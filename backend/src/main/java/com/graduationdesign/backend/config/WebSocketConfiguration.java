package com.graduationdesign.backend.config;

import com.graduationdesign.backend.handler.DefaultWebSocketHandler;
import com.graduationdesign.backend.interceptor.WebSocketInterceptor;
import com.graduationdesign.backend.service.IWebSocketService;
import com.graduationdesign.backend.service.impl.WebSocketServiceImpl;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.socket.config.annotation.EnableWebSocket;
import org.springframework.web.socket.config.annotation.WebSocketConfigurer;
import org.springframework.web.socket.config.annotation.WebSocketHandlerRegistry;

@Configuration
@EnableWebSocket
public class WebSocketConfiguration implements WebSocketConfigurer {

    @Bean
    public DefaultWebSocketHandler defaultWebSocketHandler() {
        return new DefaultWebSocketHandler();
    }

    @Bean
    public IWebSocketService webSocket() {
        return new WebSocketServiceImpl();
    }

    @Bean
    public WebSocketInterceptor webSocketInterceptor() {
        return new WebSocketInterceptor();
    }

    @Override
    public void registerWebSocketHandlers(WebSocketHandlerRegistry registry) {
        registry.addHandler(defaultWebSocketHandler(), "websocket")
                .addInterceptors(webSocketInterceptor())
                .setAllowedOrigins("*");
    }
}
