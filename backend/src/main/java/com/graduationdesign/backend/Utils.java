package com.graduationdesign.backend;

import com.auth0.jwt.JWT;
import com.auth0.jwt.JWTVerifier;
import com.auth0.jwt.algorithms.Algorithm;
import com.auth0.jwt.interfaces.DecodedJWT;
import com.graduationdesign.backend.entity.User;
import lombok.extern.slf4j.Slf4j;

import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.Random;

@Slf4j
public class Utils {
    private static final String TOKEN_SECRET = "081310";

    /**
     * 生成token
     */
    public static String generateToken(User user) {
        Date start = new Date();
        long endMillis = System.currentTimeMillis() + 7 * 24 * 60 * 60 * 1000; // 7天有效时间
        // 过期时间
        Date end = new Date(endMillis);
        // 秘钥及加密算法
        Algorithm algorithm = Algorithm.HMAC256(TOKEN_SECRET);
        // 设置头部信息
        Map<String, Object> header = new HashMap<>();
        header.put("typ", "JWT");
        header.put("alg", "HS256");
        // 生成token
        String token;
        token = JWT.create()
                .withHeader(header)
                .withClaim("id", user.getId())
                .withIssuedAt(start)
                .withExpiresAt(end)
                .sign(algorithm);
        return token;
    }

    /**
     * 获取token中的用户id，验证token是否有效
     * @return 如果token有效返回读取到的用户id，否则返回-1
     */
    public static Integer getUserIdFromToken(String token) {
        try {
            Algorithm algorithm = Algorithm.HMAC256(TOKEN_SECRET);
            JWTVerifier verifier = JWT.require(algorithm).build();
            DecodedJWT jwt = verifier.verify(token);
            return jwt.getClaim("id").asInt();
        } catch (Exception e) {
            log.error("[getUserIdFromToken] token 失效");
            return -1;
        }
    }
}
