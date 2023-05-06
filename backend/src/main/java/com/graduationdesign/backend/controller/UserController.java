package com.graduationdesign.backend.controller;

import com.graduationdesign.backend.RedisUtil;
import com.graduationdesign.backend.Result;
import com.graduationdesign.backend.Utils;
import com.graduationdesign.backend.entity.User;
import com.graduationdesign.backend.service.IUserService;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.RandomStringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.web.bind.annotation.*;

import javax.mail.internet.MimeMessage;

@Slf4j
@RestController
@RequestMapping(value = "/user")
public class UserController {
    @Autowired
    private IUserService userService;
    @Autowired
    private JavaMailSender emailSender;
    @Autowired
    private RedisUtil redisUtil;
    @Value("${spring.mail.username}")
    private String from;

    @RequestMapping(value = "/login", method = RequestMethod.POST)
    private Result login(@RequestParam(name = "email") String email, @RequestParam(name = "pwd") String pwd) {
        User user = userService.findUserByEmail(email);
        if (user == null) {
            log.info("[UserController] login 该用户不存在 " + email);
            return Result.failed(500, "该用户不存在");
        }
        if (!user.getPwd().equals(pwd)) {
            log.info("[UserController] login 密码错误 " + pwd);
            return Result.failed(500, "密码错误");
        }
        String token = Utils.generateToken(user);
        log.info("[UserController] login 登录成功 " + token);
        return Result.success(token);
    }

    @RequestMapping(value = "/register", method = RequestMethod.POST)
    private Result register(@RequestParam(value = "name") String name, @RequestParam(value = "email") String email,
                            @RequestParam(value = "pwd") String pwd) {
        if (userService.findUserByName(name) != null) {
            log.info("[UserController] login 该用户名已被使用 " + name);
            return Result.failed(500, "该用户名已被使用");
        }
        if (userService.findUserByEmail(email) != null) {
            log.info("[UserController] login 该邮箱已被注册 " + email);
            return Result.failed(500, "该邮箱已被注册");
        }
        User user = new User();
        user.setId(RandomStringUtils.randomNumeric(11));
        user.setName(name);
        user.setEmail(email);
        user.setPwd(pwd);
        userService.addUser(user);
        log.info("[UserController] login 新用户注册成功 " + user);
        return Result.success();
    }

    @RequestMapping(value = "/sendEmailVerificationCode", method = RequestMethod.GET)
    private Result sendEmailVerificationCode(@RequestParam(value = "email") String email) {
        try {
            //创建一个MINE消息
            MimeMessage message = emailSender.createMimeMessage();
            MimeMessageHelper mineHelper = new MimeMessageHelper(message, true);
            // 谁发的
            mineHelper.setFrom(from, "直播定制APP");
            // 谁要接收
            mineHelper.setTo(email);
            // 邮件标题
            mineHelper.setSubject("直播定制APP");
            // 生成验证码
            String verificationCode = RandomStringUtils.randomNumeric(4);
            // 邮件内容
            String html = "<div class=\"main\" style=\"padding: 0 24px\">\n" + "        <div>\n" + "            <div class=\"p1\" style=\"font-size: 18px;font-weight: 500;color: #222222;line-height: 25px;padding-bottom: 16px;\">Hi，亲爱的用户</div>\n" + "            <div class=\"p2\" style=\"font-size: 14px;font-weight: 400;color: #666666;line-height: 20px;padding-bottom: 28px;\">您正在进行邮箱验证操作，验证码为：</div>\n" + "            <div class=\"p3\" style=\"font-size: 20px;font-weight: 500;color: #ff6000;line-height: 28px;padding-bottom: 28px;\">" + verificationCode + "</div>\n" + "            <div class=\"p4\" style=\"font-size: 14px;font-weight: 400;color: #666666;line-height: 20px;padding-bottom: 52px;border-bottom: 1px solid #ffe2cd;\">请在30分钟内完成验证</div>\n" + "        </div>\n" + "        <div style=\"display: flex;flex-wrap: wrap;justify-content: center;align-items: center;\">\n" + "            <div class=\"main3\" style=\"flex: 1;min-width: 300px;padding-top: 20px;font-size: 12px;font-weight: 400;color: #999999;line-height: 24px;\">\n" + "                <p style=\"padding: 0;margin: 0;box-sizing: border-box;\">如非本人操作，请忽略该邮件</p>\n" + "                <p style=\"padding: 0;margin: 0;box-sizing: border-box;\">(这是一封通过自动发送的邮件，请不要直接回复)</p>\n" + "            </div>\n" + "        </div>" + "     </div>";
            mineHelper.setText(html, true);
            // 发送邮件
            emailSender.send(message);
            log.info("[UserController] getEmailVerificationCode 验证码邮件发送成功 " + email);
            // redis缓存验证码
            redisUtil.set(email, verificationCode, 30 * 60);
            return Result.success();
        } catch (Exception e) {
            log.info("[UserController] getEmailVerificationCode 验证码邮件发送失败 " + email);
            return Result.failed(500, "验证码邮件发送失败");
        }
    }

    @RequestMapping(value = "/verifyEmailVerificationCode", method = RequestMethod.POST)
    private Result verifyEmailVerificationCode(@RequestParam(value = "email") String email,
                                               @RequestParam(value = "code") String code) {
        if (!redisUtil.hasKey(email)) {
            log.info("[UserController] verifyEmailVerificationCode 验证码不存在 " + email);
            return Result.failed(500, "验证码不存在");
        }
        if (redisUtil.isExpire(email)) {
            log.info("[UserController] verifyEmailVerificationCode 验证码已过期 " + email);
            return Result.failed(500, "验证码已过期，请重新获取");
        }
        String verificationCode = redisUtil.get(email).toString();
        if (!code.equals(verificationCode)) {
            log.info("[UserController] verifyEmailVerificationCode 验证码输入错误 " + email);
            return Result.failed(500, "验证码输入错误，请重新输入");
        }
        log.info("[UserController] verifyEmailVerificationCode 验证码验证通过 " + email);
        redisUtil.delete(email);
        return Result.success();
    }

    @RequestMapping(value = "/changePwd", method = RequestMethod.POST)
    private Result changePwd(@RequestParam(value = "email") String email, @RequestParam(value = "pwd") String pwd) {
        try {
            userService.updatePwdByEmail(email, pwd);
            log.info("[UserController] changePwd 密码修改成功 " + email);
            return Result.success();
        } catch (Exception e) {
            e.printStackTrace();
            log.info("[UserController] changePwd 密码修改失败 " + email);
            return Result.failed(500, "密码修改失败");
        }
    }

    @RequestMapping(value = "/verifyUserToken", method = RequestMethod.GET)
    private Result verifyUserToken(@RequestParam("token") String token) {
        if (token == null) {
            log.info("[UserController] verifyUserToken token不存在");
            return Result.failed(500, "token不存在");
        }
        String userId = Utils.getUserIdFromToken(token);
        if (userId == null) {
            log.info("[UserController] verifyUserToken token已过期 token {}", token);
            return Result.failed(500, "token已过期");
        }
        boolean result = userService.verifyUserById(userId);
        if (!result) {
            log.info("[UserController] verifyUserToken userId不存在 userId {}", userId);
            return Result.failed(500, "userId不存在");
        }
        log.info("[UserController] verifyUserToken token验证成功 userId {}", userId);
        return Result.success();
    }
}
