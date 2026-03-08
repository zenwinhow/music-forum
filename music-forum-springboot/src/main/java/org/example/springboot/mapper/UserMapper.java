package org.example.springboot.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.example.springboot.entity.User;

import java.util.List;
import java.util.Map;

/**
 * 用户Mapper接口
 */
@Mapper
public interface UserMapper extends BaseMapper<User> {
    /**
     * 批量删除用户
     * @param ids 用户ID列表
     * @return 删除记录数
     */
    int deleteByIds(@Param("ids") List<Integer> ids);

    @Select("SELECT u.user_id as userId, u.username, u.real_name as realName, u.avatar, COUNT(p.post_id) as postCount " +
            "FROM user u LEFT JOIN post p ON u.user_id = p.user_id AND p.status = 1 " +
            "GROUP BY u.user_id " +
            "ORDER BY postCount DESC " +
            "LIMIT #{limit}")
    List<Map<String, Object>> selectUserActivityByPostCount(@Param("limit") int limit);
}
