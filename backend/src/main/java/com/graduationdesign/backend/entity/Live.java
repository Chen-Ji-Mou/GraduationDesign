package com.graduationdesign.backend.entity;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Live {
    private String id;
    private String userId;
    private Boolean ing;
    private Integer number;
}
