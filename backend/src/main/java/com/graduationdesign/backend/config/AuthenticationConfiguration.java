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
                .excludePathPatterns("/live/enterLive")
                .excludePathPatterns("/live/exitLive")
                .excludePathPatterns("/live/downloadCover")
                .excludePathPatterns("/person/getUserInfo")
                .excludePathPatterns("/person/downloadAvatar")
                .excludePathPatterns("/gift/mock")
                .excludePathPatterns("/gift/getGifts")
                .excludePathPatterns("/video/getVideos")
                .excludePathPatterns("/video/downloadVideo")
                .excludePathPatterns("/enterprise/downloadLicense")
                .excludePathPatterns("/comment/getComments")
                .excludePathPatterns("/comment/getVideoCommentCount")
                .excludePathPatterns("/favorite/getVideoFavoriteCount")
                .excludePathPatterns("/product/downloadCover")
                .excludePathPatterns("/product/getLiveProducts");
    }

    @Bean
    public AuthenticationInterceptor authenticationInterceptor() {
        return new AuthenticationInterceptor();
    }
}
