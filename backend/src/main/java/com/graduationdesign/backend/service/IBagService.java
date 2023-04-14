package com.graduationdesign.backend.service;

import com.graduationdesign.backend.entity.Bag;
import java.util.List;

public interface IBagService {
    List<Bag> getUserBags(String userId);
    Bag getBag(String userId, String giftId);
    void addBag(Bag bag);
    void updateBag(String userId, String giftId, Integer number);
}
