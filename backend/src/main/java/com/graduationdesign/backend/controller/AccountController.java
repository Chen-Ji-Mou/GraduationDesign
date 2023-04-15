package com.graduationdesign.backend.controller;

import com.graduationdesign.backend.Result;
import com.graduationdesign.backend.Utils;
import com.graduationdesign.backend.entity.Account;
import com.graduationdesign.backend.service.IAccountService;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.RandomStringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import javax.servlet.http.HttpServletRequest;

@Slf4j
@RestController
@RequestMapping(value = "/account")
public class AccountController {
    @Autowired
    IAccountService accountService;

    @RequestMapping(value = "/createAccount", method = RequestMethod.POST)
    private Result createAccount(HttpServletRequest request) {
        String userId = Utils.getUserIdFromToken(request.getHeader("token"));
        Account account = accountService.findAccountByUserId(userId);
        if (account != null) {
            log.info("[AccountController] createAccount 该用户已创建账户 userId {}", userId);
            return Result.failed(500, "该用户已创建账户");
        }
        Account newAccount = new Account();
        String accountId = RandomStringUtils.randomNumeric(11);
        newAccount.setId(accountId);
        newAccount.setUserId(userId);
        newAccount.setBalance(0);
        accountService.addAccount(newAccount);
        log.info("[AccountController] createAccount 该用户创建新账户成功 userId {} accountId {}", userId, accountId);
        return Result.success();
    }

    @RequestMapping(value = "/rechargeAccount", method = RequestMethod.POST)
    private Result rechargeAccount(HttpServletRequest request, @RequestParam(name = "amount") Integer amount) {
        String userId = Utils.getUserIdFromToken(request.getHeader("token"));
        Account account = accountService.findAccountByUserId(userId);
        if (account == null) {
            log.info("[AccountController] rechargeAccount 该用户未创建账户 userId {}", userId);
            return Result.failed(500, "该用户未创建账户");
        }
        Integer curBalance = account.getBalance();
        curBalance += amount;
        accountService.accountChange(userId, curBalance);
        log.info("[AccountController] rechargeAccount 账户余额充值成功 userId {} balance {}", userId, curBalance);
        return Result.success();
    }

    @RequestMapping(value = "/spendAccount", method = RequestMethod.POST)
    private Result spendAccount(HttpServletRequest request, @RequestParam(name = "amount") Integer amount) {
        String userId = Utils.getUserIdFromToken(request.getHeader("token"));
        Account account = accountService.findAccountByUserId(userId);
        if (account == null) {
            log.info("[AccountController] spendAccount 该用户未创建账户 userId {}", userId);
            return Result.failed(500, "该用户未创建账户");
        }
        Integer curBalance = account.getBalance();
        if (curBalance - amount < 0) {
            log.info("[AccountController] spendAccount 账户余额不足 userId {} balance {}", userId, curBalance);
            return Result.failed(500, "账户余额不足");
        }
        curBalance -= amount;
        accountService.accountChange(userId, curBalance);
        log.info("[AccountController] spendAccount 账户余额花费成功 userId {} balance {}", userId, curBalance);
        return Result.success();
    }
}
