package org.example.springboot.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.util.Date;

/**
 * 版区实体类
 */
@Data
@TableName("section")
@Schema(description = "版区实体")
public class Section {
    @TableId(value = "section_id", type = IdType.AUTO)
    @Schema(description = "版区ID，自增主键")
    private Long id;
    
    @Schema(description = "版区名称")
    @NotBlank(message = "版区名称不能为空")
    @Size(min = 2, max = 100, message = "版区名称长度必须在2到100个字符之间")
    private String sectionName;
    
    @Schema(description = "版区描述")
    @Size(max = 500, message = "版区描述长度不能超过500个字符")
    private String description;
    
    @Schema(description = "创建时间")
    private Date createTime;
    
    @Schema(description = "最后更新时间")
    private Date updateTime;
    
    @Schema(description = "版区状态（0-禁用，1-正常）")
    private Integer status;
} 