package com.graduationdesign.backend.mapper;

import com.graduationdesign.backend.entity.Detailed;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface DetailedMapper {
    @Insert("INSERT INTO detailed(id, userId, income, expenditure) VALUES(#{id}, #{userId}, #{income}, #{expenditure})")
    void addDetailed(Detailed detailed);

    @Select("SELECT * FROM detailed WHERE userId=#{userId} limit #{pageNum},#{pageSize}")
    List<Detailed> getDetailed(@Param("userId") String userId, @Param("pageNum") Integer pageNum, @Param("pageSize") Integer pageSize);
}
