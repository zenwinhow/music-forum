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
@TableName("report")
@Schema(description = "举报实体")
public class Report {
    @TableId(value = "report_id", type = IdType.AUTO)
    @Schema(description = "举报ID，自增主键")
    private Long id;
    
    @Schema(description = "举报用户ID")
    @NotNull(message = "举报用户ID不能为空")
    private Long userId;
    
    @Schema(description = "举报类型（1-帖子，2-评论，3-资源）")
    @NotNull(message = "举报类型不能为空")
    private Integer type;
    
    @Schema(description = "举报目标ID")
    @NotNull(message = "举报目标ID不能为空")
    private Long targetId;
    
    @Schema(description = "举报原因")
    @NotBlank(message = "举报原因不能为空")
    private String reason;
    
    @Schema(description = "举报时间")
    private Date createTime;
    
    @Schema(description = "处理人ID")
    private Long handlerId;
    
    @Schema(description = "处理时间")
    private Date handleTime;
    
    @Schema(description = "举报状态（0-未处理，1-已处理，2-驳回）")
    private Integer status;
    
    // 以下为数据库表中不存在但需要在显示时使用的字段
    @TableField(exist = false)
    @Schema(description = "举报用户名")
    private String username;
    
    @TableField(exist = false)
    @Schema(description = "处理人用户名")
    private String handlerName;
    
    @TableField(exist = false)
    @Schema(description = "目标内容摘要")
    private String targetContent;
} 