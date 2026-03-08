<template>
  <div class="notification-management">
    <!-- 搜索栏 -->
    <el-card class="search-card">
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="通知标题">
          <el-input v-model="searchForm.title" placeholder="请输入通知标题" clearable />
        </el-form-item>
        <el-form-item label="状态">
          <el-select 
            v-model="searchForm.status" 
            placeholder="请选择状态" 
            clearable
            style="width: 200px"
          >
            <el-option :value="1" label="已发布" />
            <el-option :value="0" label="已下线" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">搜索</el-button>
          <el-button @click="resetSearch">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 操作栏 -->
    <el-card class="table-card">
      <template #header>
        <div class="card-header">
          <div class="left">
            <span class="title">通知列表</span>
            <el-button :icon="Refresh" circle @click="handleRefresh" />
          </div>
          <div class="right">
            <el-button :icon="Download" @click="handleExport">导出</el-button>
            <el-button :icon="Setting" @click="columnSettingVisible = true">列设置</el-button>
            <el-button type="danger" :disabled="selectedRows.length === 0" @click="handleBatchDelete">批量删除</el-button>
            <el-button type="primary" @click="handleAdd">新增通知</el-button>
          </div>
        </div>
      </template>
      
      <!-- 表格 -->
      <el-table v-loading="loading" :data="tableData" border style="width: 100%" @selection-change="handleSelectionChange">
        <el-table-column type="selection" width="55" />
        <el-table-column v-if="isColumnVisible('title')" prop="title" label="通知标题" show-overflow-tooltip />
        <el-table-column v-if="isColumnVisible('content')" prop="content" label="通知内容" show-overflow-tooltip />
        <el-table-column v-if="isColumnVisible('status')" prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-switch v-model="row.status" :active-value="1" :inactive-value="0" @change="(val) => handleStatusChange(row.id, val)" />
          </template>
        </el-table-column>
        <el-table-column v-if="isColumnVisible('createTime')" prop="createTime" label="发布时间" width="180">
          <template #default="{ row }">
            {{ formatDate(row.createTime) }}
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200">
          <template #default="{ row }">
            <el-button type="primary" link @click="handleView(row)">查看</el-button>
            <el-button type="primary" link @click="handleEdit(row)">编辑</el-button>
            <el-button type="danger" link @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
      
      <!-- 分页 -->
      <div class="pagination">
        <el-pagination
          :current-page="currentPage"
          :page-size="pageSize"
          :total="total"
          :page-sizes="[10, 20, 50, 100]"
          layout="total, sizes, prev, pager, next, jumper"
          @update:current-page="currentPage = $event"
          @update:page-size="pageSize = $event"
          @size-change="handleSizeChange"
          @current-change="handleCurrentChange"
        />
      </div>
    </el-card>
    
    <!-- 通知表单对话框 -->
    <el-dialog :title="dialogTitle" v-model="dialogVisible" width="60%" @close="resetForm">
      <el-form ref="notificationFormRef" :model="notificationForm" :rules="notificationFormRules" label-width="100px">
        <el-form-item label="通知标题" prop="title">
          <el-input v-model="notificationForm.title" placeholder="请输入通知标题" />
        </el-form-item>
        <el-form-item label="通知内容" prop="content">
          <el-input v-model="notificationForm.content" type="textarea" :rows="10" placeholder="请输入通知内容" />
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-radio-group v-model="notificationForm.status">
            <el-radio :label="1">发布</el-radio>
            <el-radio :label="0">下线</el-radio>
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

    <!-- 查看通知对话框 -->
    <el-dialog title="查看通知" v-model="viewDialogVisible" width="60%">
      <div class="notification-view">
        <h2 class="notification-title">{{ viewData.title }}</h2>
        <div class="notification-meta">
          <span>发布时间：{{ formatDate(viewData.createTime) }}</span>
          <span>状态：{{ viewData.status === 1 ? '已发布' : '已下线' }}</span>
        </div>
        <div class="notification-content">{{ viewData.content }}</div>
      </div>
    </el-dialog>

    <!-- 列设置抽屉 -->
    <el-drawer
      v-model="columnSettingVisible"
      title="列设置"
      direction="rtl"
      size="300px"
    >
      <el-checkbox-group v-model="visibleColumns" class="column-list">
        <el-checkbox v-for="col in allColumns" :key="col.prop" :label="col.prop">
          {{ col.label }}
        </el-checkbox>
      </el-checkbox-group>
    </el-drawer>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, watch } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Refresh, Download, Setting } from '@element-plus/icons-vue'
