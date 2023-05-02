package com.graduationdesign.backend.mapper;

import com.graduationdesign.backend.entity.Live;
import org.apache.ibatis.annotations.*;

import java.util.List;

@Mapper
public interface LiveMapper {
    @Insert("INSERT INTO live(id, userId, status, number) VALUES(#{id}, #{userId}, #{status}, #{number})")
    void addLive(Live live);

    @Update("UPDATE live SET status=#{status} WHERE id=#{id}")
    void updateStatusById(@Param("id") String id, @Param("status") Boolean status);

    @Select("SELECT * FROM live WHERE userId=#{userId}")
    Live findLiveByUserId(String userId);

    @Select("SELECT * FROM live LIMIT #{pageNum},#{pageSize}")
    List<Live> findLives(@Param("pageNum") Integer pageNum, @Param("pageSize") Integer pageSize);

    @Select("SELECT * FROM live WHERE id=#{id}")
    Live findLiveById(String id);

    @Update("UPDATE live SET number=#{number} WHERE id=#{id}")
    void updateNumberById(@Param("id") String id, @Param("number") Integer number);

    @Update("UPDATE live SET coverUrl=#{coverUrl} WHERE id=#{id}")
    void updateCoverUrlById(@Param("id") String id, @Param("coverUrl") String coverUrl);
}
