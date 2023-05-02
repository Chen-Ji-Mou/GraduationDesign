package com.graduationdesign.backend.controller;

import com.graduationdesign.backend.Result;
import com.graduationdesign.backend.Utils;
import com.graduationdesign.backend.entity.Address;
import com.graduationdesign.backend.service.IAddressService;
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
@RequestMapping(value = "/address")
public class AddressController {

    @Autowired
    IAddressService addressService;

    @RequestMapping(value = "/addAddress", method = RequestMethod.POST)
    private Result addAddress(HttpServletRequest request, @RequestParam("name") String name,
                                 @RequestParam("phone") String phone, @RequestParam("area") String area,
                                 @RequestParam("fullAddress") String fullAddress) {
        String userId = Utils.getUserIdFromToken(request.getHeader("token"));
        Address address = new Address();
        String addressId = RandomStringUtils.randomNumeric(11);
        address.setId(addressId);
        address.setUserId(userId);
        address.setName(name);
        address.setPhone(phone);
        address.setArea(area);
        address.setFullAddress(fullAddress);
        addressService.addAddress(address);
        log.info("[AddressController] addAddress 用户地址添加成功 userId {} addressId {}", userId, addressId);
        return Result.success();
    }

    @RequestMapping(value = "/getAddresses", method = RequestMethod.GET)
    private Result getAddresses(HttpServletRequest request) {
        String userId = Utils.getUserIdFromToken(request.getHeader("token"));
        List<Address> addresses = addressService.findAddressesByUserId(userId);
        log.info("[AddressController] getAddresses 获取用户地址列表成功 userId {}", userId);
        return Result.success(addresses);
    }

    @RequestMapping(value = "/updateAddress", method = RequestMethod.POST)
    private Result updateAddress(HttpServletRequest request, @RequestParam("addressId") String addressId,
                                 @RequestParam("name") String name, @RequestParam("phone") String phone,
                                 @RequestParam("area") String area, @RequestParam("fullAddress") String fullAddress) {
        String userId = Utils.getUserIdFromToken(request.getHeader("token"));
        Address address = addressService.findAddressById(addressId);
        if (address == null) {
            log.info("[AddressController] updateAddress 用户地址不存在 userId {} addressId {}", userId, addressId);
            return Result.failed(500, "用户地址不存在");
        }
        address.setName(name);
        address.setPhone(phone);
        address.setArea(area);
        address.setFullAddress(fullAddress);
        addressService.updateAddressById(addressId, address);
        log.info("[AddressController] updateAddress 用户地址修改成功 userId {} address {}", userId, address);
        return Result.success();
    }

    @RequestMapping(value = "/deleteAddress", method = RequestMethod.POST)
    private Result deleteAddress(HttpServletRequest request, @RequestParam("addressId") String addressId) {
        String userId = Utils.getUserIdFromToken(request.getHeader("token"));
        Address address = addressService.findAddressById(addressId);
        if (address == null) {
            log.info("[AddressController] deleteAddress 用户地址不存在 userId {} addressId {}", userId, addressId);
            return Result.failed(500, "用户地址不存在");
        }
        addressService.deleteAddressById(addressId);
        log.info("[AddressController] deleteAddress 用户地址删除成功 userId {} addressId {}", userId, addressId);
        return Result.success();
    }
}
