package com.graduationdesign.backend.controller;

import com.graduationdesign.backend.Result;
import com.graduationdesign.backend.Utils;
import com.graduationdesign.backend.entity.User;
import com.graduationdesign.backend.service.IUserService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import javax.servlet.http.HttpServletRequest;

@Slf4j
@RestController
@RequestMapping(value = "/person")
public class PersonController {
    @Autowired
    private IUserService userService;

    @RequestMapping(value = "/getLiveBloggerInfo", method = RequestMethod.GET)
    private Result getLiveBloggerInfo(@RequestParam(value = "userId") String userId) {
        User user = userService.findUserById(userId);
        if (user == null) {
            log.info("[PersonController] getLiveBloggerInfo 获取用户信息失败 " + userId);
            return Result.failed(500, "获取用户信息失败 " + userId);
        } else {
            log.info("[PersonController] getLiveBloggerInfo 获取用户信息成功 " + user);
            return Result.success(user);
        }
    }

    @RequestMapping(value = "/getOwnInfo", method = RequestMethod.GET)
    private Result getOwnInfo(HttpServletRequest request) {
        String userId = Utils.getUserIdFromToken(request.getHeader("token"));
        User user = userService.findUserById(userId);
        if (user == null) {
            log.info("[PersonController] getOwnInfo 获取信息失败 " + userId);
            return Result.failed(500, "获取信息失败 " + userId);
        } else {
            log.info("[PersonController] getOwnInfo 获取信息成功 " + user);
            return Result.success(user);
        }
    }
}
