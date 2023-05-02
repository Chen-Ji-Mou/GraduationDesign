package com.graduationdesign.backend.entity;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.lang.Nullable;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Live {
    private String id;
    private String userId;
    private Boolean status;
    private Integer number;
    @Nullable
    private String coverUrl;
}
