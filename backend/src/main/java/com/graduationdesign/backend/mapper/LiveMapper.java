package com.graduationdesign.backend.mapper;

import com.graduationdesign.backend.entity.Live;
import org.apache.ibatis.annotations.*;

import java.util.List;

@Mapper
public interface LiveMapper {
    @Insert("INSERT INTO live(id, userId, ing, number) VALUES(#{id}, #{userId}, #{ing}, #{number})")
    void addLive(Live live);

    @Update("UPDATE live SET ing=#{status} WHERE id=#{id}")
    void updateLiveStatusById(@Param("id") String id, @Param("status") Boolean status);

    @Select("SELECT * FROM live WHERE userId=#{userId}")
    Live getLiveByUserId(String userId);

    @Select("SELECT * FROM live limit #{pageNum},#{pageSize}")
    List<Live> getLives(@Param("pageNum") Integer pageNum, @Param("pageSize") Integer pageSize);

    @Select("SELECT * FROM live WHERE id=#{id}")
    Live findLiveById(String id);

    @Update("UPDATE live SET number=#{number} WHERE id=#{id}")
    void updateLiveNumberById(@Param("id") String id, @Param("number") Integer number);

    @Update("UPDATE live SET coverUrl=#{coverUrl} WHERE id=#{id}")
    void updateLiveCoverUrlById(@Param("id") String id, @Param("coverUrl") String coverUrl);
}
