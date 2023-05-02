package com.graduationdesign.backend.service.impl;

import com.graduationdesign.backend.entity.Gift;
import com.graduationdesign.backend.mapper.GiftMapper;
import com.graduationdesign.backend.service.IGiftService;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.List;

@Service
public class GiftServiceImpl implements IGiftService {
    @Resource
    GiftMapper mapper;

    @Override
    public void addGift(Gift gift) {
        mapper.addGift(gift);
    }

    @Override
    public Gift findGiftById(String id) {
        return mapper.findGiftById(id);
    }

    @Override
    public List<Gift> findGifts() {
        return mapper.findGifts();
    }
}
