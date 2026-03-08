package org.example.springboot.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.util.Date;

@Data
@TableName("comment_like")
@Schema(description = "评论点赞实体")
public class CommentLike {
    @TableId(value = "id", type = IdType.AUTO)
    @Schema(description = "点赞ID，自增主键")
    private Long id;
    
    @TableField("comment_id")
    @Schema(description = "评论ID")
    private Long commentId;
    
    @TableField("user_id")
    @Schema(description = "用户ID")
    private Long userId;
    
    @TableField("create_time")
    @Schema(description = "点赞时间")
    private Date createTime;
    
    @TableField("status")
    @Schema(description = "状态（0-取消，1-有效）")
    private Integer status;
} 