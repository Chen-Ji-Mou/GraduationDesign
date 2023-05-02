package com.graduationdesign.backend.service.impl;

import com.graduationdesign.backend.entity.Chat;
import com.graduationdesign.backend.mapper.ChatMapper;
import com.graduationdesign.backend.service.IChatService;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.List;

@Service
public class ChatServiceImpl implements IChatService {

    @Resource
    ChatMapper mapper;

    @Override
    public void addChat(Chat chat) {
        mapper.addChat(chat);
    }

    @Override
    public List<Chat> findChatsByOwnId(String ownId) {
        return mapper.findChatsByOwnId(ownId);
    }

    @Override
    public List<Chat> findChatByOwnIdAndToId(String ownId, String toId) {
        return mapper.findChatByOwnIdAndToId(ownId, toId);
    }
}
