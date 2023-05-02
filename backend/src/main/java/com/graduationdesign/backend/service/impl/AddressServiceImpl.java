package com.graduationdesign.backend.service.impl;

import com.graduationdesign.backend.entity.Address;
import com.graduationdesign.backend.mapper.AddressMapper;
import com.graduationdesign.backend.service.IAddressService;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.List;

@Service
public class AddressServiceImpl implements IAddressService {

    @Resource
    AddressMapper mapper;

    @Override
    public void addAddress(Address address) {
        mapper.addAddress(address);
    }

    @Override
    public Address findAddressById(String id) {
        return mapper.findAddressById(id);
    }

    @Override
    public List<Address> findAddressesByUserId(String userId) {
        return mapper.findAddressesByUserId(userId);
    }

    @Override
    public void updateAddressById(String id, Address address) {
        mapper.updateAddressById(id, address);
    }

    @Override
    public void deleteAddressById(String id) {
        mapper.deleteAddressById(id);
    }
}
