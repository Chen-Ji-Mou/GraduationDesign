package com.graduationdesign.backend.service;

import com.graduationdesign.backend.entity.Bag;
import java.util.List;

public interface IBagService {
    List<Bag> findBagsByUserId(String userId);
    Bag findBagByUserIdAndGiftId(String userId, String giftId);
    void addBag(Bag bag);
    void updateNumberByUserIdAndGiftId(String userId, String giftId, Integer number);
}
