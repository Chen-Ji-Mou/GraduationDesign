package com.graduationdesign.backend.mapper;

import com.graduationdesign.backend.entity.Video;
import org.apache.ibatis.annotations.*;

import java.util.List;

@Mapper
public interface VideoMapper {
    @Insert("INSERT INTO video(id, userId, fileName, timestamp) VALUES(#{id}, #{userId}, #{fileName}, #{timestamp})")
    void addVideo(Video video);

    @Select("SELECT * FROM video limit #{pageNum},#{pageSize}")
    List<Video> getVideos(@Param("pageNum") Integer pageNum, @Param("pageSize") Integer pageSize);

    @Select("SELECT * FROM video WHERE fileName=#{fileName}")
    Video getVideo(String fileName);

    @Delete("DELETE FROM video WHERE fileName=#{fileName}")
    void deleteVideo(String fileName);
}
