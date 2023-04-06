package com.graduationdesign.backend.service.impl;

import com.graduationdesign.backend.entity.User;
import com.graduationdesign.backend.mapper.UserMapper;
import com.graduationdesign.backend.service.UserService;
import org.springframework.stereotype.Service;
import javax.annotation.Resource;
import java.util.List;

@Service
public class UserServiceImpl implements UserService {
    @Resource
    private UserMapper mapper;

    @Override
    public List<User> getAllUsers() {
        return mapper.getAllUsers();
    }
}
