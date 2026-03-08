<template>
  <div class="resource-management-container">
    <!-- 搜索卡片 -->
    <el-card class="search-card">
      <div class="search-form">
        <el-form :model="searchForm" inline>
          <el-form-item label="资源名称">
            <el-input v-model="searchForm.resourceName" placeholder="请输入资源名称" clearable></el-input>
          </el-form-item>
          <el-form-item label="资源分类">
            <el-select v-model="searchForm.categoryId" placeholder="请选择分类" clearable style="width: 150px">
              <el-option v-for="item in categoryOptions" :key="item.id" :label="item.categoryName" :value="item.id"></el-option>
            </el-select>
          </el-form-item>
          <el-form-item label="上传者">
            <el-input v-model="searchForm.username" placeholder="请输入上传者用户名" clearable></el-input>
          </el-form-item>
          <el-form-item label="状态">
            <el-select v-model="searchForm.status" placeholder="请选择状态" clearable style="width: 150px">
              <el-option label="正常" :value="1"></el-option>
              <el-option label="已删除" :value="0"></el-option>
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
      <el-button type="primary" @click="refreshResourceList">
        <el-icon><Refresh /></el-icon>刷新
      </el-button>
      <el-button type="primary" @click="handleExport">
        <el-icon><Download /></el-icon>导出
      </el-button>
      <el-button type="danger" :disabled="selectedRows.length === 0" @click="handleBatchDelete">
        <el-icon><Delete /></el-icon>批量删除
      </el-button>
      <el-button type="primary" @click="handleAdd">
        <el-icon><Plus /></el-icon>上传资源
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
        <el-table-column prop="id" label="ID" width="60"></el-table-column>
        <el-table-column prop="resourceName" label="资源名称" min-width="180" show-overflow-tooltip></el-table-column>
        <el-table-column prop="categoryName" label="分类" width="120"></el-table-column>
        <el-table-column prop="fileType" label="类型" width="100">
          <template #default="scope">
            <el-tag :type="getFileTypeColor(scope.row.fileType)">{{ scope.row.fileType }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="fileSize" label="大小" width="100">
          <template #default="scope">
            {{ formatFileSize(scope.row.fileSize) }}
          </template>
        </el-table-column>
        <el-table-column prop="uploadUsername" label="上传者" width="120"></el-table-column>
        <el-table-column prop="createTime" label="上传时间" width="180">
          <template #default="scope">
            {{ formatDate(scope.row.createTime) }}
          </template>
        </el-table-column>
        <el-table-column prop="downloadCount" label="下载次数" width="100"></el-table-column>
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
        <el-table-column label="操作" width="220">
          <template #default="scope">
            <el-button type="primary" size="small" @click="handleDownload(scope.row)">
              <el-icon><Download /></el-icon>下载
            </el-button>
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

    <!-- 资源表单对话框 -->
    <el-dialog 
      v-model="dialogVisible" 
      :title="dialogTitle" 
      width="600px" 
      :close-on-click-modal="false"
      :before-close="handleDialogClose"
    >
      <el-form 
        ref="resourceFormRef" 
        :model="resourceForm" 
        :rules="resourceFormRules" 
        label-width="100px"
      >
        <el-form-item label="资源名称" prop="resourceName">
          <el-input v-model="resourceForm.resourceName"></el-input>
        </el-form-item>
        <el-form-item label="资源分类" prop="categoryId">
          <el-select v-model="resourceForm.categoryId" placeholder="请选择分类" style="width: 100%">
            <el-option v-for="item in categoryOptions" :key="item.id" :label="item.categoryName" :value="item.id"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="资源描述" prop="description">
          <el-input v-model="resourceForm.description" type="textarea" rows="3"></el-input>
        </el-form-item>
        <el-form-item label="资源文件" prop="file" v-if="dialogTitle === '上传资源'">
          <el-upload
            class="resource-upload"
            action="#"
            :auto-upload="false"
            :limit="1"
            :on-change="handleFileChange"
            :on-exceed="handleExceed"
            :on-remove="handleRemove"
          >
            <el-button type="primary">选择文件</el-button>
            <template #tip>
              <div class="el-upload__tip">请选择文件，大小不超过100MB</div>
            </template>
          </el-upload>
        </el-form-item>
        <el-form-item label="资源状态" prop="status">
          <el-radio-group v-model="resourceForm.status">
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
  resourceName: '',
  categoryId: '',
  username: '',
  status: ''
})

