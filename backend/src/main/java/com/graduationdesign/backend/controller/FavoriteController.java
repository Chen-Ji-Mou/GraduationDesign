package com.graduationdesign.backend.controller;

import com.graduationdesign.backend.Result;
import com.graduationdesign.backend.Utils;
import com.graduationdesign.backend.entity.Favorite;
import com.graduationdesign.backend.entity.Video;
import com.graduationdesign.backend.service.IFavoriteService;
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
@RequestMapping(value = "/favorite")
public class FavoriteController {

    @Autowired
    IFavoriteService favoriteService;
    @Autowired
    IVideoService videoService;

    @RequestMapping(value = "/addFavorite", method = RequestMethod.POST)
    private Result addFavorite(HttpServletRequest request, @RequestParam("videoId") String videoId) {
        Video video = videoService.findVideoById(videoId);
        if (video == null) {
            log.info("[FavoriteController] addFavorite 视频不存在 videoId {}", videoId);
            return Result.failed(500, "视频不存在");
        }
        String userId = Utils.getUserIdFromToken(request.getHeader("token"));
        Favorite favorite = new Favorite();
        String favoriteId = RandomStringUtils.randomNumeric(11);
        favorite.setId(favoriteId);
        favorite.setUserId(userId);
        favorite.setVideoId(videoId);
        favorite.setTimestamp(System.currentTimeMillis());
        favoriteService.addFavorite(favorite);
        log.info("[FavoriteController] addFavorite 用户收藏视频成功 userId {} videoId {}", userId, videoId);
        return Result.success();
    }

    @RequestMapping(value = "/getVideoFavoriteCount", method = RequestMethod.GET)
    private Result getVideoFavoriteCount(@RequestParam("videoId") String videoId) {
        Video video = videoService.findVideoById(videoId);
        if (video == null) {
            log.info("[FavoriteController] getVideoFavoriteCount 视频不存在 videoId {}", videoId);
            return Result.failed(500, "视频不存在");
        }
        List<Favorite> favorites = favoriteService.findFavoritesByVideoId(videoId);
        log.info("[FavoriteController] getVideoFavoriteCount 获取视频收藏数成功 videoId {} favoriteCount {}", videoId, favorites.size());
        return Result.success(favorites.size());
    }

    @RequestMapping(value = "/getUserFavorites", method = RequestMethod.GET)
    private Result getUserFavorites(HttpServletRequest request, @RequestParam("pageNum") Integer pageNum, @RequestParam("pageSize") Integer pageSize) {
        pageNum *= pageSize;
        String userId = Utils.getUserIdFromToken(request.getHeader("token"));
        List<Favorite> favorites = favoriteService.findFavoritesByUserId(userId, pageNum, pageSize);
        log.info("[FavoriteController] getUserFavorites 获取用户收藏视频列表成功 userId {} pageNum {} pageSize {}", userId, pageNum, pageSize);
        return Result.success(favorites);
    }

    @RequestMapping(value = "/deleteFavorite", method = RequestMethod.POST)
    private Result deleteFavorite(HttpServletRequest request, @RequestParam("videoId") String videoId) {
        String userId = Utils.getUserIdFromToken(request.getHeader("token"));
        Video video = videoService.findVideoById(videoId);
        if (video == null) {
            log.info("[FavoriteController] deleteFavorite 视频不存在 videoId {}", videoId);
            return Result.failed(500, "视频不存在");
        }
        favoriteService.deleteFavoriteByUserIdAndVideoId(userId, videoId);
        log.info("[FavoriteController] deleteFavorite 用户取消收藏成功 userId {} videoId {}", userId, videoId);
        return Result.success();
    }

    @RequestMapping(value = "/verifyVideoHasOwnFavorite", method = RequestMethod.GET)
    private Result verifyVideoHasOwnFavorite(HttpServletRequest request, @RequestParam("videoId") String videoId) {
        String userId = Utils.getUserIdFromToken(request.getHeader("token"));
        List<Favorite> favorites = favoriteService.findFavoritesByVideoId(videoId);
        boolean result = false;
        for (Favorite favorite : favorites) {
            if (favorite.getUserId().equals(userId)) {
                result = true;
                break;
            }
        }
        if (!result) {
            log.info("[FavoriteController] verifyVideoHasOwnFavorite 视频未被当前用户收藏 videoId {} userId {}", videoId, userId);
            return Result.failed(500, "视频未被当前用户收藏");
        }
        log.info("[FavoriteController] verifyVideoHasOwnFavorite 视频已被当前用户收藏 videoId {} userId {}", videoId, userId);
        return Result.success();
    }
}
