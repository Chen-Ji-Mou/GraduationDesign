package com.graduationdesign.backend.entity;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Chat implements Comparable<Chat> {
    private String id;
    private String ownId;
    private String toId;
    private String content;
    private Long timestamp;

    @Override
    public int compareTo(Chat other) {
        return (int) (other.getTimestamp() - this.getTimestamp());
    }
}
