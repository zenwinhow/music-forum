package org.example.springboot.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;
import org.example.springboot.entity.Notification;
 
@Mapper
public interface NotificationMapper extends BaseMapper<Notification> {
    // 继承BaseMapper接口，已经包含基本的CRUD方法
} 