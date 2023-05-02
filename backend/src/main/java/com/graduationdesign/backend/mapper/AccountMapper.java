package com.graduationdesign.backend.mapper;

import com.graduationdesign.backend.entity.Account;
import org.apache.ibatis.annotations.*;

@Mapper
public interface AccountMapper {
    @Insert("INSERT INTO account(id, userId, balance) VALUES(#{id}, #{userId}, #{balance})")
    void addAccount(Account account);

    @Select("SELECT * FROM account WHERE userId=#{userId}")
    Account findAccountByUserId(String userId);

    @Update("UPDATE account SET balance=#{balance} WHERE userId=#{userId}")
    void updateBalanceByUserId(@Param("userId") String userId, @Param("balance") int balance);
}
