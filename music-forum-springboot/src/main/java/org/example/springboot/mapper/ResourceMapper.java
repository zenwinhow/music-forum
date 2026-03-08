package org.example.springboot.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.example.springboot.entity.ForumResource;

import java.util.List;
import java.util.Map;

@Mapper
public interface ResourceMapper extends BaseMapper<ForumResource> {
    /**
     * 分页查询资源
     * @param page 分页对象
     * @param resourceName 资源名称（模糊查询）
     * @param categoryId 分类ID
     * @param fileType 文件类型
     * @param userId 上传用户ID
     * @param status 资源状态
     * @return 分页结果
     */
    Page<ForumResource> selectResourcePage(
            Page<ForumResource> page,
            @Param("resourceName") String resourceName,
            @Param("categoryId") Long categoryId,
            @Param("fileType") String fileType,
            @Param("userId") Long userId,
            @Param("status") Integer status
    );
    
    /**
     * 批量删除资源
     * @param ids 资源ID列表
     * @return 影响行数
     */
    int deleteByIds(@Param("ids") List<Integer> ids);
    
    /**
     * 更新资源下载次数
     * @param id 资源ID
     * @return 影响行数
     */
    int updateDownloadCount(@Param("id") Long id);
    
    /**
     * 根据用户ID获取资源列表
     * @param userId 用户ID
     * @return 资源列表
     */
    List<ForumResource> selectByUserId(@Param("userId") Long userId);
    
    /**
     * 根据分类ID获取资源列表
     * @param categoryId 分类ID
     * @return 资源列表
     */
    List<ForumResource> selectByCategoryId(@Param("categoryId") Long categoryId);

    @Select("SELECT SUM(file_size) FROM resource WHERE status = 1")
    Long sumResourceSize();
    
    @Select("SELECT rc.category_id as categoryId, rc.category_name as categoryName, COUNT(r.resource_id) as resourceCount " +
            "FROM resource_category rc LEFT JOIN resource r ON rc.category_id = r.category_id AND r.status = 1 " +
            "WHERE rc.status = 1 " +
            "GROUP BY rc.category_id " +
            "ORDER BY resourceCount DESC")
    List<Map<String, Object>> countResourcesByCategory();
} 