package com.graduationdesign.backend.mapper;

import com.graduationdesign.backend.entity.Favorite;
import org.apache.ibatis.annotations.*;
import java.util.List;

@Mapper
public interface FavoriteMapper {
    @Insert("INSERT INTO favorite(id, userId, videoId, timestamp) VALUES(#{id}, #{userId}, #{videoId}, #{timestamp})")
    void addFavorite(Favorite favorite);

    @Select("SELECT * FROM favorite WHERE videoId=#{videoId}")
    List<Favorite> findFavoritesByVideoId(String videoId);

    @Select("SELECT * FROM favorite WHERE userId=#{userId} ORDER BY timestamp DESC LIMIT #{pageNum},#{pageSize}")
    List<Favorite> findFavoritesByUserId(@Param("userId") String userId, @Param("pageNum") Integer pageNum, @Param("pageSize") Integer pageSize);

    @Delete("DELETE FROM favorite WHERE userId=#{userId} AND videoId=#{videoId}")
    void deleteFavoriteByUserIdAndVideoId(@Param("userId") String userId, @Param("videoId") String videoId);

    @Select("SELECT * FROM favorite WHERE id=#{id}")
    Favorite findFavoriteById(String id);
}
