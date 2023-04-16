package com.graduationdesign.backend.controller;

import com.alibaba.fastjson.JSON;
import com.graduationdesign.backend.Result;
import com.graduationdesign.backend.Utils;
import com.graduationdesign.backend.entity.Barrage;
import com.graduationdesign.backend.entity.Gift;
import com.graduationdesign.backend.entity.User;
import com.graduationdesign.backend.service.IGiftService;
import com.graduationdesign.backend.service.IUserService;
import com.graduationdesign.backend.service.IWebSocketService;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.RandomStringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import javax.servlet.http.HttpServletRequest;
import java.util.List;

@Slf4j
@RestController
@RequestMapping(value = "/gift")
public class GiftController {
    @Autowired
    IGiftService giftService;

    @Autowired
    IUserService userService;

    @Autowired
    private IWebSocketService webSocketService;

    @RequestMapping(value = "/mock", method = RequestMethod.POST)
    private Result mock() {
        Gift gift1 = new Gift();
        gift1.setId(RandomStringUtils.randomNumeric(3));
        gift1.setName("荧光棒");
        gift1.setBackgroundColor(0xB23AF2);
        gift1.setTitleColor(0x6950FB);
        gift1.setPrice(0);
        giftService.addGift(gift1);

        Gift gift2 = new Gift();
        gift2.setId(RandomStringUtils.randomNumeric(3));
        gift2.setName("飞机");
        gift2.setBackgroundColor(0x00CCFF);
        gift2.setTitleColor(0x0066FF);
        gift2.setPrice(1000);
        giftService.addGift(gift2);

        log.info("[GiftController] mock 礼物生成成功");
        return Result.success();
    }

    @RequestMapping(value = "/getGifts", method = RequestMethod.GET)
    private Result getGifts() {
        List<Gift> gifts = giftService.getGifts();
        log.info("[GiftController] getGifts 获取礼物列表成功 {}", gifts);
        return Result.success(gifts);
    }

    @RequestMapping(value = "/sendGift", method = RequestMethod.POST)
    private Result sendGift(HttpServletRequest request, @RequestParam(name = "liveId") String liveId,
                        @RequestParam(name = "giftId") String giftId) {
        String userId = Utils.getUserIdFromToken(request.getHeader("token"));
        User user = userService.findUserById(userId);
        String userName = user.getName();
        WebSocketSession session = webSocketService.getSession(liveId);
        if (session == null) {
            log.info("[GiftController] sendGift 直播间未开播 " + liveId);
            return Result.failed(500, "直播间未开播");
        }
        Gift gift = giftService.findGiftById(giftId);
        if (gift == null) {
            log.info("[GiftController] sendGift 礼物不存在 " + giftId);
            return Result.failed(500, "礼物不存在");
        }
        Barrage barrage = new Barrage(userName, null, gift);
        String msg = JSON.toJSONString(barrage.toJsonMap());
        log.info("[GiftController] sendGift json转换string完成 " + msg);
        try {
            webSocketService.broadCast(session, new TextMessage(msg));
            log.info("[GiftController] sendGift 礼物发送成功");
            return Result.success();
        } catch (Exception e) {
            e.printStackTrace();
            log.info("[GiftController] sendGift 礼物发送失败");
            return Result.failed(500, "礼物发送失败");
        }
    }

    @RequestMapping(value = "/getGift", method = RequestMethod.GET)
    private Result getGift(@RequestParam(name = "giftId") String giftId) {
        Gift gift = giftService.findGiftById(giftId);
        if (gift == null) {
            log.info("[GiftController] getGift 礼物不存在 " + giftId);
            return Result.failed(500, "礼物不存在");
        }
        log.info("[GiftController] getGift 获取礼物信息成功 " + gift);
        return Result.success(gift);
    }
}
