package com.graduationdesign.backend.controller;

import com.graduationdesign.backend.Result;
import com.graduationdesign.backend.Utils;
import com.graduationdesign.backend.entity.Address;
import com.graduationdesign.backend.entity.Enterprise;
import com.graduationdesign.backend.entity.Order;
import com.graduationdesign.backend.entity.Product;
import com.graduationdesign.backend.service.IAddressService;
import com.graduationdesign.backend.service.IEnterpriseService;
import com.graduationdesign.backend.service.IOrderService;
import com.graduationdesign.backend.service.IProductService;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.RandomStringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import javax.servlet.http.HttpServletRequest;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

@Slf4j
@RestController
@RequestMapping(value = "/order")
public class OrderController {

    @Autowired
    IOrderService orderService;
    @Autowired
    IAddressService addressService;
    @Autowired
    IEnterpriseService enterpriseService;
    @Autowired
    IProductService productService;

    @RequestMapping(value = "/addOrder", method = RequestMethod.POST)
    private Result addOrder(@RequestParam("addressId") String addressId, @RequestParam("productId") String productId,
                            @RequestParam("number") Integer number) {
        Address address = addressService.findAddressById(addressId);
        if (address == null) {
            log.info("[OrderController] addOrder 用户地址不存在 addressId {}", addressId);
            return Result.failed(500, "用户地址不存在");
        }
        Product product = productService.findProductById(productId);
        if (product == null) {
            log.info("[OrderController] addOrder 商家产品不存在 productId {}", productId);
            return Result.failed(500, "商家产品不存在");
        }
        if (!product.getStatus()) {
            log.info("[OrderController] addOrder 该产品已下架 productId {}", productId);
            return Result.failed(500, "该产品已下架");
        }
        if (product.getInventory() <= 0 || product.getInventory() - number < 0) {
            log.info("[OrderController] addOrder 该产品库存已不足 productId {}", productId);
            return Result.failed(500, "该产品库存已不足");
        }
        Order order = new Order();
        String orderId = RandomStringUtils.randomNumeric(11);
        order.setId(orderId);
        order.setAddressId(addressId);
        order.setProductId(productId);
        order.setNumber(number);
        order.setStatus(0);
        order.setTimestamp(System.currentTimeMillis());
        orderService.addOrder(order);
        log.info("[OrderController] addOrder 新增订单成功 orderId {}", orderId);
        return Result.success();
    }

    @RequestMapping(value = "/getUserOrders", method = RequestMethod.GET)
    private Result getUserOrders(HttpServletRequest request, @RequestParam("pageNum") Integer pageNum,
                                 @RequestParam("pageSize") Integer pageSize) {
        pageNum *= pageSize;
        String userId = Utils.getUserIdFromToken(request.getHeader("token"));
        List<Order> orders = new ArrayList<>();
        List<Address> addresses = addressService.findAddressesByUserId(userId);
        for (Address address : addresses) {
            orders.addAll(orderService.findOrdersByAddressId(address.getId()));
        }
        Collections.sort(orders);
        orders = orders.subList(pageNum, pageSize);
        log.info("[OrderController] getUserOrders 获取用户订单列表成功 userId {} pageNum {} pageSize {}", userId, pageNum, pageSize);
        return Result.success(orders);
    }

    @RequestMapping(value = "/getEnterpriseOrders", method = RequestMethod.GET)
    private Result getEnterpriseOrders(@RequestParam("enterpriseId") String enterpriseId,
                                       @RequestParam("pageNum") Integer pageNum,
                                       @RequestParam("pageSize") Integer pageSize) {
        Enterprise enterprise = enterpriseService.findEnterpriseById(enterpriseId);
        if (enterprise == null) {
            log.info("[OrderController] getEnterpriseOrders 商家不存在 enterpriseId {}", enterpriseId);
            return Result.failed(500, "商家不存在");
        }
        pageNum *= pageSize;
        List<Order> orders = new ArrayList<>();
        List<Product> products = productService.findProductsByEnterpriseId(enterpriseId);
        for (Product product : products) {
            orders.addAll(orderService.findOrdersByProductId(product.getId()));
        }
        Collections.sort(orders);
        orders = orders.subList(pageNum, pageSize);
        log.info("[OrderController] getEnterpriseOrders 获取商家订单列表成功 enterpriseId {} pageNum {} pageSize {}", enterpriseId, pageNum, pageSize);
        return Result.success(orders);
    }

    @RequestMapping(value = "/updateOrderStatus", method = RequestMethod.POST)
    private Result updateOrderStatus(@RequestParam("orderId") String orderId, @RequestParam("status") Integer status) {
        Order order = orderService.findOrderById(orderId);
        if (order == null) {
            log.info("[OrderController] updateOrderStatus 订单不存在 orderId {}", orderId);
            return Result.failed(500, "订单不存在");
        }
        orderService.updateStatusById(orderId, status);
        log.info("[OrderController] updateOrderStatus 订单状态修改成功 orderId {}", orderId);
        return Result.success();
    }
}
