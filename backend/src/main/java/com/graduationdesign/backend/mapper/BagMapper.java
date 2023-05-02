package com.graduationdesign.backend.mapper;

import com.graduationdesign.backend.entity.Bag;
import org.apache.ibatis.annotations.*;

import java.util.List;

@Mapper
public interface BagMapper {
    @Select("SELECT * FROM bag WHERE userId=#{userId}")
    List<Bag> findBagsByUserId(String userId);

    @Select("SELECT * FROM bag WHERE userId=#{userId} AND giftId=#{giftId}")
    Bag findBagByUserIdAndGiftId(@Param("userId") String userId, @Param("giftId") String giftId);

    @Insert("INSERT INTO bag(id, userId, giftId, number) VALUES(#{id}, #{userId}, #{giftId}, #{number})")
    void addBag(Bag bag);

    @Update("UPDATE bag SET number=#{number} WHERE userId=#{userId} AND giftId=#{giftId}")
    void updateNumberByUserIdAndGiftId(@Param("userId") String userId, @Param("giftId") String giftId, @Param("number") Integer number);
}
