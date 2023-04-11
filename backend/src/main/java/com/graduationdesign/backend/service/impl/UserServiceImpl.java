package com.graduationdesign.backend.service.impl;

import com.graduationdesign.backend.entity.User;
import com.graduationdesign.backend.mapper.UserMapper;
import com.graduationdesign.backend.service.IUserService;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletResponse;
import java.util.List;

@Service
public class UserServiceImpl implements IUserService {
    @Resource
    private UserMapper mapper;

    @Override
    public User findUserByEmail(String email) {
        return mapper.findUserByEmail(email);
    }

    @Override
    public void addUser(User user) {
        mapper.addUser(user);
    }

    @Override
    public boolean verifyUserById(String id) {
        User user = mapper.findUserById(id);
        return user != null;
    }

    @Override
    public User findUserByName(String name) {
        return mapper.findUserByName(name);
    }

    @Override
    public void updatePwdByEmail(String email, String pwd) {
        mapper.updatePwdByEmail(email, pwd);
    }

    @Override
    public User findUserById(String id) {
        return mapper.findUserById(id);
    }
}
