package com.graduationdesign.backend.service;

import com.graduationdesign.backend.entity.Chat;
import java.util.List;

public interface IChatService {
    void addChat(Chat chat);
    List<Chat> findChatsByOwnId(String ownId);
    List<Chat> findChatByOwnIdAndToId(String ownId, String toId);
}
