package com.graduationdesign.backend.mapper;

import com.graduationdesign.backend.entity.Refund;
import org.apache.ibatis.annotations.*;

import java.util.List;

@Mapper
public interface RefundMapper {
    @Insert("INSERT INTO refund(id, orderId, status, timestamp) VALUES(#{id}, #{orderId}, #{status}, #{timestamp})")
    void addRefund(Refund refund);

    @Select("SELECT * FROM refund WHERE orderId=#{orderId}")
    Refund findRefundsByOrderId(String orderId);

    @Update("UPDATE refund SET status=#{status} WHERE id=#{id}")
    void updateStatusById(@Param("id") String id, @Param("status") Boolean status);

    @Select("SELECT * FROM refund WHERE id=#{id}")
    Refund findRefundById(String id);
}
