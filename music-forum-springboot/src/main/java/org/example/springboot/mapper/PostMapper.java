package org.example.springboot.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.example.springboot.entity.Post;

import java.util.List;
import java.util.Map;

@Mapper
public interface PostMapper extends BaseMapper<Post> {
    // 批量删除帖子
    int deleteByIds(@Param("ids") List<Integer> ids);
    
    // 查询帖子列表（包含用户和版区信息）
    Page<Post> selectPostPage(Page<Post> page, 
                              @Param("title") String title,
                              @Param("userId") Long userId,
                              @Param("sectionId") Long sectionId,
                              @Param("isEssence") Integer isEssence,
                              @Param("status") Integer status);
    
    // 查询用户的所有帖子
    List<Post> selectByUserId(@Param("userId") Long userId);
    
    // 查询版区的所有帖子
    List<Post> selectBySectionId(@Param("sectionId") Long sectionId);

    @Select("SELECT s.section_id as sectionId, s.section_name as sectionName, COUNT(p.post_id) as postCount " +
            "FROM section s LEFT JOIN post p ON s.section_id = p.section_id AND p.status = 1 " +
            "WHERE s.status = 1 " +
            "GROUP BY s.section_id " +
            "ORDER BY postCount DESC")
    List<Map<String, Object>> countPostsBySection();
} 