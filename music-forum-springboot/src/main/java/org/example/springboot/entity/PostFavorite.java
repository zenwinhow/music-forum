package org.example.springboot.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.util.Date;

@Data
@TableName("post_favorite")
@Schema(description = "帖子收藏实体")
public class PostFavorite {
    @TableId(value = "id", type = IdType.AUTO)
    @Schema(description = "收藏ID，自增主键")
    private Long id;
    
    @Schema(description = "帖子ID")
    private Long postId;
    
    @Schema(description = "用户ID")
    private Long userId;
    
    @Schema(description = "收藏时间")
    private Date createTime;
    
    @Schema(description = "状态（0-取消收藏，1-已收藏）")
    private Integer status;
    
    @TableField(exist = false)
    @Schema(description = "帖子标题")
    private String postTitle;
    
    @TableField(exist = false)
    @Schema(description = "是否收藏")
    private Boolean isFavorite;
} 