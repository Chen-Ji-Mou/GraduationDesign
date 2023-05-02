package com.graduationdesign.backend.mapper;

import com.graduationdesign.backend.entity.Chat;
import org.apache.ibatis.annotations.*;

import java.util.List;

@Mapper
public interface ChatMapper {
    @Insert("INSERT INTO chat(id, ownId, toId, content, timestamp) VALUES(#{id}, #{ownId}, #{toId}, #{content}, #{timestamp})")
    void addChat(Chat chat);

    @Select("SELECT * FROM chat WHERE ownId=#{ownId} ORDER BY timestamp DESC GROUP BY toId")
    List<Chat> findChatsByOwnId(String ownId);

    @Select("SELECT * FROM chat WHERE ownId=#{ownId} AND toId=#{toId} ORDER BY timestamp DESC")
    List<Chat> findChatByOwnIdAndToId(@Param("ownId") String ownId, @Param("toId") String toId);
}
