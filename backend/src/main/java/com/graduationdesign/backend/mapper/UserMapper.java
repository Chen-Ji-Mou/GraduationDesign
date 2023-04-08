package com.graduationdesign.backend.mapper;

import com.graduationdesign.backend.entity.User;
import org.apache.ibatis.annotations.*;

import java.util.List;

@Mapper
public interface UserMapper {
    @Select("SELECT * FROM user WHERE email=#{email}")
    User findUserByEmail(String email);

    @Insert("INSERT INTO user(id, name, pwd, email) VALUES(#{id}, #{name}, #{pwd}, #{email})")
    void addUser(User user);

    @Select("SELECT * FROM user WHERE id=#{id}")
    User findUserById(Integer id);

    @Select("SELECT * FROM user WHERE name=#{name}")
    User findUserByName(String name);

    @Update("UPDATE user SET pwd=#{pwd} WHERE email=#{email}")
    void updatePwdByEmail(@Param("email") String email, @Param("pwd") String pwd);
}
