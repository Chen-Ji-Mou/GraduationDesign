package com.graduationdesign.backend.controller;

import com.graduationdesign.backend.Result;
import com.graduationdesign.backend.Utils;
import com.graduationdesign.backend.entity.Cart;
import com.graduationdesign.backend.service.ICartService;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.RandomStringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import javax.servlet.http.HttpServletRequest;
import java.util.List;

@Slf4j
@RestController
@RequestMapping(value = "/cart")
public class CartController {

    @Autowired
    ICartService cartService;

    @RequestMapping(value = "/addCart", method = RequestMethod.POST)
    private Result addCart(HttpServletRequest request, @RequestParam("productId") String productId,
                           @RequestParam("number") Integer number) {
        String userId = Utils.getUserIdFromToken(request.getHeader("token"));
        Cart cart = cartService.findCartByUserIdAndProductId(userId, productId);
        if (cart == null) {
            cart = new Cart();
            String cartId = RandomStringUtils.randomNumeric(11);
            cart.setId(cartId);
            cart.setUserId(userId);
            cart.setProductId(productId);
            cart.setNumber(number);
            cartService.addCart(cart);
            log.info("[CartController] addCart 用户购物车添加成功 userId {} cartId {}", userId, cartId);
        } else {
            String cartId = cart.getId();
            Integer curNumber = cart.getNumber();
            curNumber += number;
            cartService.updateNumberById(cartId, curNumber);
            log.info("[CartController] addCart 用户购物车添加成功 userId {} cartId {}", userId, cartId);
        }
        return Result.success();
    }

    @RequestMapping(value = "/getCarts", method = RequestMethod.GET)
    private Result getCarts(HttpServletRequest request) {
        String userId = Utils.getUserIdFromToken(request.getHeader("token"));
        List<Cart> carts = cartService.findCartsByUserId(userId);
        log.info("[CartController] getCarts 获取用户购物车列表成功 userId {} carts {}", userId, carts);
        return Result.success(carts);
    }

    @RequestMapping(value = "/deleteCart", method = RequestMethod.POST)
    private Result deleteCart(HttpServletRequest request, @RequestParam("cartId") String cartId) {
        String userId = Utils.getUserIdFromToken(request.getHeader("token"));
        Cart cart = cartService.findCartById(cartId);
        if (cart == null) {
            log.info("[CartController] deleteCart 用户购物车项不存在 userId {} cartId {}", userId, cartId);
            return Result.failed(500, "用户购物车项不存在");
        }
        cartService.deleteCartById(cartId);
        log.info("[CartController] deleteCart 用户购物车项删除成功 userId {} cartId {}", userId, cartId);
        return Result.success();
    }
}
