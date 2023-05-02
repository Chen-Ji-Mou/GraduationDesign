package com.graduationdesign.backend.service.impl;

import com.graduationdesign.backend.entity.Refund;
import com.graduationdesign.backend.mapper.RefundMapper;
import com.graduationdesign.backend.service.IRefundService;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.List;

@Service
public class RefundServiceImpl implements IRefundService {

    @Resource
    RefundMapper mapper;

    @Override
    public void addRefund(Refund refund) {
        mapper.addRefund(refund);
    }

    @Override
    public Refund findRefundsByOrderId(String orderId) {
        return mapper.findRefundsByOrderId(orderId);
    }

    @Override
    public void updateStatusById(String id, Boolean status) {
        mapper.updateStatusById(id, status);
    }

    @Override
    public Refund findRefundById(String id) {
        return mapper.findRefundById(id);
    }
}
