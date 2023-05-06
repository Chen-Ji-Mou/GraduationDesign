package com.graduationdesign.backend.service;

import com.graduationdesign.backend.entity.Favorite;
import java.util.List;

public interface IFavoriteService {
    void addFavorite(Favorite favorite);
    List<Favorite> findFavoritesByVideoId(String videoId);
    List<Favorite> findFavoritesByUserId(String userId, Integer pageNum, Integer pageSize);
    void deleteFavoriteByUserIdAndVideoId(String userId, String videoId);
    Favorite findFavoriteById(String id);
}
