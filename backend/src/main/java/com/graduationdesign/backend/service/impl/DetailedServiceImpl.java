package com.graduationdesign.backend.service.impl;

import com.graduationdesign.backend.entity.Detailed;
import com.graduationdesign.backend.mapper.DetailedMapper;
import com.graduationdesign.backend.service.IDetailedService;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.List;

@Service
public class DetailedServiceImpl implements IDetailedService {
    @Resource
    DetailedMapper mapper;

    @Override
    public void addDetailed(Detailed detailed) {
        mapper.addDetailed(detailed);
    }

    @Override
    public List<Detailed> getDetailed(String userId, Integer pageNum, Integer pageSize) {
        return mapper.getDetailed(userId, pageNum, pageSize);
    }

    @Override
    public Detailed sumIncome(String userId) {
        return mapper.sumIncome(userId);
    }

    @Override
    public Detailed sumExpenditure(String userId) {
        return mapper.sumExpenditure(userId);
    }
}
