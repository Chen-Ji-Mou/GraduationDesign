package com.graduationdesign.backend.entity;

import lombok.Data;

@Data
public class User {
    private Integer id;
    private String name;
    private String pwd;
    private String email;
}
