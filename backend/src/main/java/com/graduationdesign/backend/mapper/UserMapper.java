package com.graduationdesign.backend.mapper;

import com.graduationdesign.backend.entity.User;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

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
}
