package com.graduationdesign.backend.mapper;

import com.graduationdesign.backend.entity.Detailed;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface DetailedMapper {
    @Insert("INSERT INTO detailed(id, userId, income, expenditure, timestamp) VALUES(#{id}, #{userId}, #{income}, #{expenditure}, #{timestamp})")
    void addDetailed(Detailed detailed);

    @Select("SELECT * FROM detailed WHERE userId=#{userId} limit #{pageNum},#{pageSize}")
    List<Detailed> getDetailed(@Param("userId") String userId, @Param("pageNum") Integer pageNum, @Param("pageSize") Integer pageSize);

    @Select("SELECT sum(income) as income FROM detailed WHERE userId=#{userId}")
    Detailed sumIncome(String userId);

    @Select("SELECT sum(expenditure) as expenditure FROM detailed WHERE userId=#{userId}")
    Detailed sumExpenditure(String userId);
}
