package com.graduationdesign.backend.service;

import com.graduationdesign.backend.entity.Cart;
import java.util.List;

public interface ICartService {
    void addCart(Cart cart);
    List<Cart> findCartsByUserId(String userId);
    Cart findCartById(String id);
    void deleteCartById(String id);
    Cart findCartByUserIdAndProductId(String userId, String productId);
    void updateNumberById(String id, Integer number);
}
