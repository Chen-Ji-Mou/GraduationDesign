package com.graduationdesign.backend.controller;

import com.graduationdesign.backend.entity.User;
import com.graduationdesign.backend.mapper.UserMapper;
import com.graduationdesign.backend.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import javax.annotation.Resource;
import java.util.List;

@RestController
public class UserController {
    @Autowired
    private UserService service;

    @GetMapping("/allUser")
    public List<User> getAllUsers() {
        return service.getAllUsers();
    }
}
