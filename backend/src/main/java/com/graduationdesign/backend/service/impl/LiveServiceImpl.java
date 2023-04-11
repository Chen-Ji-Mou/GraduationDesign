package com.graduationdesign.backend.service.impl;

import com.graduationdesign.backend.entity.Live;
import com.graduationdesign.backend.mapper.LiveMapper;
import com.graduationdesign.backend.service.ILiveService;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.List;

@Service
public class LiveServiceImpl implements ILiveService {
    @Resource
    private LiveMapper mapper;

    @Override
    public void addLive(Live live) {
        mapper.addLive(live);
    }

    @Override
    public void updateLiveStatusById(String id, Boolean status) {
        mapper.updateLiveStatusById(id, status);
    }

    @Override
    public Live findLiveByUserId(String userId) {
        return mapper.getLiveByUserId(userId);
    }

    @Override
    public List<Live> getLives(Integer pageNum, Integer pageSize) {
        return mapper.getLives(pageNum, pageSize);
    }
}
