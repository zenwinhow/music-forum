<template>
  <div class="resource-category-management-container">
    <!-- 搜索卡片 -->
    <el-card class="search-card">
      <div class="search-form">
        <el-form :model="searchForm" inline>
          <el-form-item label="分类名称">
            <el-input v-model="searchForm.categoryName" placeholder="请输入分类名称" clearable></el-input>
          </el-form-item>
          <el-form-item label="状态">
            <el-select v-model="searchForm.status" placeholder="请选择状态" clearable style="width: 150px">
              <el-option label="正常" :value="1"></el-option>
              <el-option label="禁用" :value="0"></el-option>
            </el-select>
          </el-form-item>
          <el-form-item>
            <el-button type="primary" @click="handleSearch">
              <el-icon><Search /></el-icon>搜索
            </el-button>
            <el-button @click="resetSearch">
              <el-icon><Refresh /></el-icon>重置
            </el-button>
          </el-form-item>
        </el-form>
      </div>
    </el-card>

    <!-- 操作栏 -->
    <div class="operation-bar">
      <el-button type="primary" @click="refreshCategoryList">
        <el-icon><Refresh /></el-icon>刷新
      </el-button>
      <el-button type="primary" @click="handleExport">
        <el-icon><Download /></el-icon>导出
      </el-button>
      <el-button type="danger" :disabled="selectedRows.length === 0" @click="handleBatchDelete">
        <el-icon><Delete /></el-icon>批量删除
      </el-button>
      <el-button type="primary" @click="handleAdd">
        <el-icon><Plus /></el-icon>新增分类
      </el-button>
    </div>

    <!-- 数据表格 -->
    <el-card class="table-card">
      <el-table
        v-loading="tableLoading"
        :data="tableData"
        border
        stripe
        style="width: 100%"
        @selection-change="handleSelectionChange"
      >
        <el-table-column type="selection" width="55"></el-table-column>
        <el-table-column prop="id" label="ID" width="80"></el-table-column>
        <el-table-column prop="categoryName" label="分类名称" min-width="180"></el-table-column>
        <el-table-column prop="description" label="分类描述" min-width="220" show-overflow-tooltip></el-table-column>
        <el-table-column prop="createTime" label="创建时间" width="180">
          <template #default="scope">
            {{ formatDate(scope.row.createTime) }}
          </template>
        </el-table-column>
        <el-table-column prop="status" label="状态" width="80">
          <template #default="scope">
            <el-switch
              v-model="scope.row.status"
              :active-value="1"
              :inactive-value="0"
              @change="(val) => handleStatusChange(scope.row.id, val)"
            ></el-switch>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="180">
          <template #default="scope">
            <el-button type="primary" size="small" @click="handleEdit(scope.row)">
              <el-icon><Edit /></el-icon>编辑
            </el-button>
            <el-button type="danger" size="small" @click="handleDelete(scope.row)">
              <el-icon><Delete /></el-icon>删除
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <div class="pagination-container">
        <el-pagination
          :current-page="currentPage"
          :page-size="pageSize"
          :page-sizes="[10, 20, 50, 100]"
          layout="total, sizes, prev, pager, next, jumper"
          :total="total"
          @size-change="handleSizeChange"
          @current-change="handleCurrentChange"
        ></el-pagination>
      </div>
    </el-card>

    <!-- 分类表单对话框 -->
    <el-dialog 
      v-model="dialogVisible" 
      :title="dialogTitle" 
      width="500px" 
      :close-on-click-modal="false"
      :before-close="handleDialogClose"
    >
      <el-form 
        ref="categoryFormRef" 
        :model="categoryForm" 
        :rules="categoryFormRules" 
        label-width="100px"
      >
        <el-form-item label="分类名称" prop="categoryName">
          <el-input v-model="categoryForm.categoryName" placeholder="请输入分类名称"></el-input>
        </el-form-item>
        <el-form-item label="分类描述" prop="description">
          <el-input v-model="categoryForm.description" type="textarea" rows="3" placeholder="请输入分类描述"></el-input>
        </el-form-item>
        <el-form-item label="分类状态" prop="status">
          <el-radio-group v-model="categoryForm.status">
            <el-radio :label="1">正常</el-radio>
            <el-radio :label="0">禁用</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="dialogVisible = false">取消</el-button>
          <el-button type="primary" @click="handleSubmit">确定</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { Search, Refresh, Download, Plus, Edit, Delete } from '@element-plus/icons-vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import request from '@/utils/request'
import { formatDate } from '@/utils/format'

// 搜索表单
const searchForm = reactive({
  categoryName: '',
  status: ''
})

// 表格数据
const tableLoading = ref(false)
const tableData = ref([])
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)
const selectedRows = ref([])

// 表单对话框
const dialogVisible = ref(false)
const dialogTitle = ref('新增分类')
const categoryFormRef = ref(null)
const categoryForm = reactive({
  id: '',
  categoryName: '',
  description: '',
  status: 1
})

