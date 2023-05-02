package com.graduationdesign.backend.controller;

import com.graduationdesign.backend.Result;
import com.graduationdesign.backend.Utils;
import com.graduationdesign.backend.entity.Enterprise;
import com.graduationdesign.backend.service.IEnterpriseService;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.RandomStringUtils;
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
@RequestMapping(value = "/enterprise")
public class EnterpriseController {

    @Autowired
    private IEnterpriseService enterpriseService;
    @Value("${file.upload.root.path}")
    private String fileRootPath;

    @RequestMapping(value = "/uploadLicense", method = RequestMethod.POST)
    private Result uploadLicense(@RequestParam("file") MultipartFile file) {
        String fileSuffix = file.getOriginalFilename().substring(file.getOriginalFilename().lastIndexOf("."));
        String licenseFileName = "license_" + System.currentTimeMillis() + fileSuffix;
        String licenseFilePath = fileRootPath + '/' + licenseFileName;
        File licenseFile = new File(licenseFilePath);
        try {
            // 生成父目录
            if (!licenseFile.getParentFile().exists()) {
                licenseFile.getParentFile().mkdirs();
            }

            // 覆盖原有文件
            if (licenseFile.exists()) {
                licenseFile.delete();
                licenseFile.createNewFile();
            } else {
                licenseFile.createNewFile();
            }

            // 保存文件放入本地
            file.transferTo(licenseFile);

            log.info("[EnterpriseController] uploadLicense 营业执照上传成功 path {}", licenseFilePath);
            return Result.success(licenseFileName);
        } catch (Exception e) {
            e.printStackTrace();
            log.info("[EnterpriseController] uploadLicense 营业执照上传失败");
            return Result.failed(500, "营业执照上传失败");
        }
    }

    @RequestMapping(value = "/downloadLicense", method = RequestMethod.GET)
    private void downloadLicense(@RequestParam("fileName") String fileName, HttpServletResponse response) throws IOException {
        String licenseFilePath = fileRootPath + '/' + fileName;
        File file = new File(licenseFilePath);
        if (!file.exists()) {
            log.info("[EnterpriseController] downloadLicense 营业执照文件不存在 name {}", fileName);
            response.reset();
            response.setStatus(500);
            response.setContentType("application/json");
            response.setCharacterEncoding("utf-8");
            response.getWriter().write("营业执照文件不存在");
            return;
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
            log.info("[EnterpriseController] downloadLicense 营业执照下载成功 name {}", fileName);
        } catch (IOException e) {
            log.info("[EnterpriseController] downloadLicense 营业执照下载失败 name {}", fileName);
        }
    }

    @RequestMapping(value = "/authentication", method = RequestMethod.POST)
    private Result authentication(HttpServletRequest request, @RequestParam("code") String code,
                            @RequestParam("license") String license) {
        String userId = Utils.getUserIdFromToken(request.getHeader("token"));
        if (enterpriseService.findEnterpriseByUserId(userId) != null) {
            log.info("[EnterpriseController] authentication 当前用户已认证 userId {}", userId);
            return Result.failed(500, "当前用户已认证");
        }
        Enterprise enterprise = new Enterprise();
        String enterpriseId = RandomStringUtils.randomNumeric(11);
        enterprise.setId(enterpriseId);
        enterprise.setUserId(userId);
        enterprise.setCode(code);
        enterprise.setLicenseUrl(license);
        enterpriseService.addEnterprise(enterprise);
        log.info("[EnterpriseController] authentication 商家认证成功 enterpriseId {}", enterpriseId);
        return Result.success();
    }

    @RequestMapping(value = "/verifyUserHasAuthenticated", method = RequestMethod.GET)
    private Result verifyUserHasAuthenticated(HttpServletRequest request) {
        String userId = Utils.getUserIdFromToken(request.getHeader("token"));
        Enterprise enterprise = enterpriseService.findEnterpriseByUserId(userId);
        if (enterprise == null) {
            log.info("[EnterpriseController] verifyUserHasAuthenticated 当前用户未认证 userId {}", userId);
            return Result.failed(500, "当前用户未认证");
        }
        log.info("[EnterpriseController] verifyUserHasAuthenticated 当前用户已认证 userId {} enterpriseId {}", userId, enterprise.getId());
        return Result.success(enterprise.getId());
    }
}
