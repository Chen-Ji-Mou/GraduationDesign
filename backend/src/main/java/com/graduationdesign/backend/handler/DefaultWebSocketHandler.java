package com.graduationdesign.backend.handler;

import com.graduationdesign.backend.service.WebSocketService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.lang.NonNull;
import org.springframework.web.socket.*;

public class DefaultWebSocketHandler implements WebSocketHandler {

    @Autowired
    private WebSocketService service;

    /**
     * 建立连接
     *
     * @param session Session
     */
    @Override
    public void afterConnectionEstablished(@NonNull WebSocketSession session) {
        service.handleOpen(session);
    }

    /**
     * 接收消息
     *
     * @param session Session
     * @param message 消息
     */
    @Override
    public void handleMessage(@NonNull WebSocketSession session, @NonNull WebSocketMessage<?> message) {
        service.handleMessage(session, message);
    }

    /**
     * 发生错误
     *
     * @param session   Session
     * @param exception 异常
     */
    @Override
    public void handleTransportError(WebSocketSession session, Throwable exception) {
        service.handleError(session, exception);
    }

    /**
     * 关闭连接
     *
     * @param session     Session
     * @param closeStatus 关闭状态
     */
    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus closeStatus) {
        service.handleClose(session);
    }

    /**
     * 是否支持发送部分消息
     *
     * @return 默认为false
     */
    @Override
    public boolean supportsPartialMessages() {
        return false;
    }
}
