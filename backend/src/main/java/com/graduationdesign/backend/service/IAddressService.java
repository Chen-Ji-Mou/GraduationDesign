package com.graduationdesign.backend.service;

import com.graduationdesign.backend.entity.Address;
import java.util.List;

public interface IAddressService {
    void addAddress(Address address);
    Address findAddressById(String id);
    List<Address> findAddressesByUserId(String userId);
    void updateAddressById(String id, Address address);
    void deleteAddressById(String id);
}
