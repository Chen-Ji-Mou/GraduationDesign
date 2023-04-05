package com.graduationdesign.service.impl;

import com.graduationdesign.entity.User;
import com.graduationdesign.mapper.UserMapper;
import com.graduationdesign.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class UserServiceImpl implements UserService {

    @Autowired
    private UserMapper userMapper;

    @Override
    public List<User> findUserList() {
        return userMapper.findUserList();
    }
}