// 资源分类选项
const categoryOptions = ref([])

// 表格数据
const tableLoading = ref(false)
const tableData = ref([])
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)
const selectedRows = ref([])

// 表单对话框
const dialogVisible = ref(false)
const dialogTitle = ref('上传资源')
const resourceFormRef = ref(null)
const resourceForm = reactive({
  id: '',
  resourceName: '',
  categoryId: '',
  description: '',
  filePath: '',
  fileSize: 0,
  fileType: '',
  status: 1,
  file: null
})

// 表单验证规则
const resourceFormRules = {
  resourceName: [
    { required: true, message: '请输入资源名称', trigger: 'blur' },
    { min: 2, max: 100, message: '长度在 2 到 100 个字符', trigger: 'blur' }
  ],
  categoryId: [
    { required: true, message: '请选择资源分类', trigger: 'change' }
  ],
  file: [
    { required: true, message: '请选择文件', trigger: 'change' }
  ]
}

// 格式化文件大小
const formatFileSize = (size) => {
  if (!size) return '0 B'
  
  if (size < 1024) {
    return size + ' B'
  } else if (size < 1024 * 1024) {
    return (size / 1024).toFixed(2) + ' KB'
  } else {
    return (size / (1024 * 1024)).toFixed(2) + ' MB'
  }
}

// 获取文件类型标签
const getFileTypeLabel = (type) => {
  const typeMap = {
    'document': '文档',
    'image': '图片',
    'video': '视频',
    'audio': '音频',
    'archive': '压缩包',
    'other': '其他'
  }
  return typeMap[type] || '未知'
}

// 获取资源分类列表
const fetchCategories = () => {
  request.get('/resource/category/valid', null, {
    showDefaultMsg: false,
    onSuccess: (res) => {
      categoryOptions.value = res
    },
    onError: (error) => {
      console.error('获取资源分类列表失败:', error)
    }
  })
}

// 获取资源列表
const fetchResources = () => {
  tableLoading.value = true
  const params = {
    resourceName: searchForm.resourceName || undefined,
    categoryId: searchForm.categoryId || undefined,
    userId: searchForm.userId || undefined,
    status: searchForm.status === '' ? undefined : searchForm.status,
    currentPage: currentPage.value,
    size: pageSize.value
  }
  
  request.get('/resource/page', params, {
    showDefaultMsg: false,
    onSuccess: (res) => {
      tableData.value = res.records
      total.value = res.total
      tableLoading.value = false
    },
    onError: (error) => {
      console.error('获取资源列表失败:', error)
      tableLoading.value = false
    }
  })
}

// 搜索
const handleSearch = () => {
  currentPage.value = 1
  fetchResources()
}

// 重置搜索
const resetSearch = () => {
  Object.keys(searchForm).forEach(key => {
    searchForm[key] = ''
  })
  handleSearch()
}

// 刷新列表
const refreshResourceList = () => {
  fetchResources()
}

// 导出资源列表
const handleExport = () => {
  ElMessage.success('资源列表导出功能开发中')
  // TODO: 实现导出功能
}

// 表格选择项变化
const handleSelectionChange = (rows) => {
  selectedRows.value = rows
}

// 分页大小变化
const handleSizeChange = (val) => {
  pageSize.value = val
  fetchResources()
}

// 当前页变化
const handleCurrentChange = (val) => {
  currentPage.value = val
  fetchResources()
}

// 上传资源
const handleAdd = () => {
  dialogTitle.value = '上传资源'
  resourceForm.id = ''
  resourceForm.resourceName = ''
  resourceForm.categoryId = ''
  resourceForm.description = ''
  resourceForm.filePath = ''
  resourceForm.fileSize = 0
  resourceForm.fileType = ''
  resourceForm.status = 1
  resourceForm.file = null
  dialogVisible.value = true
}

// 编辑资源
const handleEdit = (row) => {
  dialogTitle.value = '编辑资源'
  Object.assign(resourceForm, {
    id: row.id,
    resourceName: row.resourceName,
    categoryId: row.categoryId,
    description: row.description,
    filePath: row.filePath,
    fileSize: row.fileSize,
    fileType: row.fileType,
    status: row.status
  })
  dialogVisible.value = true
}

// 删除资源
const handleDelete = (row) => {
  ElMessageBox.confirm('确认删除该资源吗？', '提示', {
    confirmButtonText: '确认',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    request.delete(`/resource/${row.id}`, null, {
      successMsg: '删除成功',
      onSuccess: () => {
        fetchResources()
      }
    })
  }).catch(() => {})
}

