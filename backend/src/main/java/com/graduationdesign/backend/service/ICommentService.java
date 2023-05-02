package com.graduationdesign.backend.service;

import com.graduationdesign.backend.entity.Comment;
import java.util.List;

public interface ICommentService {
    void addComment(Comment comment);
    List<Comment> findComments(String videoId);
    List<Comment> findCommentsByVideoId(String videoId, Integer pageNum, Integer pageSize);
}
