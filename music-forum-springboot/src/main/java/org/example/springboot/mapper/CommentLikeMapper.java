package org.example.springboot.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.example.springboot.entity.CommentLike;

@Mapper
public interface CommentLikeMapper extends BaseMapper<CommentLike> {
    /**
     * 获取评论的点赞数量
     * @param commentId 评论ID
     * @return 点赞数量
     */
    Integer countLikesByCommentId(@Param("commentId") Long commentId);
    
    /**
     * 查询评论是否被用户点赞
     * @param commentId 评论ID
     * @param userId 用户ID
     * @return 点赞记录
     */
    CommentLike selectLikeByCommentIdAndUserId(@Param("commentId") Long commentId, @Param("userId") Long userId);
} 