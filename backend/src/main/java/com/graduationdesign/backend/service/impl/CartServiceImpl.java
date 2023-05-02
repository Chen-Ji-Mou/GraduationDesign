package com.graduationdesign.backend.service.impl;

import com.graduationdesign.backend.entity.Cart;
import com.graduationdesign.backend.mapper.CartMapper;
import com.graduationdesign.backend.service.ICartService;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.List;

@Service
public class CartServiceImpl implements ICartService {

    @Resource
    CartMapper mapper;

    @Override
    public void addCart(Cart cart) {
        mapper.addCart(cart);
    }

    @Override
    public List<Cart> findCartsByUserId(String userId) {
        return mapper.findCartsByUserId(userId);
    }

    @Override
    public Cart findCartById(String id) {
        return mapper.findCartById(id);
    }

    @Override
    public void deleteCartById(String id) {
        mapper.deleteCartById(id);
    }

    @Override
    public Cart findCartByUserIdAndProductId(String userId, String productId) {
        return mapper.findCartByUserIdAndProductId(userId, productId);
    }

    @Override
    public void updateNumberById(String id, Integer number) {
        mapper.updateNumberById(id, number);
    }
}
