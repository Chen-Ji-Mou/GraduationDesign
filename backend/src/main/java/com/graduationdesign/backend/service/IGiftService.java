package com.graduationdesign.backend.service;

import com.graduationdesign.backend.entity.Gift;
import java.util.List;

public interface IGiftService {
    void addGift(Gift gift);
    Gift findGiftById(String id);
    List<Gift> findGifts();
}
