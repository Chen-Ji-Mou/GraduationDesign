package com.graduationdesign.backend.controller;

import com.graduationdesign.backend.Result;
import com.graduationdesign.backend.Utils;
import com.graduationdesign.backend.entity.Cart;
import com.graduationdesign.backend.entity.Chat;
import com.graduationdesign.backend.service.IChatService;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.RandomStringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import javax.servlet.http.HttpServletRequest;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

@Slf4j
@RestController
@RequestMapping(value = "/chat")
public class ChatController {

    @Autowired
    IChatService chatService;

    @RequestMapping(value = "/addChat", method = RequestMethod.POST)
    private Result addChat(HttpServletRequest request, @RequestParam("toId") String toId,
                           @RequestParam("content") String content) {
        String userId = Utils.getUserIdFromToken(request.getHeader("token"));
        Chat chat = new Chat();
        String chatId = RandomStringUtils.randomNumeric(11);
        chat.setId(chatId);
        chat.setOwnId(userId);
        chat.setToId(toId);
        chat.setContent(content);
        chat.setTimestamp(System.currentTimeMillis());
        chatService.addChat(chat);
        log.info("[ChatController] addChat 聊天记录添加成功 ownId {} toId {}", userId, toId);
        return Result.success();
    }

    @RequestMapping(value = "/getChatList", method = RequestMethod.GET)
    private Result getChatList(HttpServletRequest request) {
        String userId = Utils.getUserIdFromToken(request.getHeader("token"));
        List<Chat> chatList = chatService.findChatsByOwnId(userId);
        log.info("[ChatController] getChatList 获取聊天记录列表成功 ownId {} chatList {}", userId, chatList);
        return Result.success();
    }

    @RequestMapping(value = "/getChat", method = RequestMethod.GET)
    private Result getChat(HttpServletRequest request, @RequestParam("toId") String toId,
                           @RequestParam(name = "pageNum") Integer pageNum,
                           @RequestParam(name = "pageSize") Integer pageSize) {
        pageNum *= pageSize;
        String userId = Utils.getUserIdFromToken(request.getHeader("token"));
        List<Chat> result = new ArrayList<>();
        result.addAll(chatService.findChatByOwnIdAndToId(userId, toId));
        result.addAll(chatService.findChatByOwnIdAndToId(toId, userId));
        Collections.sort(result);
        result = result.subList(pageNum, pageSize);
        log.info("[ChatController] getChat 获取聊天记录成功 ownId {} toId {}", userId, toId);
        return Result.success(result);
    }
}
