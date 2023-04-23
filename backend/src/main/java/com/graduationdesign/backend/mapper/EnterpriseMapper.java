package com.graduationdesign.backend.mapper;

import com.graduationdesign.backend.entity.Enterprise;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface EnterpriseMapper {
    @Insert("INSERT INTO enterprise(id, code, licenseUrl) VALUES(#{id}, #{code}, #{licenseUrl})")
    void addEnterprise(Enterprise enterprise);
}
