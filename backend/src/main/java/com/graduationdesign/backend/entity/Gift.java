package com.graduationdesign.backend.entity;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.HashMap;
import java.util.Map;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Gift {
    private String id;
    private String name;
    private Integer backgroundColor;
    private Integer titleColor;
    private Integer price;

    public Map<String, Object> toJsonMap() {
        Map<String, Object> jsonMap = new HashMap<>();
        jsonMap.put("id", id);
        jsonMap.put("name", name);
        jsonMap.put("backgroundColor", backgroundColor);
        jsonMap.put("titleColor", titleColor);
        jsonMap.put("price", price);
        return jsonMap;
    }
}
