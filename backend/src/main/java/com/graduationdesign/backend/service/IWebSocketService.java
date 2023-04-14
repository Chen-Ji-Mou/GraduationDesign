package com.graduationdesign.backend.service;

import org.springframework.web.socket.WebSocketMessage;
import org.springframework.web.socket.WebSocketSession;
import java.io.IOException;
import java.util.Set;

public interface IWebSocketService {
    /**
     * 会话开始回调
     *
     * @param session 会话
     */
    void handleOpen(WebSocketSession session);

    /**
     * 会话结束回调
     *
     * @param session 会话
     */
    void handleClose(WebSocketSession session);

    /**
     * 处理消息
     *
     * @param session 会话
     * @param message 接收的消息
     */
    void handleMessage(WebSocketSession session, WebSocketMessage<?> message) throws IOException;

    /**
     * 广播
     *
     * @param message 消息
     * @throws IOException 异常
     */
    void broadCast(WebSocketSession session, WebSocketMessage<?> message) throws IOException;

    /**
     * 处理会话异常
     *
     * @param session 会话
     * @param error   异常
     */
    void handleError(WebSocketSession session, Throwable error);

    /**
     * 获取会话
     *
     * @param liveId 直播间id
     */
    WebSocketSession getSession(String liveId);
}
