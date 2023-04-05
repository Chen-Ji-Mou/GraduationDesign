package com.graduationdesign.backend.mapper;

import com.graduationdesign.backend.entity.User;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;
import java.util.List;

@Mapper
public interface UserMapper {
    @Select("SELECT * FROM user")
    public List<User> getAllUsers();
}
