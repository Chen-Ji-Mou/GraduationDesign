package com.graduationdesign.backend.service.impl;

import com.graduationdesign.backend.entity.Bag;
import com.graduationdesign.backend.mapper.BagMapper;
import com.graduationdesign.backend.service.IBagService;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.List;

@Service
public class BagServiceImpl implements IBagService {
    @Resource
    BagMapper mapper;

    @Override
    public List<Bag> getUserBags(String userId) {
        return mapper.getUserBags(userId);
    }

    @Override
    public Bag getBag(String userId, String giftId) {
        return mapper.getBag(userId, giftId);
    }

    @Override
    public void addBag(Bag bag) {
        mapper.addBag(bag);
    }

    @Override
    public void updateBag(String userId, String giftId, Integer number) {
        mapper.updateBag(userId, giftId, number);
    }
}
