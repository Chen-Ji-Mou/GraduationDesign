package com.graduationdesign.backend.mapper;

import com.graduationdesign.backend.entity.Detail;
import org.apache.ibatis.annotations.*;
import java.util.List;

@Mapper
public interface DetailMapper {
    @Insert("INSERT INTO detail(id, userId, income, expenditure, timestamp) VALUES(#{id}, #{userId}, #{income}, #{expenditure}, #{timestamp})")
    void addDetail(Detail detail);

    @Select("SELECT * FROM detail WHERE userId=#{userId} ORDER BY timestamp DESC LIMIT #{pageNum},#{pageSize}")
    List<Detail> getDetails(@Param("userId") String userId, @Param("pageNum") Integer pageNum, @Param("pageSize") Integer pageSize);

    @Select("SELECT sum(income) as income FROM detail WHERE userId=#{userId}")
    Detail sumIncome(String userId);

    @Select("SELECT sum(expenditure) as expenditure FROM detail WHERE userId=#{userId}")
    Detail sumExpenditure(String userId);
}
