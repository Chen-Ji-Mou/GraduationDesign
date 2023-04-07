package com.graduationdesign.backend.controller;

import com.graduationdesign.backend.Result;
import com.graduationdesign.backend.Utils;
import com.graduationdesign.backend.entity.User;
import com.graduationdesign.backend.service.IUserService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

@Slf4j
@RestController
@RequestMapping(value = "/user")
public class UserController {
    @Autowired
    private IUserService service;

    @RequestMapping(value = "/login", method = RequestMethod.POST)
    @ResponseBody
    private Result login(@RequestParam(name = "email") String email,
                         @RequestParam(name = "pwd") String pwd) {
        User user = service.findUserByEmail(email);
        if (user == null) {
            return Result.failed(500, "该用户不存在");
        }
        if (!user.getPwd().equals(pwd)) {
            return Result.failed(500, "密码错误");
        }
        String token = Utils.generateToken(user);
        return Result.success(token);
    }

    @RequestMapping(value = "/register", method = RequestMethod.POST)
    @ResponseBody
    private Result register(@RequestParam(value = "name") String name,
                            @RequestParam(value = "email") String email,
                            @RequestParam(value = "pwd") String pwd) {
        if (service.findUserByName(name) != null) {
            return Result.failed(500, "该用户名已被使用");
        }
        if (service.findUserByEmail(email) != null) {
            return Result.failed(500, "该邮箱已被注册");
        }
        User user = new User();
        user.setId(Utils.generateRandomID(11));
        user.setName(name);
        user.setEmail(email);
        user.setPwd(pwd);
        service.addUser(user);
        return Result.success();
    }
}
