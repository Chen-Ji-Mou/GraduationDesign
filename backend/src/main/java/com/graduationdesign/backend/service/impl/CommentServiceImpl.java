package com.graduationdesign.backend.service.impl;

import com.graduationdesign.backend.entity.Comment;
import com.graduationdesign.backend.mapper.CommentMapper;
import com.graduationdesign.backend.service.ICommentService;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.List;

@Service
public class CommentServiceImpl implements ICommentService {

    @Resource
    CommentMapper mapper;

    @Override
    public void addComment(Comment comment) {
        mapper.addComment(comment);
    }

    @Override
    public List<Comment> findComments(String videoId) {
        return mapper.findComments(videoId);
    }

    @Override
    public List<Comment> findCommentsByVideoId(String videoId, Integer pageNum, Integer pageSize) {
        return mapper.findCommentsByVideoId(videoId, pageNum, pageSize);
    }
}
