package org.example.springboot.enumClass;

import lombok.Getter;

@Getter
public enum UserRole {
    ADMIN(1, "管理员"),
    USER(2, "用户");

    private final Integer value;
    private final String label;

    UserRole(Integer value, String label) {
        this.value = value;
        this.label = label;
    }
}
