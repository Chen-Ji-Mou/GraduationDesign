package com.graduationdesign.backend;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 统一返回对象
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Result<T> {
    // 自定义状态码
    private Integer code;
    // 提示内容，如果接口出错，则存放异常信息
    private String msg;
    // 返回数据体
    private T data;

    /**
     * 请求成功返回
     */
    public static <T> Result<T> success() {
        return new Result<>(200, "success", null);
    }

    public static <T> Result<T> success(T data) {
        return new Result<>(200, "success", data);
    }

    /**
     * 请求失败返回
     *
     * @param msg: 错误原因
     */
    public static <T> Result<T> failed(Integer code, String msg) {
        return new Result<>(code, msg, null);
    }

    public static <T> Result<T> failed(Integer code, String msg, T data) {
        return new Result<>(code, msg, data);
    }
}
