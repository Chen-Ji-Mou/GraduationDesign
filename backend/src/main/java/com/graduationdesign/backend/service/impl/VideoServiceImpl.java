package com.graduationdesign.backend.service.impl;

import com.graduationdesign.backend.entity.Video;
import com.graduationdesign.backend.mapper.VideoMapper;
import com.graduationdesign.backend.service.IVideoService;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.List;

@Service
public class VideoServiceImpl implements IVideoService {
    @Resource
    VideoMapper mapper;

    @Override
    public void addVideo(Video video) {
        mapper.addVideo(video);
    }

    @Override
    public List<Video> findVideos(Integer pageNum, Integer pageSize) {
        return mapper.findVideos(pageNum, pageSize);
    }

    @Override
    public Video findVideoByFileName(String name) {
        return mapper.findVideoByFileName(name);
    }

    @Override
    public void deleteVideoByFileName(String name) {
        mapper.deleteVideoByFileName(name);
    }

    @Override
    public Video findVideoById(String id) {
        return mapper.findVideoById(id);
    }

    @Override
    public void updateShareCountById(String id, Integer shareCount) {
        mapper.updateShareCountById(id, shareCount);
    }
}
