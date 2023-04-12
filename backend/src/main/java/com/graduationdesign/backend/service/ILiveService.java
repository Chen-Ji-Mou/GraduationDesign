package com.graduationdesign.backend.service;

import com.graduationdesign.backend.entity.Live;

import java.util.List;

public interface ILiveService {
    void addLive(Live live);
    void updateLiveStatusById(String id, Boolean status);
    Live findLiveByUserId(String userId);
    List<Live> getLives(Integer pageNum, Integer pageSize);
    Integer updateLiveNumberById(String id, Boolean increase);
    Live findLiveById(String id);
}
