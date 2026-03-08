package org.example.springboot.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.example.springboot.entity.ResourceCategory;

import java.util.List;

@Mapper
public interface ResourceCategoryMapper extends BaseMapper<ResourceCategory> {
    /**
     * 分页查询资源分类
     * @param page 分页对象
     * @param categoryName 分类名称（模糊查询）
     * @param status 分类状态
     * @return 分页结果
     */
    Page<ResourceCategory> selectCategoryPage(
            Page<ResourceCategory> page,
            @Param("categoryName") String categoryName,
            @Param("status") Integer status
    );
    
    /**
     * 获取所有有效分类（状态为1）
     * @return 分类列表
     */
    List<ResourceCategory> selectAllValidCategories();
    
    /**
     * 批量删除资源分类
     * @param ids 分类ID列表
     * @return 影响行数
     */
    int deleteByIds(@Param("ids") List<Integer> ids);
} 