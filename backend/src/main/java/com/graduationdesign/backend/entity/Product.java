package com.graduationdesign.backend.entity;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.lang.Nullable;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Product {
    private String id;
    private String enterpriseId;
    private String name;
    @Nullable
    private String coverUrl;
    @Nullable
    private String desc;
    private Boolean status;
    private Integer inventory;
}
