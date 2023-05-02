package com.graduationdesign.backend.controller;

import com.graduationdesign.backend.Result;
import com.graduationdesign.backend.Utils;
import com.graduationdesign.backend.entity.Detail;
import com.graduationdesign.backend.service.IDetailService;
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
@RequestMapping(value = "/detail")
public class DetailController {

    @Autowired
    IDetailService detailService;

    @RequestMapping(value = "/addDetail", method = RequestMethod.POST)
    private Result addDetail(HttpServletRequest request, @RequestParam(name = "income") Integer income,
                             @RequestParam(name = "expenditure") Integer expenditure) {
        String userId = Utils.getUserIdFromToken(request.getHeader("token"));
        Detail detail = new Detail();
        String detailedId = RandomStringUtils.randomNumeric(11);
        detail.setId(detailedId);
        detail.setUserId(userId);
        detail.setIncome(income);
        detail.setExpenditure(expenditure);
        detail.setTimestamp(System.currentTimeMillis());
        detailService.addDetail(detail);
        log.info("[DetailedController] addDetailed 该用户明细添加成功 userId {} detailedId {}", userId, detailedId);
        return Result.success();
    }

    @RequestMapping(value = "/getDetails", method = RequestMethod.GET)
    private Result getDetails(HttpServletRequest request, @RequestParam(name = "pageNum") Integer pageNum,
                              @RequestParam(name = "pageSize") Integer pageSize) {
        pageNum *= pageSize;
        String userId = Utils.getUserIdFromToken(request.getHeader("token"));
        List<Detail> result = detailService.getDetails(userId, pageNum, pageSize);
        log.info("[DetailedController] getDetailed 获取该用户明细列表成功 userId {}", userId);
        return Result.success(result);
    }

    @RequestMapping(value = "/getTotalIncome", method = RequestMethod.GET)
    private Result getTotalIncome(HttpServletRequest request) {
        String userId = Utils.getUserIdFromToken(request.getHeader("token"));
        Detail detail = detailService.sumIncome(userId);
        if (detail == null) {
            log.info("[DetailedController] getTotalIncome 账户明细为空 totalIncome {}", 0);
            return Result.success(0);
        } else {
            Integer totalIncome = detail.getIncome();
            log.info("[DetailedController] getTotalIncome 获取该用户账户总收入成功 totalIncome {}", totalIncome);
            return Result.success(totalIncome);
        }
    }

    @RequestMapping(value = "/getTotalExpenditure", method = RequestMethod.GET)
    private Result getTotalExpenditure(HttpServletRequest request) {
        String userId = Utils.getUserIdFromToken(request.getHeader("token"));
        Detail detail = detailService.sumExpenditure(userId);
        if (detail == null) {
            log.info("[DetailedController] getTotalExpenditure 账户明细为空 totalIncome {}", 0);
            return Result.success(0);
        } else {
            Integer totalExpenditure = detail.getExpenditure();
            log.info("[DetailedController] getTotalExpenditure 获取该用户账户总支出成功 totalExpenditure {}", totalExpenditure);
            return Result.success(totalExpenditure);
        }
    }
}
