package com.graduationdesign.backend.controller;

import com.graduationdesign.backend.Result;
import com.graduationdesign.backend.Utils;
import com.graduationdesign.backend.entity.Detailed;
import com.graduationdesign.backend.service.IDetailedService;
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
@RequestMapping(value = "/detailed")
public class DetailedController {
    @Autowired
    IDetailedService detailedService;

    @RequestMapping(value = "/addDetailed", method = RequestMethod.POST)
    private Result addDetailed(HttpServletRequest request, @RequestParam(name = "income") Integer income,
                               @RequestParam(name = "expenditure") Integer expenditure) {
        String userId = Utils.getUserIdFromToken(request.getHeader("token"));
        Detailed detailed = new Detailed();
        String detailedId = RandomStringUtils.randomNumeric(11);
        detailed.setId(detailedId);
        detailed.setUserId(userId);
        detailed.setIncome(income);
        detailed.setExpenditure(expenditure);
        detailedService.addDetailed(detailed);
        log.info("[DetailedController] addDetailed 该用户明细添加成功 userId {} detailedId {}", userId, detailedId);
        return Result.success();
    }

    @RequestMapping(value = "/getDetailed", method = RequestMethod.GET)
    private Result getDetailed(HttpServletRequest request, @RequestParam(name = "pageNum") Integer pageNum,
                               @RequestParam(name = "pageSize") Integer pageSize) {
        String userId = Utils.getUserIdFromToken(request.getHeader("token"));
        List<Detailed> result = detailedService.getDetailed(userId, pageNum, pageSize);
        log.info("[DetailedController] getDetailed 获取该用户明细列表成功 userId {}", userId);
        return Result.success(result);
    }
}
