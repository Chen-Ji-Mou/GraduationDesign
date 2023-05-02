package com.graduationdesign.backend.entity;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Order implements Comparable<Order> {
    private String id;
    private String addressId;
    private String productId;
    private Integer number;
    private Integer status;
    private Long timestamp;

    @Override
    public int compareTo(Order other) {
        return (int) (other.getTimestamp() - this.getTimestamp());
    }
}
