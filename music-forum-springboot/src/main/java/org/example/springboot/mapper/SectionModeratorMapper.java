package org.example.springboot.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.example.springboot.entity.SectionModerator;

import java.util.List;

@Mapper
public interface SectionModeratorMapper extends BaseMapper<SectionModerator> {
    // 批量删除版主
    int deleteByIds(@Param("ids") List<Integer> ids);
    
    // 查询版主列表（包含用户和版区信息）
    Page<SectionModerator> selectModeratorPage(Page<SectionModerator> page, 
                                              @Param("sectionId") Long sectionId,
                                              @Param("username") String username);
                                              
    // 根据版区ID查询该版区的所有版主
    List<SectionModerator> selectBySectionId(@Param("sectionId") Long sectionId);
    
    // 根据用户ID查询其担任版主的所有版区
    List<SectionModerator> selectByUserId(@Param("userId") Long userId);
} 