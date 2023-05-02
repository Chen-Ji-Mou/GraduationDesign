package com.graduationdesign.backend.entity;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Refund implements Comparable<Refund> {
    private String id;
    private String orderId;
    private Boolean status;
    private Long timestamp;

    @Override
    public int compareTo(Refund other) {
        return (int) (other.getTimestamp() - this.getTimestamp());
    }
}
