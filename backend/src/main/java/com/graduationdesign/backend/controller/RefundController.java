package com.graduationdesign.backend.controller;

import com.graduationdesign.backend.Result;
import com.graduationdesign.backend.Utils;
import com.graduationdesign.backend.entity.*;
import com.graduationdesign.backend.service.*;
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
@RequestMapping(value = "/refund")
public class RefundController {

    @Autowired
    IRefundService refundService;
    @Autowired
    IOrderService orderService;
    @Autowired
    IAddressService addressService;
    @Autowired
    IEnterpriseService enterpriseService;
    @Autowired
    IProductService productService;

    @RequestMapping(value = "/addRefund", method = RequestMethod.POST)
    private Result addRefund(@RequestParam("orderId") String orderId) {
        Order order = orderService.findOrderById(orderId);
        if (order == null) {
            log.info("[RefundController] addRefund 订单不存在 orderId {}", orderId);
            return Result.failed(500, "订单不存在");
        }
        Refund refund = new Refund();
        String refundId = RandomStringUtils.randomNumeric(11);
        refund.setId(refundId);
        refund.setOrderId(orderId);
        refund.setStatus(false);
        refund.setTimestamp(System.currentTimeMillis());
        refundService.addRefund(refund);
        log.info("[RefundController] addRefund 发起退款申请成功 orderId {} refundId {}", orderId, refundId);
        return Result.success();
    }

    @RequestMapping(value = "/getUserRefunds", method = RequestMethod.GET)
    private Result getUserRefunds(HttpServletRequest request, @RequestParam(name = "pageNum") Integer pageNum,
                                  @RequestParam(name = "pageSize") Integer pageSize) {
        pageNum *= pageSize;
        String userId = Utils.getUserIdFromToken(request.getHeader("token"));
        List<Refund> refunds = new ArrayList<>();
        List<Address> addresses = addressService.findAddressesByUserId(userId);
        for (Address address : addresses) {
            List<Order> orders = orderService.findOrdersByAddressId(address.getId());
            for (Order order : orders) {
                Refund refund = refundService.findRefundsByOrderId(order.getId());
                if (refund != null) {
                    refunds.add(refund);
                }
            }
        }
        Collections.sort(refunds);
        refunds = refunds.subList(pageNum, refunds.size() - pageNum > pageSize ? pageNum + pageSize : refunds.size());
        log.info("[RefundController] getUserRefunds 获取用户退款申请列表成功 userId {} pageNum {} pageSize {}", userId, pageNum, pageSize);
        return Result.success(refunds);
    }

    @RequestMapping(value = "/getEnterpriseRefunds", method = RequestMethod.GET)
    private Result getEnterpriseRefunds(@RequestParam("enterpriseId") String enterpriseId,
                                        @RequestParam(name = "pageNum") Integer pageNum,
                                        @RequestParam(name = "pageSize") Integer pageSize) {
        Enterprise enterprise = enterpriseService.findEnterpriseById(enterpriseId);
        if (enterprise == null) {
            log.info("[RefundController] getEnterpriseRefunds 商家不存在 enterpriseId {}", enterpriseId);
            return Result.failed(500, "商家不存在");
        }
        pageNum *= pageSize;
        List<Refund> refunds = new ArrayList<>();
        List<Product> products = productService.findProductsByEnterpriseId(enterpriseId);
        for (Product product : products) {
            List<Order> orders = orderService.findOrdersByProductId(product.getId());
            for (Order order : orders) {
                Refund refund = refundService.findRefundsByOrderId(order.getId());
                if (refund != null) {
                    refunds.add(refund);
                }
            }
        }
        Collections.sort(refunds);
        refunds = refunds.subList(pageNum, refunds.size() - pageNum > pageSize ? pageNum + pageSize : refunds.size());
        log.info("[RefundController] getUserRefunds 获取商家退款申请列表成功 enterpriseId {} pageNum {} pageSize {}", enterpriseId, pageNum, pageSize);
        return Result.success(refunds);
    }

    @RequestMapping(value = "/updateRefundStatus", method = RequestMethod.POST)
    private Result updateRefundStatus(@RequestParam("refundId") String refundId,
                                      @RequestParam("status") Boolean status) {
        Refund refund = refundService.findRefundById(refundId);
        if (refund == null) {
            log.info("[RefundController] updateRefundStatus 退款申请不存在 refundId {}", refundId);
            return Result.failed(500, "退款申请不存在");
        }
        refundService.updateStatusById(refundId, status);
        log.info("[RefundController] updateRefundStatus 修改退款申请状态成功 refundId {}", refundId);
        return Result.success();
    }
}
