package com.graduationdesign.backend.service.impl;

import com.graduationdesign.backend.entity.Detail;
import com.graduationdesign.backend.mapper.DetailMapper;
import com.graduationdesign.backend.service.IDetailService;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.List;

@Service
public class DetailServiceImpl implements IDetailService {
    @Resource
    DetailMapper mapper;

    @Override
    public void addDetail(Detail detail) {
        mapper.addDetail(detail);
    }

    @Override
    public List<Detail> getDetails(String userId, Integer pageNum, Integer pageSize) {
        return mapper.getDetails(userId, pageNum, pageSize);
    }

    @Override
    public Detail sumIncome(String userId) {
        return mapper.sumIncome(userId);
    }

    @Override
    public Detail sumExpenditure(String userId) {
        return mapper.sumExpenditure(userId);
    }
}
