package org.example.springboot.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.util.Date;

@Data
@TableName("comment")
@Schema(description = "评论实体")
public class Comment {
    @TableId(value = "comment_id", type = IdType.AUTO)
    @Schema(description = "评论ID，自增主键")
    private Long id;
    
    @Schema(description = "帖子ID")
    @NotNull(message = "帖子ID不能为空")
    private Long postId;
    
    @Schema(description = "评论用户ID")
    @NotNull(message = "用户ID不能为空")
    private Long userId;
    
    @Schema(description = "评论内容")
    @NotBlank(message = "评论内容不能为空")
    private String content;
    
    @Schema(description = "评论时间")
    private Date createTime;
    
    @Schema(description = "父评论ID，用于回复评论")
    private Long parentId;
    
    @Schema(description = "评论状态（0-删除，1-正常）")
    private Integer status;
    
    @TableField(exist = false)
    @Schema(description = "用户名")
    private String username;
    
    @TableField(exist = false)
    @Schema(description = "用户头像")
    private String userAvatar;
    
    @TableField(exist = false)
    @Schema(description = "帖子标题")
    private String postTitle;
    
    @TableField(exist = false)
    @Schema(description = "回复目标用户名")
    private String parentUsername;
    
    @TableField(exist = false)
    @Schema(description = "点赞数量")
    private Integer likeCount;
    
    @TableField(exist = false)
    @Schema(description = "当前用户是否点赞")
    private Boolean isLiked;

    @TableField(exist = false)
    @Schema(description = "用户信息")
    private User user;
} 