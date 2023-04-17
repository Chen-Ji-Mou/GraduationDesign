package com.graduationdesign.backend.controller;

import com.graduationdesign.backend.LRUCache;
import com.graduationdesign.backend.Result;
import com.graduationdesign.backend.Utils;
import com.graduationdesign.backend.entity.Video;
import com.graduationdesign.backend.service.IVideoService;
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
@RequestMapping(value = "/video")
public class VideoController {
    @Autowired
    IVideoService videoService;

    @Value("${file.upload.root.path}")
    private String fileRootPath;

    private final LRUCache<String, String> videoCache = new LRUCache<>(500); // 最多保存500个视频文件

    @RequestMapping(value = "/getVideos", method = RequestMethod.GET)
    public Result getVideos(@RequestParam(name = "pageNum") Integer pageNum, @RequestParam(name = "pageSize") Integer pageSize) {
        pageNum *= pageSize;
        List<Video> videos = videoService.getVideos(pageNum, pageSize);
        log.info("[VideoController] getVideos 获取视频列表成功 pageNum " + pageNum + " pageSize " + pageSize);
        return Result.success(videos);
    }

    @RequestMapping(value = "/uploadVideo", method = RequestMethod.POST)
    public Result uploadVideo(HttpServletRequest request, @RequestParam("file") MultipartFile file) {
        String userId = Utils.getUserIdFromToken(request.getHeader("token"));
        String fileName = file.getOriginalFilename();
        String filePath = fileRootPath + '/' + fileName;
        File dest = new File(filePath);
        try {
            // 生成父目录
            if (!dest.getParentFile().exists()) {
                dest.getParentFile().mkdirs();
            }

            // 覆盖原有文件
            if (dest.exists()) {
                dest.delete();
                dest.createNewFile();
            } else {
                dest.createNewFile();
            }

            // 保存视频文件放入本地
            file.transferTo(dest);

            // 生成数据库记录
            Video video = new Video();
            String videoId = RandomStringUtils.randomNumeric(11);
            video.setId(videoId);
            video.setUserId(userId);
            video.setFileName(fileName);
            video.setTimestamp(System.currentTimeMillis());
            videoService.addVideo(video);

            // 视频缓存插入
            insertCache(videoId, fileName);

            log.info("[VideoController] upload 视频上传成功 path {}", filePath);
            return Result.success();
        } catch (Exception e) {
            e.printStackTrace();
            log.info("[VideoController] upload 视频上传失败 path {}", filePath);
            return Result.failed(500, "视频上传失败");
        }
    }

    @RequestMapping(value = "/downloadVideo", method = RequestMethod.GET)
    public void downloadVideo(HttpServletResponse response, @RequestParam("fileName") String fileName) {
        String filePath = fileRootPath + '/' + fileName;
        File file = new File(filePath);
        if (!file.exists()) {
            log.info("[VideoController] download 视频文件不存在 name {}", fileName);
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
            log.info("[VideoController] download 视频下载成功 name {}", fileName);
        } catch (IOException e) {
            log.info("[VideoController] download 视频下载失败 name {}", fileName);
        }
    }

    private void insertCache(String videoId, String fileName) {
        String deleteFileName = videoCache.put(videoId, fileName);
        if (deleteFileName != null) {
            log.info("[FileController] insertFileCache cache缓存达到最大值，需要删除文件");
            String deleteFilePath = fileRootPath + '/' + deleteFileName;
            File deleteFile = new File(deleteFilePath);
            boolean deleteSuccess = deleteFile.delete();
            if (deleteSuccess) {
                log.info("[FileController] insertFileCache 成功删除文件 path {}", deleteFilePath);
                videoService.deleteVideo(deleteFileName);
            } else {
                log.info("[FileController] insertFileCache 文件删除失败，正在恢复cache数据");
                // 如果文件删除失败则需要从数据库恢复数据，因为cache中已经删除，需要将数据重新插入cache
                Video restoreVideo = videoService.getVideo(deleteFileName);
                insertCache(restoreVideo.getId(), restoreVideo.getFileName());
            }
        }
    }
}
