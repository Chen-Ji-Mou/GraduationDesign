package com.graduationdesign.backend.entity;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Bag {
    private String id;
    private String userId;
    private String giftId;
    private Integer number;
}
