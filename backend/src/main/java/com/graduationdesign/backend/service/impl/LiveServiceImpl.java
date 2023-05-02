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
    public void updateStatusById(String id, Boolean status) {
        mapper.updateStatusById(id, status);
    }

    @Override
    public Live findLiveByUserId(String userId) {
        return mapper.findLiveByUserId(userId);
    }

    @Override
    public List<Live> findLives(Integer pageNum, Integer pageSize) {
        return mapper.findLives(pageNum, pageSize);
    }

    @Override
    public Integer updateNumberById(String id, Boolean increase) {
        Live live = mapper.findLiveById(id);
        Integer curNumber = live.getNumber();
        if (increase) {
            curNumber++;
        } else {
            curNumber--;
        }
        mapper.updateNumberById(id, curNumber);
        return curNumber;
    }

    @Override
    public Live findLiveById(String id) {
        return mapper.findLiveById(id);
    }

    @Override
    public void updateCoverUrlById(String id, String coverUrl) {
        mapper.updateCoverUrlById(id, coverUrl);
    }
}