import * as XLSX from 'xlsx'
import request from '@/utils/request'

// 搜索表单
const searchForm = reactive({
  title: '',
  status: ''
})

// 表格数据
const loading = ref(false)
const tableData = ref([])
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)
const selectedRows = ref([])

// 表单对话框
const dialogVisible = ref(false)
const dialogTitle = ref('新增通知')
const notificationFormRef = ref(null)
const notificationForm = reactive({
  id: '',
  title: '',
  content: '',
  status: 1
})

// 表单验证规则
const notificationFormRules = {
  title: [
    { required: true, message: '请输入通知标题', trigger: 'blur' },
    { min: 2, max: 200, message: '长度在 2 到 200 个字符', trigger: 'blur' }
  ],
  content: [
    { required: true, message: '请输入通知内容', trigger: 'blur' }
  ]
}

// 查看通知对话框
const viewDialogVisible = ref(false)
const viewData = reactive({
  id: '',
  title: '',
  content: '',
  createTime: '',
  status: 1
})

// 格式化日期
const formatDate = (date) => {
  if (!date) return ''
  const d = new Date(date)
  const year = d.getFullYear()
  const month = String(d.getMonth() + 1).padStart(2, '0')
  const day = String(d.getDate()).padStart(2, '0')
  const hour = String(d.getHours()).padStart(2, '0')
  const minute = String(d.getMinutes()).padStart(2, '0')
  const second = String(d.getSeconds()).padStart(2, '0')
  return `${year}-${month}-${day} ${hour}:${minute}:${second}`
}

// 获取通知列表
const fetchNotifications = () => {
  loading.value = true
  const params = {
    ...searchForm,
    currentPage: currentPage.value,
    size: pageSize.value
  }
  
  request.get('/notification/page', params, {
    showDefaultMsg: false,
    onSuccess: (res) => {
      tableData.value = res.records
      total.value = res.total
      loading.value = false
    },
    onError: (error) => {
      console.error('获取通知列表失败:', error)
    }
  })
}

// 搜索
const handleSearch = () => {
  currentPage.value = 1
  fetchNotifications()
}

// 重置搜索
const resetSearch = () => {
  Object.keys(searchForm).forEach(key => {
    searchForm[key] = ''
  })
  handleSearch()
}

// 表格选择
const handleSelectionChange = (rows) => {
  selectedRows.value = rows
}

// 分页
const handleSizeChange = (val) => {
  pageSize.value = val
  fetchNotifications()
}

const handleCurrentChange = (val) => {
  currentPage.value = val
  fetchNotifications()
}

// 新增通知
const handleAdd = () => {
  dialogTitle.value = '新增通知'
  notificationForm.id = ''
  notificationForm.title = ''
  notificationForm.content = ''
  notificationForm.status = 1
  dialogVisible.value = true
}

// 编辑通知
const handleEdit = (row) => {
  dialogTitle.value = '编辑通知'
  Object.assign(notificationForm, row)
  dialogVisible.value = true
}

// 查看通知
const handleView = (row) => {
  Object.assign(viewData, row)
  viewDialogVisible.value = true
}

// 删除通知
const handleDelete = async (row) => {
  try {
    await ElMessageBox.confirm('确认删除该通知吗？', '提示', {
      type: 'warning'
    })
    
    request.delete(`/notification/${row.id}`, {
      successMsg: '删除成功',
      errorMsg: '删除失败',
      onSuccess: () => {
        fetchNotifications()
      },
      onError: (error) => {
        console.error('删除通知失败:', error)
      }
    })
  } catch (error) {
    // 用户取消删除，不做处理
  }
}

// 修改通知状态
const handleStatusChange = (id, status) => {
  request.put(`/notification/${id}/status?status=${status}`, null, {
    successMsg: '状态更新成功',
    errorMsg: '状态更新失败',
    onError: (error) => {
      console.error('修改状态失败:', error)
    }
  })
}

// 提交表单
const handleSubmit = async () => {
  if (!notificationFormRef.value) return

  try {
    await notificationFormRef.value.validate()
    
    if (notificationForm.id) {
      // 编辑
      request.put(`/notification/${notificationForm.id}`, notificationForm, {
        successMsg: '更新成功',
        errorMsg: '更新失败',
        onSuccess: () => {
          dialogVisible.value = false
          fetchNotifications()
        },
        onError: (error) => {
          console.error('更新通知失败:', error)
        }
      })
  } else {
      // 新增
      request.post('/notification/add', notificationForm, {
        successMsg: '创建成功',
        errorMsg: '创建失败',
        onSuccess: () => {
  dialogVisible.value = false
          fetchNotifications()
        },
        onError: (error) => {
          console.error('创建通知失败:', error)
        }
      })
    }
  } catch (error) {
    console.error('表单验证失败:', error)
  }
}

