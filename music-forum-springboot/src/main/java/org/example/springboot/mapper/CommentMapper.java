package org.example.springboot.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.example.springboot.entity.Comment;

import java.util.List;

@Mapper
public interface CommentMapper extends BaseMapper<Comment> {
    // 批量删除评论
    int deleteByIds(@Param("ids") List<Integer> ids);
    
    // 查询评论列表（包含用户和帖子信息）
    Page<Comment> selectCommentPage(Page<Comment> page, 
                                  @Param("content") String content,
                                  @Param("username") String username,
                                  @Param("postTitle") String postTitle,
                                  @Param("postId") Integer postId,
                                  @Param("status") Integer status);
    
    // 查询帖子的所有评论
    List<Comment> selectByPostId(@Param("postId") Long postId);
    
    // 查询用户的所有评论
    List<Comment> selectByUserId(@Param("userId") Long userId);
    
    // 查询父评论下的所有子评论
    List<Comment> selectByParentId(@Param("parentId") Long parentId);
} 