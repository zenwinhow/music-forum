package org.example.springboot.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.example.springboot.entity.Report;

import java.util.List;

@Mapper
public interface ReportMapper extends BaseMapper<Report> {
    // 批量删除举报
    int deleteByIds(@Param("ids") List<Integer> ids);
    
    // 查询举报列表（包含用户和处理人信息）
    Page<Report> selectReportPage(Page<Report> page, 
                                  @Param("reason") String reason,
                                  @Param("type") Integer type,
                                  @Param("username") String username,
                                  @Param("status") Integer status);
    
    // 根据类型和目标ID查询举报
    List<Report> selectByTypeAndTargetId(@Param("type") Integer type, @Param("targetId") Long targetId);
    
    // 根据用户ID查询举报
    List<Report> selectByUserId(@Param("userId") Long userId);
} 