// 重置表单
const resetForm = () => {
  if (notificationFormRef.value) {
    notificationFormRef.value.resetFields()
  }
}

// 刷新
const handleRefresh = () => {
  fetchNotifications()
  ElMessage.success('刷新成功')
}

// 批量删除
const handleBatchDelete = async () => {
  if (selectedRows.value.length === 0) return
  
  try {
    await ElMessageBox.confirm(`确认删除选中的 ${selectedRows.value.length} 个通知吗？`, '提示', {
      type: 'warning'
    })
    
    const ids = selectedRows.value.map(row => row.id)
    request.delete('/notification/batch', { 
      data: ids 
    }, {
      successMsg: '批量删除成功',
      errorMsg: '批量删除失败',
      onSuccess: () => {
        fetchNotifications()
      },
      onError: (error) => {
        console.error('批量删除失败:', error)
      }
    })
  } catch (error) {
    // 用户取消删除，不做处理
  }
}

// 列设置相关
const STORAGE_KEY = 'notificationManagementVisibleColumns'
const columnSettingVisible = ref(false)
const allColumns = [
  { prop: 'title', label: '通知标题' },
  { prop: 'content', label: '通知内容' },
  { prop: 'status', label: '状态' },
  { prop: 'createTime', label: '发布时间' }
]

// 从localStorage获取保存的列设置，如果没有则使用默认值
const visibleColumns = ref(
  JSON.parse(localStorage.getItem(STORAGE_KEY)) || allColumns.map(col => col.prop)
)

// 监听列设置变化并保存到localStorage
watch(visibleColumns, (newVal) => {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(newVal))
}, { deep: true })

const isColumnVisible = (prop) => {
  return visibleColumns.value.includes(prop)
}

// 导出数据
const handleExport = () => {
  try {
    loading.value = true
    
    // 获取当前可见列的配置
    const visibleColumnConfigs = allColumns.filter(col => isColumnVisible(col.prop))
    
    // 准备导出数据
    const exportData = tableData.value.map(item => {
      const row = {}
      visibleColumnConfigs.forEach(col => {
        if (col.prop === 'status') {
          row[col.label] = item.status === 1 ? '已发布' : '已下线'
        } else if (col.prop === 'createTime') {
          row[col.label] = formatDate(item.createTime)
        } else {
          row[col.label] = item[col.prop]
        }
      })
      return row
    })

    // 创建工作簿
    const worksheet = XLSX.utils.json_to_sheet(exportData)
    const workbook = XLSX.utils.book_new()
    XLSX.utils.book_append_sheet(workbook, worksheet, '通知列表')

    // 导出文件
    const today = new Date()
    const year = today.getFullYear()
    const month = String(today.getMonth() + 1).padStart(2, '0')
    const day = String(today.getDate()).padStart(2, '0')
    XLSX.writeFile(workbook, `通知列表_${year}-${month}-${day}.xlsx`)
    
    ElMessage.success('导出成功')
  } catch (error) {
    console.error('导出失败:', error)
    ElMessage.error('导出失败')
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  fetchNotifications()
})
</script>

<style scoped>
.notification-management {
  padding: 20px;
}

.search-card {
  margin-bottom: 20px;
}
  
  .card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }
  
.card-header .left {
  display: flex;
  align-items: center;
  gap: 10px;
}

.card-header .right {
  display: flex;
  gap: 10px;
}

.title {
  font-size: 16px;
  font-weight: bold;
}

.pagination {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
}

.search-form {
    display: flex;
    flex-wrap: wrap;
    gap: 10px;
}

:deep(.el-form-item) {
  margin-bottom: 0;
}

:deep(.el-select) {
  width: 100%;
  }
  
.column-list {
  display: flex;
  flex-direction: column;
  gap: 10px;
  padding: 20px;
}

.notification-view {
  padding: 20px;
  }
  
.notification-title {
  text-align: center;
  margin-bottom: 20px;
  font-size: 24px;
}

.notification-meta {
    display: flex;
  justify-content: space-between;
  color: #666;
  font-size: 14px;
  margin-bottom: 30px;
  border-bottom: 1px solid #eee;
  padding-bottom: 10px;
  }

.notification-content {
  line-height: 1.8;
  font-size: 16px;
  white-space: pre-wrap;
}
</style> 