package com.graduationdesign.backend.entity;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Detailed {
    private String id;
    private String userId;
    private int income;
    private int expenditure;
}
