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
@TableName("resource")
@Schema(description = "资源实体")
public class ForumResource {
    @TableId(value = "resource_id", type = IdType.AUTO)
    @Schema(description = "资源ID，自增主键")
    private Long id;
    
    @Schema(description = "资源名称")
    @NotBlank(message = "资源名称不能为空")
    private String resourceName;
    
    @Schema(description = "资源描述")
    private String description;
    
    @Schema(description = "文件路径")
    @NotBlank(message = "文件路径不能为空")
    private String filePath;
    
    @Schema(description = "文件大小（KB）")
    @NotNull(message = "文件大小不能为空")
    private Integer fileSize;
    
    @Schema(description = "文件类型")
    @NotBlank(message = "文件类型不能为空")
    private String fileType;
    
    @Schema(description = "上传用户ID")
    @NotNull(message = "上传用户ID不能为空")
    private Long userId;
    
    @Schema(description = "资源分类ID")
    @NotNull(message = "资源分类ID不能为空")
    private Long categoryId;
    
    @Schema(description = "下载次数")
    private Integer downloadCount;
    
    @Schema(description = "上传时间")
    private Date createTime;
    
    @Schema(description = "资源状态（0-删除，1-正常）")
    private Integer status;
    
    // 非数据库字段
    @TableField(exist = false)
    @Schema(description = "上传者用户名")
    private String uploadUsername;
    
    @TableField(exist = false)
    @Schema(description = "分类名称")
    private String categoryName;


} 