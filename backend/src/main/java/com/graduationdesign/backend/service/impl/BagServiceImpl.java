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
    public List<Bag> findBagsByUserId(String userId) {
        return mapper.findBagsByUserId(userId);
    }

    @Override
    public Bag findBagByUserIdAndGiftId(String userId, String giftId) {
        return mapper.findBagByUserIdAndGiftId(userId, giftId);
    }

    @Override
    public void addBag(Bag bag) {
        mapper.addBag(bag);
    }

    @Override
    public void updateNumberByUserIdAndGiftId(String userId, String giftId, Integer number) {
        mapper.updateNumberByUserIdAndGiftId(userId, giftId, number);
    }
}
