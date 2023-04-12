package com.graduationdesign.backend.config;

import com.graduationdesign.backend.interceptor.AuthenticationInterceptor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class AuthenticationConfiguration implements WebMvcConfigurer {
    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(authenticationInterceptor())
                // 拦截所有路径
                .addPathPatterns("/**")
                // 取消特定路径的拦截
                .excludePathPatterns("/user/**")
                .excludePathPatterns("/live/getLives")
                .excludePathPatterns("/person/getLiveBloggerInfo");
    }

    @Bean
    public AuthenticationInterceptor authenticationInterceptor() {
        return new AuthenticationInterceptor();
    }
}
