package com.graduationdesign.backend.controller;

import com.graduationdesign.backend.entity.User;
import com.graduationdesign.backend.mapper.UserMapper;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import javax.annotation.Resource;
import java.util.List;

@RestController
public class UserController {
    @Resource
    private UserMapper mapper;

    @GetMapping("/allUser")
    public List<User> getAllUsers() {
        return mapper.getAllUsers();
    }
}
