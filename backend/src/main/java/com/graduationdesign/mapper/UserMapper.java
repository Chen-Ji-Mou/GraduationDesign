package com.graduationdesign.mapper;

import com.graduationdesign.entity.User;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface UserMapper {
    List<User> findUserList();
}
