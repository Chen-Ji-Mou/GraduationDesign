package com.graduationdesign.backend.service;

import com.graduationdesign.backend.entity.Video;

import java.util.List;

public interface IVideoService {
    void addVideo(Video video);
    List<Video> getVideos(Integer pageNum, Integer pageSize);
    Video getVideo(String name);
    void deleteVideo(String name);
}
