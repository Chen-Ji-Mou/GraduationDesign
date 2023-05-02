package com.graduationdesign.backend.service;

import com.graduationdesign.backend.entity.Refund;
import java.util.List;

public interface IRefundService {
    void addRefund(Refund refund);
    Refund findRefundsByOrderId(String orderId);
    void updateStatusById(String id, Boolean status);
    Refund findRefundById(String id);
}
