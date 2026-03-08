package org.example.springboot.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.util.Date;
import java.util.List;

@Data
@TableName("user")
@Schema(description = "用户实体")
public class User {
    @TableId(value = "user_id", type = IdType.AUTO)
    @Schema(description = "用户ID，自增主键")
    private Long id;
    
    @Schema(description = "用户名")
    @NotBlank(message = "用户名不能为空")
    @Size(min = 3, max = 50, message = "用户名长度必须在3到50个字符之间")
    private String username;
    
    @Schema(description = "密码")
    @NotBlank(message = "密码不能为空")
    @Size(min = 6, max = 100, message = "密码长度必须在6到100个字符之间")
    private String password;
    
    @Schema(description = "真实姓名")
    private String realName;
    
    @Schema(description = "角色类型（1-管理员，2-教师，3-学生）")
    private Integer role;
    
    @Schema(description = "电子邮箱")
    @Pattern(regexp = "^[a-zA-Z0-9_-]+(\\.[a-zA-Z0-9_-]+)*@[a-zA-Z0-9_-]+(\\.[a-zA-Z0-9_-]+)+$", message = "邮箱格式不正确")
    private String email;
    
    @Schema(description = "联系电话")
    private String phone;
    
    @Schema(description = "用户头像URL")
    private String avatar;
    
    @Schema(description = "个性签名")
    private String signature;
    
    @Schema(description = "个人简介")
    private String profile;
    
    @Schema(description = "创建时间")
    private Date createTime;
    
    @Schema(description = "最后更新时间")
    private Date updateTime;
    
    @Schema(description = "用户状态（0-禁用，1-正常）")
    private Integer status;

    
    @TableField(exist = false)
    private String token;
}
