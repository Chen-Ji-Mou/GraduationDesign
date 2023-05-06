package com.graduationdesign.backend.mapper;

import com.graduationdesign.backend.entity.Video;
import org.apache.ibatis.annotations.*;

import java.util.List;

@Mapper
public interface VideoMapper {
    @Insert("INSERT INTO video(id, userId, fileName, timestamp, shareCount) VALUES(#{id}, #{userId}, #{fileName}, #{timestamp}, #{shareCount})")
    void addVideo(Video video);

    @Select("SELECT * FROM video ORDER BY timestamp DESC LIMIT #{pageNum},#{pageSize}")
    List<Video> findVideos(@Param("pageNum") Integer pageNum, @Param("pageSize") Integer pageSize);

    @Select("SELECT * FROM video WHERE fileName=#{fileName}")
    Video findVideoByFileName(String fileName);

    @Delete("DELETE FROM video WHERE fileName=#{fileName}")
    void deleteVideoByFileName(String fileName);

    @Select("SELECT * FROM video WHERE id=#{id}")
    Video findVideoById(String id);

    @Update("UPDATE video SET shareCount=#{shareCount} WHERE id=#{id}")
    void updateShareCountById(@Param("id") String id, @Param("shareCount") Integer shareCount);
}
