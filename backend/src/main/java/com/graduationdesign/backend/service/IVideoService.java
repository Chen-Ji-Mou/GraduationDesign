package com.graduationdesign.backend.service;

import com.graduationdesign.backend.entity.Video;
import java.util.List;

public interface IVideoService {
    void addVideo(Video video);
    List<Video> findVideos(Integer pageNum, Integer pageSize);
    Video findVideoByFileName(String name);
    void deleteVideoByFileName(String name);
    Video findVideoById(String id);
    void updateShareCountById(String id, Integer shareCount);
}
