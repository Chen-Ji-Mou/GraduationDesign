package com.graduationdesign.backend.service.impl;

import com.graduationdesign.backend.entity.Enterprise;
import com.graduationdesign.backend.mapper.EnterpriseMapper;
import com.graduationdesign.backend.service.IEnterpriseService;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;

@Service
public class EnterpriseServiceImpl implements IEnterpriseService {
    @Resource
    EnterpriseMapper mapper;

    @Override
    public void addEnterprise(Enterprise enterprise) {
        mapper.addEnterprise(enterprise);
    }
}
