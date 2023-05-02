package com.graduationdesign.backend.service;

import com.graduationdesign.backend.entity.Enterprise;

public interface IEnterpriseService {
    void addEnterprise(Enterprise enterprise);
    Enterprise findEnterpriseByUserId(String userId);
    Enterprise findEnterpriseById(String id);
}
