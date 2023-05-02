package com.graduationdesign.backend.service;

import com.graduationdesign.backend.entity.Live;

import java.util.List;

public interface ILiveService {
    void addLive(Live live);
    void updateStatusById(String id, Boolean status);
    Live findLiveByUserId(String userId);
    List<Live> findLives(Integer pageNum, Integer pageSize);
    Live findLiveById(String id);
    Integer updateNumberById(String id, Boolean increase);
    void updateCoverUrlById(String id, String coverUrl);
}
