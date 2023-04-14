package com.graduationdesign.backend.mapper;

import com.graduationdesign.backend.entity.Bag;
import org.apache.ibatis.annotations.*;

import java.util.List;

@Mapper
public interface BagMapper {
    @Select("SELECT * FROM bag WHERE userId=#{userId}")
    List<Bag> getUserBags(String userId);

    @Select("SELECT * FROM bag WHERE userId=#{userId} AND giftId=#{giftId}")
    Bag getBag(@Param("userId") String userId, @Param("giftId") String giftId);

    @Insert("INSERT INTO bag(id, userId, giftId, number) VALUES(#{id}, #{userId}, #{giftId}, #{number})")
    void addBag(Bag bag);

    @Update("UPDATE bag SET number=#{number} WHERE userId=#{userId} AND giftId=#{giftId}")
    void updateBag(@Param("userId") String userId, @Param("giftId") String giftId, @Param("number") Integer number);
}
