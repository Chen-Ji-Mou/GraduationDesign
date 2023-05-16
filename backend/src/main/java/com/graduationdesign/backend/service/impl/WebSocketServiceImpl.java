package com.graduationdesign.backend.service.impl;

import com.graduationdesign.backend.service.IWebSocketService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.socket.WebSocketMessage;
import org.springframework.web.socket.WebSocketSession;

import java.io.IOException;
import java.util.concurrent.CopyOnWriteArraySet;
import java.util.concurrent.atomic.AtomicInteger;

@Slf4j
public class WebSocketServiceImpl implements IWebSocketService {
    /**
     * 在线连接数（线程安全）
     */
    private final AtomicInteger connectionCount = new AtomicInteger(0);

    /**
     * 线程安全的无序集合（存储会话）
     */
    private final CopyOnWriteArraySet<WebSocketSession> sessions = new CopyOnWriteArraySet<>();

    @Override
    public void handleOpen(WebSocketSession session) {
        sessions.add(session);
        int count = connectionCount.incrementAndGet();
        log.info("[WebSocketServiceImpl] handleOpen a new connection opened，current online count：{}", count);
    }

    @Override
    public void handleClose(WebSocketSession session) {
        sessions.remove(session);
        int count = connectionCount.decrementAndGet();
        log.info("[WebSocketServiceImpl] handleClose a new connection closed，current online count：{}", count);
    }

    @Override
    public void handleMessage(WebSocketSession session, WebSocketMessage<?> message) throws IOException {
        log.info("[WebSocketServiceImpl] handleMessage received a message：{}", message.getPayload());
        this.broadCast(session, message);
    }

    @Override
    public void broadCast(WebSocketSession session, WebSocketMessage<?> message) throws IOException {
        for (WebSocketSession curSession : sessions) {
            if (curSession.isOpen() && curSession.getAttributes().get("lid").toString().equals(session.getAttributes().get("lid").toString())) {
                curSession.sendMessage(message);
            }
        }
    }

    @Override
    public void handleError(WebSocketSession session, Throwable error) {
        log.error("[WebSocketServiceImpl] handleError websocket error：{}，session id：{}", error.getMessage(), session.getId());
    }

    @Override
    public WebSocketSession getSession(String liveId) {
        WebSocketSession session = null;
        for (WebSocketSession curSession : sessions) {
            if (curSession.isOpen() && curSession.getAttributes().get("lid").toString().equals(liveId)) {
                session = curSession;
                break;
            }
        }
        return session;
    }
}
