package com.graduationdesign.backend.controller;

import com.graduationdesign.backend.Result;
import com.graduationdesign.backend.Utils;
import com.graduationdesign.backend.entity.Bag;
import com.graduationdesign.backend.entity.Gift;
import com.graduationdesign.backend.service.IBagService;
import com.graduationdesign.backend.service.IGiftService;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.RandomStringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import javax.servlet.http.HttpServletRequest;
import java.util.List;

@Slf4j
@RestController
@RequestMapping(value = "/bag")
public class BagController {

    @Autowired
    IBagService bagService;
    @Autowired
    IGiftService giftService;

    @RequestMapping(value = "/getUserBag", method = RequestMethod.GET)
    private Result getUserBag(HttpServletRequest request) {
        String userId = Utils.getUserIdFromToken(request.getHeader("token"));
        List<Bag> bags = bagService.findBagsByUserId(userId);
        log.info("[BagController] getUserBag 获取用户礼物背包成功 userId {}", userId);
        return Result.success(bags);
    }

    @RequestMapping(value = "/getGiftNumber", method = RequestMethod.GET)
    private Result getGiftNumber(HttpServletRequest request, @RequestParam(name = "giftId") String giftId) {
        String userId = Utils.getUserIdFromToken(request.getHeader("token"));
        Bag bag = bagService.findBagByUserIdAndGiftId(userId, giftId);
        if (bag == null) {
            log.info("[BagController] getGiftNumber 用户未拥有该礼物 userId {} giftId {}", userId, giftId);
            return Result.failed(500, "用户未拥有该礼物");
        }
        Integer number = bag.getNumber();
        log.info("[BagController] getGiftNumber 获取用户礼物数量成功 userId {} giftId {} number {}", userId, giftId, number);
        return Result.success(number);
    }

    @RequestMapping(value = "/addBag", method = RequestMethod.POST)
    private Result addBag(HttpServletRequest request, @RequestParam(name = "giftId") String giftId) {
        String userId = Utils.getUserIdFromToken(request.getHeader("token"));
        Gift gift = giftService.findGiftById(giftId);
        if (gift == null) {
            log.info("[BagController] addBag 礼物不存在 giftId {}", giftId);
            return Result.failed(500, "礼物不存在");
        }
        Bag bag = bagService.findBagByUserIdAndGiftId(userId, giftId);
        if (bag == null) {
            Bag newBag = new Bag();
            String bagId = RandomStringUtils.randomNumeric(11);
            newBag.setId(bagId);
            newBag.setUserId(userId);
            newBag.setGiftId(giftId);
            newBag.setNumber(1);
            bagService.addBag(newBag);
            log.info("[BagController] addBag 用户背包记录创建成功 bagId {}", bagId);
        } else {
            String bagId = bag.getId();
            Integer curNumber = bag.getNumber();
            bagService.updateNumberByUserIdAndGiftId(userId, giftId, ++curNumber);
            log.info("[BagController] addBag 用户背包记录更改成功 bagId {} number {}", bagId, curNumber);
        }
        return Result.success();
    }

    @RequestMapping(value = "/reduceBag", method = RequestMethod.POST)
    private Result reduceBag(HttpServletRequest request, @RequestParam(name = "giftId") String giftId) {
        String userId = Utils.getUserIdFromToken(request.getHeader("token"));
        Gift gift = giftService.findGiftById(giftId);
        if (gift == null) {
            log.info("[BagController] reduceBag 礼物不存在 giftId {}", giftId);
            return Result.failed(500, "礼物不存在");
        }
        Bag bag = bagService.findBagByUserIdAndGiftId(userId, giftId);
        if (bag == null) {
            log.info("[BagController] reduceBag 用户背包记录不存在 userId {}", userId);
            return Result.failed(500, "用户背包记录不存在");
        }
        String bagId = bag.getId();
        Integer curNumber = bag.getNumber();
        bagService.updateNumberByUserIdAndGiftId(userId, giftId, --curNumber);
        log.info("[BagController] reduceBag 用户背包记录更改成功 bagId {} number {}", bagId, curNumber);
        return Result.success();
    }
}
