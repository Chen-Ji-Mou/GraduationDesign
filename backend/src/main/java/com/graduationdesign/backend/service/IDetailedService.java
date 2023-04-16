package com.graduationdesign.backend.service;

import com.graduationdesign.backend.entity.Detailed;
import java.util.List;

public interface IDetailedService {
    void addDetailed(Detailed detailed);
    List<Detailed> getDetailed(String userId, Integer pageNum, Integer pageSize);
    Detailed sumIncome(String userId);
    Detailed sumExpenditure(String userId);
}
