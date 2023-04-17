package com.graduationdesign.backend.controller;

import com.graduationdesign.backend.Result;
import com.graduationdesign.backend.Utils;
import com.graduationdesign.backend.entity.Live;
import com.graduationdesign.backend.service.ILiveService;
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
import java.util.List;

@Slf4j
@RestController
@RequestMapping(value = "/live")
public class LiveController {
    @Autowired
    private ILiveService liveService;

    @Value("${file.upload.root.path}")
    private String fileRootPath;

    @RequestMapping(value = "/apply", method = RequestMethod.POST)
    private Result apply(HttpServletRequest request) {
        Live live = new Live();
        String liveId = RandomStringUtils.randomNumeric(7);
        live.setId(liveId);
        String userId = Utils.getUserIdFromToken(request.getHeader("token"));
        live.setUserId(userId);
        live.setIng(false);
        live.setNumber(0);
        liveService.addLive(live);
        log.info("[LiveController] apply 申请直播间成功 " + liveId);
        return Result.success(liveId);
    }

    @RequestMapping(value = "/start", method = RequestMethod.POST)
    private Result start(@RequestParam(name = "liveId") String liveId) {
        Live live = liveService.findLiveById(liveId);
        if (live == null) {
            log.info("[LiveController] start 直播间不存在 " + liveId);
            return Result.failed(500, "直播间不存在");
        }
        liveService.updateLiveStatusById(liveId, true);
        log.info("[LiveController] start 直播间状态改变成功 active");
        return Result.success();
    }

    @RequestMapping(value = "/stop", method = RequestMethod.POST)
    private Result stop(@RequestParam(name = "liveId") String liveId) {
        Live live = liveService.findLiveById(liveId);
        if (live == null) {
            log.info("[LiveController] stop 直播间不存在 " + liveId);
            return Result.failed(500, "直播间不存在");
        }
        liveService.updateLiveStatusById(liveId, false);
        log.info("[LiveController] stop 直播间状态改变成功 interdict");
        return Result.success();
    }

    @RequestMapping(value = "/verifyUserHasLive", method = RequestMethod.GET)
    private Result verifyUserHasLive(HttpServletRequest request) {
        String userId = Utils.getUserIdFromToken(request.getHeader("token"));
        Live live = liveService.findLiveByUserId(userId);
        if (live == null) {
            log.info("[LiveController] verifyUserHasLive 当前用户未拥有直播间");
            return Result.failed(500, "当前用户未拥有直播间");
        }
        log.info("[LiveController] verifyUserHasLive 当前用户已拥有直播间 " + live.getId());
        return Result.success(live.getId());
    }

    @RequestMapping(value = "/getLives", method = RequestMethod.GET)
    private Result getLives(@RequestParam(name = "pageNum") Integer pageNum,
                            @RequestParam(name = "pageSize") Integer pageSize) {
        pageNum *= pageSize;
        List<Live> lives = liveService.getLives(pageNum, pageSize);
        log.info("[LiveController] getLives 获取直播间列表成功 pageNum " + pageNum + " pageSize " + pageSize);
        return Result.success(lives);
    }

    @RequestMapping(value = "/enterLive", method = RequestMethod.POST)
    private Result enterLive(@RequestParam(name = "liveId") String liveId) {
        Live live = liveService.findLiveById(liveId);
        if (live == null) {
            log.info("[LiveController] enterLive 直播间不存在 " + liveId);
            return Result.failed(500, "直播间不存在");
        }
        Integer curNumber = liveService.updateLiveNumberById(liveId, true);
        log.info("[LiveController] enterLive 更新直播间人数成功 当前人数 " + curNumber);
        return Result.success();
    }

    @RequestMapping(value = "/exitLive", method = RequestMethod.POST)
    private Result exitLive(@RequestParam(name = "liveId") String liveId) {
        Live live = liveService.findLiveById(liveId);
        if (live == null) {
            log.info("[LiveController] exitLive 直播间不存在 " + liveId);
            return Result.failed(500, "直播间不存在");
        }
        Integer curNumber = liveService.updateLiveNumberById(liveId, false);
        log.info("[LiveController] exitLive 更新直播间人数成功 当前人数 " + curNumber);
        return Result.success();
    }

    @RequestMapping(value = "/uploadCover", method = RequestMethod.POST)
    private Result uploadCover(@RequestParam(name = "liveId") String liveId,
                               @RequestParam("file") MultipartFile file) {
        String coverFileName = "cover_" + liveId + ".jpg";
        String coverFilePath = fileRootPath + '/' + coverFileName;
        File coverFile = new File(coverFilePath);
        try {
            // 生成父目录
            if (!coverFile.getParentFile().exists()) {
                coverFile.getParentFile().mkdirs();
            }

            // 覆盖原有文件
            if (coverFile.exists()) {
                coverFile.delete();
                coverFile.createNewFile();
            } else {
                coverFile.createNewFile();
            }

            // 保存视频文件放入本地
            file.transferTo(coverFile);

            // 生成数据库记录
            liveService.updateLiveCoverUrlById(liveId, coverFileName);

            log.info("[LiveController] uploadCover 直播间封面上传成功 liveId {} path {}", liveId, coverFilePath);
            return Result.success();
        } catch (Exception e) {
            e.printStackTrace();
            log.info("[LiveController] uploadCover 直播间封面上传失败 liveId {}", liveId);
            return Result.failed(500, "直播间封面上传失败");
        }
    }

    @RequestMapping(value = "/downloadCover", method = RequestMethod.GET)
    private void downloadCover(@RequestParam(name = "liveId") String liveId, HttpServletResponse response) {
        String coverFileName = liveService.findLiveById(liveId).getCoverUrl();
        String coverFilePath = fileRootPath + '/' + coverFileName;
        File file = new File(coverFilePath);
        if (!file.exists()) {
            log.info("[LiveController] downloadCover 直播间封面文件不存在 liveId {}", liveId);
        }

        response.reset();
        response.setContentType("image/jpeg");
        response.setCharacterEncoding("utf-8");
        response.setContentLength((int) file.length());
        response.setHeader("Content-Disposition", "attachment;filename=" + coverFileName);

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
            log.info("[LiveController] downloadCover 直播间封面文件下载成功 liveId {} name {}", liveId, coverFileName);
        } catch (IOException e) {
            log.info("[LiveController] downloadCover 直播间封面文件下载失败 name {}", coverFileName);
        }
    }
}
