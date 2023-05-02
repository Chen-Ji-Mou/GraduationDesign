package com.graduationdesign.backend.controller;

import com.graduationdesign.backend.Result;
import com.graduationdesign.backend.Utils;
import com.graduationdesign.backend.entity.Comment;
import com.graduationdesign.backend.entity.Video;
import com.graduationdesign.backend.service.ICommentService;
import com.graduationdesign.backend.service.IVideoService;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.RandomStringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import javax.servlet.http.HttpServletRequest;
import java.util.List;

@Slf4j
@RestController
@RequestMapping(value = "/comment")
public class CommentController {

    @Autowired
    ICommentService commentService;
    @Autowired
    IVideoService videoService;

    @RequestMapping(value = "/addComment", method = RequestMethod.POST)
    private Result addComment(HttpServletRequest request, @RequestParam("videoId") String videoId,
                              @RequestParam("content") String content) {
        Video video = videoService.findVideoById(videoId);
        if (video == null) {
            log.info("[CommentController] addComment 视频不存在 videoId {}", videoId);
            return Result.failed(500, "视频不存在");
        }
        String userId = Utils.getUserIdFromToken(request.getHeader("token"));
        Comment comment = new Comment();
        String commentId = RandomStringUtils.randomNumeric(11);
        comment.setId(commentId);
        comment.setUserId(userId);
        comment.setVideoId(videoId);
        comment.setContent(content);
        comment.setTimestamp(System.currentTimeMillis());
        commentService.addComment(comment);
        log.info("[CommentController] addComment 用户添加评论成功 userId {} videoId {} commentId {}", userId, videoId, commentId);
        return Result.success();
    }

    @RequestMapping(value = "/getComments", method = RequestMethod.GET)
    private Result getComments(@RequestParam("videoId") String videoId, @RequestParam(name = "pageNum") Integer pageNum,
                               @RequestParam(name = "pageSize") Integer pageSize) {
        Video video = videoService.findVideoById(videoId);
        if (video == null) {
            log.info("[CommentController] getComments 视频不存在 videoId {}", videoId);
            return Result.failed(500, "视频不存在");
        }
        pageNum *= pageSize;
        List<Comment> comments = commentService.findCommentsByVideoId(videoId, pageNum, pageSize);
        log.info("[CommentController] getComments 获取视频评论成功 videoId {} pageNum {} pageSize {}", videoId, pageNum, pageSize);
        return Result.success(comments);
    }

    @RequestMapping(value = "/getVideoCommentCount", method = RequestMethod.GET)
    private Result getVideoCommentCount(@RequestParam("videoId") String videoId) {
        Video video = videoService.findVideoById(videoId);
        if (video == null) {
            log.info("[CommentController] getVideoCommentCount 视频不存在 videoId {}", videoId);
            return Result.failed(500, "视频不存在");
        }
        List<Comment> comments = commentService.findComments(videoId);
        log.info("[CommentController] getVideoCommentCount 获取视频评论数成功 videoId {} commentCount {}", videoId, comments.size());
        return Result.success(comments.size());
    }
}
