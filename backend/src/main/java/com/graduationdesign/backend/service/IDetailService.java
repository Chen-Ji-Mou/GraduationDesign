package com.graduationdesign.backend.service;

import com.graduationdesign.backend.entity.Detail;
import java.util.List;

public interface IDetailService {
    void addDetail(Detail detail);
    List<Detail> getDetails(String userId, Integer pageNum, Integer pageSize);
    Detail sumIncome(String userId);
    Detail sumExpenditure(String userId);
}
