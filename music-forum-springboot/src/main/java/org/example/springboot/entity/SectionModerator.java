package org.example.springboot.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.util.Date;

@Data
@TableName("section_moderator")
@Schema(description = "版主实体")
public class SectionModerator {
    @TableId(value = "id", type = IdType.AUTO)
    @Schema(description = "记录ID，自增主键")
    private Long id;
    
    @Schema(description = "版区ID")
    @NotNull(message = "版区ID不能为空")
    private Long sectionId;
    
    @Schema(description = "用户ID")
    @NotNull(message = "用户ID不能为空")
    private Long userId;
    
    @Schema(description = "任命时间")
    private Date appointTime;
    
    @Schema(description = "任命人ID")
    private Long appointBy;
    
    @Schema(description = "状态（0-停用，1-正常）")
    private Integer status;
    
    @Schema(description = "备注说明")
    @Size(max = 200, message = "备注说明长度不能超过200个字符")
    private String remark;
    
    @TableField(exist = false)
    @Schema(description = "版区名称")
    private String sectionName;
    
    @TableField(exist = false)
    @Schema(description = "用户名")
    private String username;
    
    @TableField(exist = false)
    @Schema(description = "用户真实姓名")
    private String realName;
    
    @TableField(exist = false)
    @Schema(description = "任命人用户名")
    private String appointByName;

    @TableField(exist = false)
    @Schema(description = "用户信息")
    private User user;

} 