package com.graduationdesign.backend.mapper;

import com.graduationdesign.backend.entity.Cart;
import org.apache.ibatis.annotations.*;
import java.util.List;

@Mapper
public interface CartMapper {
    @Insert("INSERT INTO cart(id, userId, productId, number) VALUES(#{id}, #{userId}, #{productId}, #{number})")
    void addCart(Cart cart);

    @Select("SELECT * FROM cart WHERE userId=#{userId}")
    List<Cart> findCartsByUserId(String userId);

    @Select("SELECT * FROM cart WHERE id=#{id}")
    Cart findCartById(String id);

    @Delete("DELETE FROM cart WHERE id=#{id}")
    void deleteCartById(String id);

    @Select("SELECT * FROM cart WHERE userId=#{userId} AND productId=#{productId}")
    Cart findCartByUserIdAndProductId(@Param("userId") String userId, @Param("productId") String productId);

    @Update("UPDATE cart SET number=#{number} WHERE id=#{id}")
    void updateNumberById(@Param("id") String id, @Param("number") Integer number);
}
