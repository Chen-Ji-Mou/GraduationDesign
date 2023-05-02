package com.graduationdesign.backend.mapper;

import com.graduationdesign.backend.entity.Enterprise;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

@Mapper
public interface EnterpriseMapper {
    @Insert("INSERT INTO enterprise(id, userId, code, licenseUrl) VALUES(#{id}, #{userId}, #{code}, #{licenseUrl})")
    void addEnterprise(Enterprise enterprise);

    @Select("SELECT * FROM enterprise WHERE userId=#{userId}")
    Enterprise findEnterpriseByUserId(String userId);

    @Select("SELECT * FROM enterprise WHERE id=#{id}")
    Enterprise findEnterpriseById(String id);
}
