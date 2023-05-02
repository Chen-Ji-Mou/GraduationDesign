package com.graduationdesign.backend.service;

import com.graduationdesign.backend.entity.User;

public interface IUserService {
    User findUserByEmail(String email);
    void addUser(User user);
    boolean verifyUserById(String id);
    User findUserByName(String name);
    void updatePwdByEmail(String email, String pwd);
    User findUserById(String id);
    void updateAvatarUrlById(String id, String avatar);
}