// 表单验证规则
const categoryFormRules = {
  categoryName: [
    { required: true, message: '请输入分类名称', trigger: 'blur' },
    { min: 2, max: 50, message: '长度在 2 到 50 个字符', trigger: 'blur' }
  ],
  description: [
    { max: 200, message: '描述不能超过 200 个字符', trigger: 'blur' }
  ]
}

// 获取资源分类列表
const fetchCategories = () => {
  tableLoading.value = true
  const params = {
    categoryName: searchForm.categoryName || undefined,
    status: searchForm.status === '' ? undefined : searchForm.status,
    currentPage: currentPage.value,
    size: pageSize.value
  }
  
  request.get('/resource/category/page', params, {
    showDefaultMsg: false,
    onSuccess: (res) => {
      tableData.value = res.records
      total.value = res.total
      tableLoading.value = false
    },
    onError: (error) => {
      console.error('获取资源分类列表失败:', error)
      tableLoading.value = false
    }
  })
}

// 搜索
const handleSearch = () => {
  currentPage.value = 1
  fetchCategories()
}

// 重置搜索
const resetSearch = () => {
  Object.keys(searchForm).forEach(key => {
    searchForm[key] = ''
  })
  handleSearch()
}

// 刷新列表
const refreshCategoryList = () => {
  fetchCategories()
}

// 导出分类列表
const handleExport = () => {
  ElMessage.success('分类列表导出功能开发中')
  // TODO: 实现导出功能
}

// 表格选择项变化
const handleSelectionChange = (rows) => {
  selectedRows.value = rows
}

// 分页大小变化
const handleSizeChange = (val) => {
  pageSize.value = val
  fetchCategories()
}

// 当前页变化
const handleCurrentChange = (val) => {
  currentPage.value = val
  fetchCategories()
}

// 新增分类
const handleAdd = () => {
  dialogTitle.value = '新增分类'
  categoryForm.id = ''
  categoryForm.categoryName = ''
  categoryForm.description = ''
  categoryForm.status = 1
  dialogVisible.value = true
}

// 编辑分类
const handleEdit = (row) => {
  dialogTitle.value = '编辑分类'
  Object.assign(categoryForm, {
    id: row.id,
    categoryName: row.categoryName,
    description: row.description,
    status: row.status
  })
  dialogVisible.value = true
}

// 删除分类
const handleDelete = (row) => {
  ElMessageBox.confirm('确认删除该分类吗？', '提示', {
    confirmButtonText: '确认',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    request.delete(`/resource/category/${row.id}`, {
      successMsg: '删除成功',
      onSuccess: () => {
        fetchCategories()
      }
    })
  }).catch(() => {})
}

// 批量删除
const handleBatchDelete = () => {
  if (selectedRows.value.length === 0) return
  
  ElMessageBox.confirm(`确认批量删除选中的 ${selectedRows.value.length} 条分类记录吗？`, '提示', {
    confirmButtonText: '确认',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    const ids = selectedRows.value.map(item => item.id)
    request.delete('/resource/category/batch', { ids }, {
      successMsg: '批量删除成功',
      onSuccess: () => {
        fetchCategories()
      }
    })
  }).catch(() => {})
}

// 更新分类状态
const handleStatusChange = (id, status) => {
  request.put(`/resource/category/${id}/status?status=${status}`, null, {
    successMsg: `状态已${status === 1 ? '启用' : '禁用'}`,
    onSuccess: () => {
      fetchCategories()
    },
    onError: () => {
      fetchCategories() // 更新失败时刷新列表
    }
  })
}

// 对话框关闭前的处理
const handleDialogClose = (done) => {
  categoryFormRef.value.resetFields()
  done()
}

// 提交表单
const handleSubmit = async () => {
  if (!categoryFormRef.value) return
  
  try {
    await categoryFormRef.value.validate()
    
    if (dialogTitle.value === '新增分类') {
      // 创建分类
      const categoryData = {
        categoryName: categoryForm.categoryName,
        description: categoryForm.description,
        status: categoryForm.status
      }
      
      request.post('/resource/category/add', categoryData, {
        successMsg: '分类创建成功',
        onSuccess: () => {
          dialogVisible.value = false
          fetchCategories()
        }
      })
    } else {
      // 编辑分类
      const categoryData = {
        categoryName: categoryForm.categoryName,
        description: categoryForm.description,
        status: categoryForm.status
      }
      
      request.put(`/resource/category/${categoryForm.id}`, categoryData, {
        successMsg: '分类更新成功',
        onSuccess: () => {
          dialogVisible.value = false
          fetchCategories()
        }
      })
    }
  } catch (error) {
    console.error('表单验证失败:', error)
  }
}

// 初始化
onMounted(() => {
  fetchCategories()
})
</script>

<style lang="scss" scoped>
.resource-category-management-container {
  padding: 20px;
  
  .search-card {
    margin-bottom: 20px;
    
    .search-form {
      display: flex;
      justify-content: space-between;
      align-items: center;
    }
  }
  
  .operation-bar {
    margin-bottom: 20px;
    display: flex;
    gap: 10px;
  }
  
  .table-card {
    margin-bottom: 20px;
  }
  
  .pagination-container {
    margin-top: 20px;
    display: flex;
    justify-content: flex-end;
  }
}
</style> 