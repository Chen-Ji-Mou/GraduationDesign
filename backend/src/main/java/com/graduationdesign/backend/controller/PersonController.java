package com.graduationdesign.backend.controller;

import com.graduationdesign.backend.Result;
import com.graduationdesign.backend.Utils;
import com.graduationdesign.backend.entity.User;
import com.graduationdesign.backend.service.IUserService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.*;

@Slf4j
@RestController
@RequestMapping(value = "/person")
public class PersonController {
    @Autowired
    private IUserService userService;

    @Value("${file.upload.root.path}")
    private String fileRootPath;

    @RequestMapping(value = "/getUserInfo", method = RequestMethod.GET)
    private Result getUserInfo(@RequestParam(value = "userId") String userId) {
        User user = userService.findUserById(userId);
        if (user == null) {
            log.info("[PersonController] getLiveBloggerInfo 获取用户信息失败 " + userId);
            return Result.failed(500, "获取用户信息失败 " + userId);
        } else {
            log.info("[PersonController] getLiveBloggerInfo 获取用户信息成功 " + user);
            return Result.success(user);
        }
    }

    @RequestMapping(value = "/getOwnInfo", method = RequestMethod.GET)
    private Result getOwnInfo(HttpServletRequest request) {
        String userId = Utils.getUserIdFromToken(request.getHeader("token"));
        User user = userService.findUserById(userId);
        if (user == null) {
            log.info("[PersonController] getOwnInfo 获取信息失败 " + userId);
            return Result.failed(500, "获取信息失败 " + userId);
        } else {
            log.info("[PersonController] getOwnInfo 获取信息成功 " + user);
            return Result.success(user);
        }
    }

    @RequestMapping(value = "/uploadAvatar", method = RequestMethod.POST)
    private Result uploadAvatar(HttpServletRequest request, @RequestParam("file") MultipartFile file) {
        String userId = Utils.getUserIdFromToken(request.getHeader("token"));
        String fileSuffix = file.getOriginalFilename().substring(file.getOriginalFilename().lastIndexOf("."));
        String avatarFileName = "avatar_" + userId + fileSuffix;
        String avatarFilePath = fileRootPath + '/' + avatarFileName;
        File avatarFile = new File(avatarFilePath);
        try {
            // 生成父目录
            if (!avatarFile.getParentFile().exists()) {
                avatarFile.getParentFile().mkdirs();
            }

            // 覆盖原有文件
            if (avatarFile.exists()) {
                avatarFile.delete();
                avatarFile.createNewFile();
            } else {
                avatarFile.createNewFile();
            }

            // 保存视频文件放入本地
            file.transferTo(avatarFile);

            // 生成数据库记录
            userService.updateAvatarUrlById(userId, avatarFileName);

            log.info("[PersonController] uploadAvatar 用户头像上传成功 userId {} path {}", userId, avatarFilePath);
            return Result.success();
        } catch (Exception e) {
            e.printStackTrace();
            log.info("[PersonController] uploadAvatar 用户头像上传失败 userId {}", userId);
            return Result.failed(500, "用户头像上传失败");
        }
    }

    @RequestMapping(value = "/downloadAvatar", method = RequestMethod.GET)
    private void downloadAvatar(@RequestParam("fileName") String fileName, HttpServletResponse response) {
        String avatarFilePath = fileRootPath + '/' + fileName;
        File file = new File(avatarFilePath);
        if (!file.exists()) {
            log.info("[PersonController] downloadAvatar 头像文件不存在 name {}", fileName);
        }

        response.reset();
        response.setContentType("application/octet-stream");
        response.setCharacterEncoding("utf-8");
        response.setContentLength((int) file.length());
        response.setHeader("Content-Disposition", "attachment;filename=" + fileName);

        try {
            // 将文件写入输入流
            InputStream fis = new BufferedInputStream(new FileInputStream(file));
            byte[] buffer = new byte[fis.available()];
            fis.read(buffer);
            fis.close();
            // 将文件写入输出流
            OutputStream outputStream = new BufferedOutputStream(response.getOutputStream());
            outputStream.write(buffer);
            outputStream.flush();
            log.info("[PersonController] downloadAvatar 头像文件下载成功 name {}", fileName);
        } catch (IOException e) {
            log.info("[PersonController] downloadAvatar 头像文件下载失败 name {}", fileName);
        }
    }

    @RequestMapping(value = "/verifyUserHasAuth", method = RequestMethod.GET)
    private Result verifyUserHasAuth(HttpServletRequest request) {
        String userId = Utils.getUserIdFromToken(request.getHeader("token"));
        User user = userService.findUserById(userId);
        if (user.getEnterpriseId() == null) {
            log.info("[PersonController] verifyUserHasAuth 用户未进行商家认证 userId {}", userId);
            return Result.failed(500, "用户未进行商家认证");
        }
        log.info("[PersonController] verifyUserHasAuth 用户已进行商家认证 userId {}", userId);
        return Result.success();
    }
}
