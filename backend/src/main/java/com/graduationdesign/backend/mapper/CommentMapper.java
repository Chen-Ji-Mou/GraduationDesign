package com.graduationdesign.backend.mapper;

import com.graduationdesign.backend.entity.Comment;
import org.apache.ibatis.annotations.*;

import java.util.List;

@Mapper
public interface CommentMapper {
    @Insert("INSERT INTO comment(id, userId, videoId, content, timestamp) VALUES(#{id}, #{userId}, #{videoId}, #{content}, #{timestamp})")
    void addComment(Comment comment);

    @Select("SELECT * FROM comment WHERE videoId=#{videoId}")
    List<Comment> findComments(String videoId);

    @Select("SELECT * FROM comment WHERE videoId=#{videoId} ORDER BY timestamp DESC LIMIT #{pageNum},#{pageSize}")
    List<Comment> findCommentsByVideoId(@Param("videoId") String videoId, @Param("pageNum") Integer pageNum, @Param("pageSize") Integer pageSize);
}
