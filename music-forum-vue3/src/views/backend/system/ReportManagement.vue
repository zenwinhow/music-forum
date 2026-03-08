<template>
  <div class="report-management-container">
    <!-- 搜索卡片 -->
    <el-card class="search-card">
      <div class="search-form">
        <el-form :model="searchForm" inline>
          <el-form-item label="举报原因">
            <el-input v-model="searchForm.reason" placeholder="请输入举报原因关键词" clearable></el-input>
          </el-form-item>
          <el-form-item label="举报类型">
            <el-select style="width: 150px" v-model="searchForm.type" placeholder="请选择类型" clearable>
              <el-option label="帖子" :value="1"></el-option>
              <el-option label="评论" :value="2"></el-option>
              <el-option label="资源" :value="3"></el-option>
            </el-select>
          </el-form-item>
          <el-form-item label="举报人">
            <el-input v-model="searchForm.username" placeholder="请输入举报人用户名" clearable></el-input>
          </el-form-item>
          <el-form-item label="处理状态">
            <el-select style="width: 150px" v-model="searchForm.status" placeholder="请选择状态" clearable>
              <el-option label="未处理" :value="0"></el-option>
              <el-option label="已处理" :value="1"></el-option>
              <el-option label="已驳回" :value="2"></el-option>
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
      <el-button type="primary" @click="refreshReportList">
        <el-icon><Refresh /></el-icon>刷新
      </el-button>
      <el-button type="danger" :disabled="selectedReports.length === 0" @click="handleBatchDelete">
        <el-icon><Delete /></el-icon>批量删除
      </el-button>
    </div>

    <!-- 数据表格 -->
    <el-card class="table-card">
      <el-table
        v-loading="tableLoading"
        :data="reportList"
        border
        stripe
        style="width: 100%"
        @selection-change="handleSelectionChange"
      >
        <el-table-column type="selection" width="55"></el-table-column>
        <el-table-column prop="id" label="ID" width="60"></el-table-column>
        <el-table-column prop="username" label="举报人" width="120"></el-table-column>
        <el-table-column prop="type" label="举报类型" width="100">
          <template #default="scope">
            <el-tag>{{ getReportTypeName(scope.row.type) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="targetContent" label="举报目标" width="180" show-overflow-tooltip></el-table-column>
        <el-table-column prop="reason" label="举报原因" show-overflow-tooltip></el-table-column>
        <el-table-column prop="createTime" label="举报时间" width="180">
          <template #default="scope">
            {{ formatDate(scope.row.createTime) }}
          </template>
        </el-table-column>
        <el-table-column prop="status" label="处理状态" width="100">
          <template #default="scope">
            <el-tag :type="getStatusTagType(scope.row.status)">
              {{ getStatusName(scope.row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="handlerName" label="处理人" width="120">
          <template #default="scope">
            {{ scope.row.handlerName || '无' }}
          </template>
        </el-table-column>
        <el-table-column prop="handleTime" label="处理时间" width="180">
          <template #default="scope">
            {{ scope.row.handleTime ? formatDate(scope.row.handleTime) : '无' }}
          </template>
        </el-table-column>
        <el-table-column label="操作" width="220">
          <template #default="scope">
            <el-tooltip effect="dark" :content="`处理后将自动下架该${getReportTypeName(scope.row.type)}`" placement="top">
              <el-button 
                v-if="scope.row.status === 0" 
                type="success" 
                @click="handleReportProcess(scope.row, 1)" 
                size="small"
              >
                处理并下架
              </el-button>
            </el-tooltip>
            <el-button 
              v-if="scope.row.status === 0" 
              type="warning" 
              @click="handleReportProcess(scope.row, 2)" 
              size="small"
            >
              驳回
            </el-button>
            <el-button 
              type="primary" 
              @click="handleDetail(scope.row)" 
              size="small"
            >
              <el-icon><View /></el-icon>详情
            </el-button>
            <el-button 
              type="danger" 
              @click="handleDelete(scope.row.id)" 
              size="small"
            >
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
          @update:current-page="currentPage = $event"
          @update:page-size="pageSize = $event"
          @size-change="handleSizeChange"
          @current-change="handleCurrentChange"
        ></el-pagination>
      </div>
    </el-card>

    <!-- 详情对话框 -->
    <el-dialog
      v-model="detailDialogVisible"
      title="举报详情"
      width="600px"
    >
      <el-descriptions :column="1" border>
        <el-descriptions-item label="举报ID">{{ currentReport.id }}</el-descriptions-item>
        <el-descriptions-item label="举报人">{{ currentReport.username }}</el-descriptions-item>
        <el-descriptions-item label="举报类型">{{ getReportTypeName(currentReport.type) }}</el-descriptions-item>
        <el-descriptions-item label="举报目标">{{ currentReport.targetContent }}</el-descriptions-item>
        <el-descriptions-item label="举报原因">{{ currentReport.reason }}</el-descriptions-item>
        <el-descriptions-item label="举报时间">{{ formatDate(currentReport.createTime) }}</el-descriptions-item>
        <el-descriptions-item label="处理状态">
          <el-tag :type="getStatusTagType(currentReport.status)">
            {{ getStatusName(currentReport.status) }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="处理人">{{ currentReport.handlerName || '无' }}</el-descriptions-item>
        <el-descriptions-item label="处理时间">{{ currentReport.handleTime ? formatDate(currentReport.handleTime) : '无' }}</el-descriptions-item>
      </el-descriptions>
      <div v-if="currentReport.status === 0" class="dialog-footer" style="margin-top: 20px;">
        <el-tooltip effect="dark" :content="`处理后将自动下架该${getReportTypeName(currentReport.type)}`" placement="top">
          <el-button type="success" @click="handleReportProcess(currentReport, 1)">处理并下架</el-button>
        </el-tooltip>
        <el-button type="warning" @click="handleReportProcess(currentReport, 2)">驳回</el-button>
      </div>
      <template #footer>
        <el-button @click="detailDialogVisible = false">关闭</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { Search, Refresh, Delete, View } from '@element-plus/icons-vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import request from '@/utils/request'
import { formatDate } from '@/utils/format'

// 搜索表单
const searchForm = reactive({
  reason: '',
  type: '',
  username: '',
  status: ''
})

// 分页相关
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)

// 表格相关
const tableLoading = ref(false)
const reportList = ref([])
const selectedReports = ref([])

// 详情对话框
const detailDialogVisible = ref(false)
const currentReport = reactive({
  id: '',
  username: '',
  type: 1,
  targetContent: '',
  reason: '',
  createTime: '',
  status: 0,
  handlerName: '',
  handleTime: ''
})

// 获取举报类型名称
const getReportTypeName = (type) => {
  switch (type) {
    case 1:
      return '帖子'
    case 2:
      return '评论'
    case 3:
      return '资源'
    default:
      return '未知'
  }
}

// 获取状态名称
const getStatusName = (status) => {
  switch (status) {
    case 0:
      return '未处理'
    case 1:
      return '已处理'
    case 2:
      return '已驳回'
    default:
      return '未知'
  }
}

// 获取状态标签类型
const getStatusTagType = (status) => {
  switch (status) {
    case 0:
      return 'warning'
    case 1:
      return 'success'
    case 2:
      return 'danger'
    default:
      return 'info'
  }
}

// 加载举报列表
const fetchReportList = async () => {
  tableLoading.value = true
  try {
    const params = {
      reason: searchForm.reason || undefined,
      type: searchForm.type === '' ? undefined : searchForm.type,
      username: searchForm.username || undefined,
      status: searchForm.status === '' ? undefined : searchForm.status,
      current: currentPage.value,
      size: pageSize.value
    }
    const response = await request.get('/report/page', params, {
      showDefaultMsg: false,
      onSuccess: (res) => {
        reportList.value = res.records
        total.value = res.total
      },
      onError: (err) => {
        console.error('获取举报列表失败:', err)
        ElMessage.error('获取举报列表失败')
      }
    })
  } catch (error) {
    console.error('获取举报列表失败:', error)
    ElMessage.error('获取举报列表失败')
  } finally {
    tableLoading.value = false
  }
}

// 搜索
const handleSearch = () => {
  currentPage.value = 1
  fetchReportList()
}

// 重置搜索
const resetSearch = () => {
  Object.keys(searchForm).forEach(key => {
    searchForm[key] = ''
  })
  currentPage.value = 1
  fetchReportList()
}

// 刷新列表
const refreshReportList = () => {
  fetchReportList()
}

// 表格选择项变化
const handleSelectionChange = (selection) => {
  selectedReports.value = selection
}

// 分页大小变化
const handleSizeChange = (val) => {
  pageSize.value = val
  fetchReportList()
}

// 当前页变化
const handleCurrentChange = (val) => {
  currentPage.value = val
  fetchReportList()
}

// 查看详情
const handleDetail = (row) => {
  Object.assign(currentReport, row)
  detailDialogVisible.value = true
}

// 处理举报
const handleReportProcess = async (row, status) => {
  const statusText = status === 1 ? '处理' : '驳回'
  const confirmText = status === 1 
    ? `确定要处理该举报吗？\n处理后将会自动下架被举报的${getReportTypeName(row.type)}！` 
    : `确定要驳回该举报吗？`
  
  ElMessageBox.confirm(confirmText, '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning',
    dangerouslyUseHTMLString: true
  }).then(async () => {
    try {
      const response = await request.put(`/report/${row.id}/handle?status=${status}`, null, {
        successMsg: status === 1 
          ? `举报处理成功，已下架被举报的${getReportTypeName(row.type)}` 
          : `举报已驳回`,
        onSuccess: (res) => {
          fetchReportList()
          if (detailDialogVisible.value) {
            detailDialogVisible.value = false
          }
        }
      })
    } catch (error) {
      console.error(`举报${statusText}失败:`, error)
      ElMessage.error(`举报${statusText}失败`)
    }
  }).catch(() => {})
}

// 删除举报
const handleDelete = (id) => {
  ElMessageBox.confirm('确定要删除该举报吗？此操作不可恢复！', '警告', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(async () => {
    try {
      const response = await request.delete(`/report/${id}`, null, {
        successMsg: '删除成功',
        onSuccess: (res) => {
          fetchReportList()
        }
      })
    } catch (error) {
      console.error('删除举报失败:', error)
      ElMessage.error('删除举报失败')
    }
  }).catch(() => {})
}

// 批量删除
const handleBatchDelete = () => {
  if (selectedReports.value.length === 0) {
    ElMessage.warning('请至少选择一条举报')
    return
  }
  
  ElMessageBox.confirm(`确定要删除选中的 ${selectedReports.value.length} 条举报吗？此操作不可恢复！`, '警告', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(async () => {
    try {
      const ids = selectedReports.value.map(item => item.id)
      const response = await request.delete('/report/batch?ids=' + ids, null, {
        successMsg: '批量删除成功',
        onSuccess: (res) => {
          fetchReportList()
        }
      })
    } catch (error) {
      console.error('批量删除举报失败:', error)
      ElMessage.error('批量删除举报失败')
    }
  }).catch(() => {})
}

// 组件挂载时获取举报列表
onMounted(() => {
  fetchReportList()
})
</script>

<style lang="scss" scoped>
.report-management-container {
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