// 批量删除
const handleBatchDelete = () => {
  if (selectedRows.value.length === 0) return
  
  ElMessageBox.confirm(`确认批量删除选中的 ${selectedRows.value.length} 条资源记录吗？`, '提示', {
    confirmButtonText: '确认',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    const ids = selectedRows.value.map(item => item.id)
    request.delete('/resource/batch', { ids }, {
      successMsg: '批量删除成功',
      onSuccess: () => {
        fetchResources()
      }
    })
  }).catch(() => {})
}

// 更新资源状态
const handleStatusChange = (id, status) => {
  request.put(`/resource/${id}/status?status=${status}`, null, {
    successMsg: `状态已${status === 1 ? '启用' : '禁用'}`,
    onSuccess: () => {
      fetchResources()
    },
    onError: () => {
      fetchResources() // 更新失败时刷新列表
    }
  })
}

// 下载资源
const handleDownload = (row) => {
  // 增加下载次数
  request.put(`/resource/${row.id}/download`, null, {
    showDefaultMsg: false
  })
  
  // 执行下载操作
  ElMessage.success(`开始下载: ${row.resourceName}`)
  // TODO: 实现下载功能
  window.open(row.filePath, '_blank')
}

// 文件上传相关处理
const handleFileChange = (file) => {
  if (!file) return
  
  resourceForm.file = file.raw
  resourceForm.resourceName = resourceForm.resourceName || file.name
  
  // 获取文件扩展名作为文件类型
  resourceForm.fileType = file.name.split('.').pop().toLowerCase()
  resourceForm.fileSize = Math.floor(file.size / 1024) // 转为KB
}

const handleExceed = () => {
  ElMessage.warning('只能上传一个文件')
}

const handleRemove = () => {
  resourceForm.file = null
}

// 对话框关闭前的处理
const handleDialogClose = (done) => {
  resourceFormRef.value.resetFields()
  done()
}

// 提交表单
const handleSubmit = async () => {
  if (!resourceFormRef.value) return
  
  try {
    await resourceFormRef.value.validate()
    
    if (dialogTitle.value === '上传资源') {
      // 上传文件
      const formData = new FormData()
      formData.append('file', resourceForm.file)
      
      // TODO: 实现文件上传功能
      // 模拟文件上传成功后的处理
      const uploadResult = {
        filePath: `/uploads/${Date.now()}_${resourceForm.file.name}`,
        fileSize: resourceForm.fileSize,
        fileType: resourceForm.fileType
      }
      
      // 创建资源
      const resourceData = {
        resourceName: resourceForm.resourceName,
        categoryId: resourceForm.categoryId,
        description: resourceForm.description,
        filePath: uploadResult.filePath,
        fileSize: uploadResult.fileSize,
        fileType: uploadResult.fileType,
        status: resourceForm.status
      }
      
      request.post('/resource/add', resourceData, {
        successMsg: '资源上传成功',
        onSuccess: () => {
          dialogVisible.value = false
          fetchResources()
        }
      })
    } else {
      // 编辑资源
      const resourceData = {
        resourceName: resourceForm.resourceName,
        categoryId: resourceForm.categoryId,
        description: resourceForm.description,
        status: resourceForm.status
      }
      
      request.put(`/resource/${resourceForm.id}`, resourceData, {
        successMsg: '资源信息更新成功',
        onSuccess: () => {
          dialogVisible.value = false
          fetchResources()
        }
      })
    }
  } catch (error) {
    console.error('表单验证失败:', error)
  }
}

// 修改文件类型显示的样式
const getFileTypeColor = (type) => {
  const typeMap = {
    // Office 文档
    'doc': 'primary',
    'docx': 'primary',
    'ppt': 'danger',
    'pptx': 'danger',
    'xls': 'success',
    'xlsx': 'success',
    // PDF
    'pdf': 'warning',
    // 图片
    'jpg': 'info',
    'jpeg': 'info',
    'png': 'info',
    'gif': 'info',
    // 视频
    'mp4': 'success',
    'avi': 'success',
    // 压缩包
    'zip': 'warning',
    'rar': 'warning',
  }
  return typeMap[type] || ''
}

// 初始化
onMounted(() => {
  fetchCategories()
  fetchResources()
})
</script>

<style lang="scss" scoped>
.resource-management-container {
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
  
  .resource-upload {
    width: 100%;
  }
}
</style> 