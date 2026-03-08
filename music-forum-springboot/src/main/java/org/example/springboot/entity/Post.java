package org.example.springboot.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.util.Date;

@Data
@TableName("post")
@Schema(description = "帖子实体")
public class Post {
    @TableId(value = "post_id", type = IdType.AUTO)
    @Schema(description = "帖子ID，自增主键")
    private Long id;
    
    @Schema(description = "发帖用户ID")
    @NotNull(message = "用户ID不能为空")
    private Long userId;
    
    @Schema(description = "所属版区ID")
    @NotNull(message = "版区ID不能为空")
    private Long sectionId;
    
    @Schema(description = "帖子标题")
    @NotBlank(message = "帖子标题不能为空")
    @Size(min = 2, max = 200, message = "帖子标题长度必须在2到200个字符之间")
    private String title;
    
    @Schema(description = "帖子内容")
    @NotBlank(message = "帖子内容不能为空")
    private String content;
    
    @Schema(description = "发布时间")
    private Date createTime;
    
    @Schema(description = "最后更新时间")
    private Date updateTime;
    
    @Schema(description = "浏览次数")
    private Integer viewCount;
    
    @Schema(description = "是否精华（0-否，1-是）")
    private Integer isEssence;
    
    @Schema(description = "帖子状态（0-删除，1-正常）")
    private Integer status;
    
    @TableField(exist = false)
    @Schema(description = "用户名")
    private String username;
    
    @TableField(exist = false)
    @Schema(description = "版区名称")
    private String sectionName;
    
    @TableField(exist = false)
    @Schema(description = "作者头像")
    private String authorAvatar;
    
    @TableField(exist = false)
    @Schema(description = "作者名称")
    private String authorName;
    
    @TableField(exist = false)
    @Schema(description = "评论数量")
    private Integer commentCount;
    
    @TableField(exist = false)
    @Schema(description = "点赞数量")
    private Integer likeCount;
    
    @TableField(exist = false)
    @Schema(description = "是否点赞")
    private Boolean isLiked;
    
    @TableField(exist = false)
    @Schema(description = "收藏数量")
    private Integer favoriteCount;
    
    @TableField(exist = false)
    @Schema(description = "是否收藏")
    private Boolean isFavorited;

    @TableField(exist = false)
    @Schema(description = "用户信息")
    private User user;

    @TableField(exist = false)
    @Schema(description = "版区信息")
    private Section section;
} 