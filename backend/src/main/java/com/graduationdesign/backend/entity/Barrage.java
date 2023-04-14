package com.graduationdesign.backend.entity;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.HashMap;
import java.util.Map;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Barrage {
    private String userName;
    private String content;
    private Gift gift;

    public Map<String, Object> toJsonMap() {
        Map<String, Object> jsonMap = new HashMap<>();
        jsonMap.put("userName", userName);
        jsonMap.put("content", content);
        jsonMap.put("gift", gift.toJsonMap());
        return jsonMap;
    }
}
