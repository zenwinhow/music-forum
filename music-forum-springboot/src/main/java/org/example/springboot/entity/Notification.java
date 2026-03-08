package org.example.springboot.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.util.Date;

@Data
@TableName("notification")
@Schema(description = "系统通知实体")
public class Notification {
    @TableId(value = "notification_id", type = IdType.AUTO)
    @Schema(description = "通知ID，自增主键")
    private Long id;
    
    @Schema(description = "通知标题")
    @NotBlank(message = "通知标题不能为空")
    @Size(min = 2, max = 200, message = "通知标题长度必须在2到200个字符之间")
    private String title;
    
    @Schema(description = "通知内容")
    @NotBlank(message = "通知内容不能为空")
    private String content;
    
    @Schema(description = "发布用户ID")
    private Long userId;
    
    @Schema(description = "发布时间")
    private Date createTime;
    
    @Schema(description = "通知状态（0-下线，1-发布）")
    private Integer status;
} 