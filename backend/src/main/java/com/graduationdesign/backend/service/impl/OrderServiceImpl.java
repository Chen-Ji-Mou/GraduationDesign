package com.graduationdesign.backend.service.impl;

import com.graduationdesign.backend.entity.Order;
import com.graduationdesign.backend.mapper.OrderMapper;
import com.graduationdesign.backend.service.IOrderService;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.List;

@Service
public class OrderServiceImpl implements IOrderService {

    @Resource
    OrderMapper mapper;

    @Override
    public void addOrder(Order order) {
        mapper.addOrder(order);
    }

    @Override
    public List<Order> findOrdersByAddressId(String addressId) {
        return mapper.findOrdersByAddressId(addressId);
    }

    @Override
    public List<Order> findOrdersByProductId(String productId) {
        return mapper.findOrdersByProductId(productId);
    }

    @Override
    public void updateStatusById(String id, Integer status) {
        mapper.updateStatusById(id, status);
    }

    @Override
    public Order findOrderById(String id) {
        return mapper.findOrderById(id);
    }
}
