package com.graduationdesign.backend.service;

import com.graduationdesign.backend.entity.Account;

public interface IAccountService {
    void addAccount(Account account);
    Account findAccountByUserId(String userId);
    void updateBalanceByUserId(String userId, int balance);
}
