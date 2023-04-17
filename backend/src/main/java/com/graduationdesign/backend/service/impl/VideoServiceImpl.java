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
    public List<Video> getVideos(Integer pageNum, Integer pageSize) {
        return mapper.getVideos(pageNum, pageSize);
    }

    @Override
    public Video getVideo(String name) {
        return mapper.getVideo(name);
    }

    @Override
    public void deleteVideo(String name) {
        mapper.deleteVideo(name);
    }
}
