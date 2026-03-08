package org.example.springboot.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.example.springboot.entity.Section;

import java.util.List;

/**
 * 版区Mapper接口
 */
@Mapper
public interface SectionMapper extends BaseMapper<Section> {
    /**
     * 批量删除版区
     * @param ids 版区ID列表
     * @return 删除记录数
     */
    int deleteByIds(@Param("ids") List<Long> ids);
} 