package com.graduationdesign.backend.controller;

import com.graduationdesign.backend.Result;
import com.graduationdesign.backend.Utils;
import com.graduationdesign.backend.entity.Live;
import com.graduationdesign.backend.service.ILiveService;
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
@RequestMapping(value = "/live")
public class LiveController {
    @Autowired
    private ILiveService liveService;

    @RequestMapping(value = "/apply", method = RequestMethod.POST)
    private Result apply(HttpServletRequest request) {
        Live live = new Live();
        String liveId = RandomStringUtils.randomNumeric(7);
        live.setId(liveId);
        String userId = Utils.getUserIdFromToken(request.getHeader("token"));
        live.setUserId(userId);
        live.setIng(false);
        live.setNumber(0);
        liveService.addLive(live);
        log.info("[LiveController] apply 申请直播间成功 " + liveId);
        return Result.success(liveId);
    }

    @RequestMapping(value = "/start", method = RequestMethod.POST)
    private Result start(@RequestParam(name = "liveId") String liveId) {
        liveService.updateLiveStatusById(liveId, true);
        log.info("[LiveController] start 直播间状态改变成功 active");
        return Result.success();
    }

    @RequestMapping(value = "/stop", method = RequestMethod.POST)
    private Result stop(@RequestParam(name = "liveId") String liveId) {
        liveService.updateLiveStatusById(liveId, false);
        log.info("[LiveController] stop 直播间状态改变成功 interdict");
        return Result.success();
    }

    @RequestMapping(value = "/verifyUserHasLive", method = RequestMethod.GET)
    private Result verifyUserHasLive(HttpServletRequest request) {
        String userId = Utils.getUserIdFromToken(request.getHeader("token"));
        Live live = liveService.findLiveByUserId(userId);
        if (live == null) {
            log.info("[LiveController] verifyUserHasLive 当前用户未拥有直播间");
            return Result.failed(500, "当前用户未拥有直播间");
        } else {
            log.info("[LiveController] verifyUserHasLive 当前用户已拥有直播间 " + live.getId());
            return Result.success(live.getId());
        }
    }

    @RequestMapping(value = "/getLives", method = RequestMethod.GET)
    private Result getLives(@RequestParam(name = "pageNum") Integer pageNum,
                            @RequestParam(name = "pageSize") Integer pageSize) {
        pageNum *= pageSize;
        List<Live> lives = liveService.getLives(pageNum, pageSize);
        log.info("[LiveController] getLives 获取直播间列表成功 pageNum " + pageNum + " pageSize " + pageSize);
        return Result.success(lives);
    }
}
