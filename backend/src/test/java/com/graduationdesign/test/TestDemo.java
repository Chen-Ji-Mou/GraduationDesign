package com.graduationdesign.test;

import com.graduationdesign.entity.User;
import com.graduationdesign.mapper.UserMapper;
import com.graduationdesign.service.UserService;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;
import java.util.List;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(locations = "classpath:applicationContext.xml")
public class TestDemo {

    @Autowired
    private UserService userService;

    @Test
    public void testFindUserList(){
        List<User> userList = userService.findUserList();
        System.out.println("[chenjimou]"+userList);
    }
}
