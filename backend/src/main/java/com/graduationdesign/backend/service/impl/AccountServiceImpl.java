package com.graduationdesign.backend.service.impl;

import com.graduationdesign.backend.entity.Account;
import com.graduationdesign.backend.mapper.AccountMapper;
import com.graduationdesign.backend.service.IAccountService;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;

@Service
public class AccountServiceImpl implements IAccountService {
    @Resource
    AccountMapper mapper;

    @Override
    public void addAccount(Account account) {
        mapper.addAccount(account);
    }

    @Override
    public Account findAccountByUserId(String userId) {
        return mapper.findAccountByUserId(userId);
    }

    @Override
    public void accountChange(String userId, int balance) {
        mapper.accountChange(userId, balance);
    }
}
