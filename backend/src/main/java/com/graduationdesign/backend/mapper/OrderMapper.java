package com.graduationdesign.backend.mapper;

import com.graduationdesign.backend.entity.Order;
import org.apache.ibatis.annotations.*;

import java.util.List;

@Mapper
public interface OrderMapper {
    @Insert("INSERT INTO order(id, addressId, productId, number, status, timestamp) VALUES(#{id}, #{addressId}, #{productId}, #{number}, #{status}, #{timestamp})")
    void addOrder(Order order);

    @Select("SELECT * FROM order WHERE addressId=#{addressId} ORDER BY timestamp DESC")
    List<Order> findOrdersByAddressId(String addressId);

    @Select("SELECT * FROM order WHERE productId=#{productId} ORDER BY timestamp DESC")
    List<Order> findOrdersByProductId(String productId);

    @Update("UPDATE order SET status=#{status} WHERE id=#{id}")
    void updateStatusById(@Param("id") String id, @Param("status") Integer status);

    @Select("SELECT * FROM order WHERE id=#{id}")
    Order findOrderById(String id);
}
