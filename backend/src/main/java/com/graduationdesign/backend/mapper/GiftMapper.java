package com.graduationdesign.backend.mapper;

import com.graduationdesign.backend.entity.Gift;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;
import java.util.List;

@Mapper
public interface GiftMapper {
    @Insert("INSERT INTO gift(id, name, backgroundColor, titleColor, price) VALUES(#{id}, #{name}, #{backgroundColor}, #{titleColor}, #{price})")
    void addGift(Gift gift);

    @Select("SELECT * FROM gift WHERE id=#{id}")
    Gift findGiftById(String id);

    @Select("SELECT * FROM gift")
    List<Gift> findGifts();
}
