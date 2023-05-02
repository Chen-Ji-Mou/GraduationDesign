package com.graduationdesign.backend.mapper;

import com.graduationdesign.backend.entity.Address;
import org.apache.ibatis.annotations.*;
import java.util.List;

@Mapper
public interface AddressMapper {
    @Insert("INSERT INTO address(id, userId, name, phone, area, fullAddress) VALUES(#{id}, #{userId}, #{name}, #{phone}, #{area}, #{fullAddress})")
    void addAddress(Address address);

    @Select("SELECT * FROM address WHERE id=#{id}")
    Address findAddressById(String id);

    @Select("SELECT * FROM address WHERE userId=#{userId}")
    List<Address> findAddressesByUserId(String userId);

    @Update("UPDATE address SET name=#{address.name},phone=#{address.phone},area=#{address.area},fullAddress=#{address.fullAddress} WHERE id=#{id}")
    void updateAddressById(@Param("id") String id, @Param("address") Address address);

    @Delete("DELETE FROM address WHERE id=#{id}")
    void deleteAddressById(String id);
}
