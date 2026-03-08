package org.example.springboot.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.example.springboot.entity.PostFavorite;

import java.util.List;

@Mapper
public interface PostFavoriteMapper extends BaseMapper<PostFavorite> {
    /**
     * 查询用户收藏的帖子
     * @param page 分页参数
     * @param userId 用户ID
     * @return 帖子收藏分页列表
     */
    Page<PostFavorite> selectFavoritesByUserId(Page<PostFavorite> page, @Param("userId") Long userId);
    
    /**
     * 查询帖子是否被用户收藏
     * @param postId 帖子ID
     * @param userId 用户ID
     * @return 收藏记录
     */
    PostFavorite selectFavoriteByPostIdAndUserId(@Param("postId") Long postId, @Param("userId") Long userId);
    
    /**
     * 获取帖子的收藏数量
     * @param postId 帖子ID
     * @return 收藏数量
     */
    Integer countFavoritesByPostId(@Param("postId") Long postId);
} 