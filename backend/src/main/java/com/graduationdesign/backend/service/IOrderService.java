package com.graduationdesign.backend.service;

import com.graduationdesign.backend.entity.Order;
import java.util.List;

public interface IOrderService {
    void addOrder(Order order);
    List<Order> findOrdersByAddressId(String addressId);
    List<Order> findOrdersByProductId(String productId);
    void updateStatusById(String id, Integer status);
    Order findOrderById(String id);
}
