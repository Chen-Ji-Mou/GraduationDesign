package com.graduationdesign.backend.service;

import com.graduationdesign.backend.entity.User;

import javax.servlet.http.HttpServletResponse;
import java.util.List;

public interface IUserService {
    User findUserByEmail(String email);
    void addUser(User user);
    boolean verifyUserById(Integer id);
    User findUserByName(String name);
    void updatePwdByEmail(String email, String pwd);
}
