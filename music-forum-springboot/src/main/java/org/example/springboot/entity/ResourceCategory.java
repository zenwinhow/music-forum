package org.example.springboot.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

import java.util.Date;

@Data
@TableName("resource_category")
@Schema(description = "资源分类实体")
public class ResourceCategory {
    @TableId(value = "category_id", type = IdType.AUTO)
    @Schema(description = "分类ID，自增主键")
    private Long id;
    
    @Schema(description = "分类名称")
    @NotBlank(message = "分类名称不能为空")
    private String categoryName;
    
    @Schema(description = "分类描述")
    private String description;
    
    @Schema(description = "创建时间")
    private Date createTime;
    
    @Schema(description = "分类状态（0-禁用，1-正常）")
    private Integer status;
} 