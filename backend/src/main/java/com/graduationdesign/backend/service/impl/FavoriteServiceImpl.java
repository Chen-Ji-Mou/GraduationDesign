package com.graduationdesign.backend.service.impl;

import com.graduationdesign.backend.entity.Favorite;
import com.graduationdesign.backend.mapper.FavoriteMapper;
import com.graduationdesign.backend.service.IFavoriteService;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.List;

@Service
public class FavoriteServiceImpl implements IFavoriteService {

    @Resource
    FavoriteMapper mapper;

    @Override
    public void addFavorite(Favorite favorite) {
        mapper.addFavorite(favorite);
    }

    @Override
    public List<Favorite> findFavoritesByVideoId(String videoId) {
        return mapper.findFavoritesByVideoId(videoId);
    }

    @Override
    public List<Favorite> findFavoritesByUserId(String userId, Integer pageNum, Integer pageSize) {
        return mapper.findFavoritesByUserId(userId, pageNum, pageSize);
    }

    @Override
    public void deleteFavoriteById(String id) {
        mapper.deleteFavoriteById(id);
    }

    @Override
    public Favorite findFavoriteById(String id) {
        return mapper.findFavoriteById(id);
    }
}
