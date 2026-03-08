<template>
  <div class="moderator-management">
    <!-- 搜索栏 -->
    <el-card class="search-card">
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="版区名称">
          <el-select v-model="searchForm.sectionId" placeholder="请选择版区" clearable filterable style="width: 230px">
            <el-option
              v-for="item in sectionOptions"
              :key="item.id"
              :label="item.sectionName"
              :value="item.id"
            ></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="用户名">
          <el-input v-model="searchForm.username" placeholder="请输入用户名" clearable />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="searchForm.status" placeholder="请选择状态" clearable style="width: 200px">
            <el-option :value="1" label="正常" />
            <el-option :value="0" label="停用" />
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
            <span class="title">版主列表</span>
            <el-button :icon="Refresh" circle @click="handleRefresh" />
          </div>
          <div class="right">
            <el-button :icon="Download" @click="handleExport">导出</el-button>
            <el-button type="danger" :disabled="selectedRows.length === 0" @click="handleBatchDelete">批量删除</el-button>
          </div>
        </div>
      </template>

      <!-- 表格 -->
      <el-table v-loading="loading" :data="tableData" border style="width: 100%" @selection-change="handleSelectionChange">
        <el-table-column type="selection" width="55" />
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="sectionName" label="版区名称" />
        <el-table-column prop="username" label="用户名" />
        <el-table-column prop="realName" label="真实姓名" />
        <el-table-column prop="appointTime" label="任命时间">
          <template #default="{ row }">
            {{ formatDate(row.appointTime) }}
          </template>
        </el-table-column>
        <el-table-column prop="appointByName" label="任命人" />
        <el-table-column prop="remark" label="备注" show-overflow-tooltip />
        <el-table-column prop="status" label="状态">
          <template #default="{ row }">
            <el-switch v-model="row.status" :active-value="1" :inactive-value="0" @change="(val) => handleStatusChange(row.id, val)" />
          </template>
        </el-table-column>
        <el-table-column label="操作" width="160">
          <template #default="{ row }">
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

    <!-- 编辑版主对话框 -->
    <el-dialog :title="dialogTitle" v-model="dialogVisible" width="500px" @close="resetForm">
      <el-form ref="moderatorFormRef" :model="moderatorForm" :rules="moderatorFormRules" label-width="100px">
        <el-form-item label="版区">
          <el-input v-model="moderatorForm.sectionName" disabled />
        </el-form-item>
        <el-form-item label="用户">
          <el-input v-model="moderatorForm.username" disabled />
        </el-form-item>
        <el-form-item label="备注" prop="remark">
          <el-input v-model="moderatorForm.remark" type="textarea" :rows="3" placeholder="请输入备注" />
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-radio-group v-model="moderatorForm.status">
            <el-radio :label="1">正常</el-radio>
            <el-radio :label="0">停用</el-radio>
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
import { ElMessage, ElMessageBox } from 'element-plus'
import { Refresh, Download } from '@element-plus/icons-vue'
import * as XLSX from 'xlsx'
import request from '@/utils/request'

// 搜索表单
const searchForm = reactive({
  sectionId: '',
  username: '',
  status: ''
})

// 版区选项
const sectionOptions = ref([])

// 表格数据
const loading = ref(false)
const tableData = ref([])
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)
const selectedRows = ref([])

// 版主表单对话框
const dialogVisible = ref(false)
const dialogTitle = ref('编辑版主')
const moderatorFormRef = ref(null)
const moderatorForm = reactive({
  id: '',
  sectionId: '',
  userId: '',
  sectionName: '',
  username: '',
  remark: '',
  status: 1
})

// 版主表单验证规则
const moderatorFormRules = {
  status: [
    { required: true, message: '请选择状态', trigger: 'change' }
  ]
}

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

// 获取所有版区列表
const fetchSections = () => {
  request.get('/section/all', null,{
    showDefaultMsg: false,
    onSuccess: (res) => {
      sectionOptions.value = res
    },
    onError: (error) => {
      console.error('获取版区列表失败:', error)
    }
  })
}

// 获取版主列表
const fetchModerators = () => {
  loading.value = true
  const params = {
    ...searchForm,
    currentPage: currentPage.value,
    size: pageSize.value
  }
  
  request.get('/moderator/page', params, {
    showDefaultMsg: false,
    onSuccess: (res) => {
      tableData.value = res.records
      total.value = res.total
      loading.value = false
    },
    onError: (error) => {
      console.error('获取版主列表失败:', error)
      loading.value = false
    }
  })
}

// 搜索
const handleSearch = () => {
  currentPage.value = 1
  fetchModerators()
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
  fetchModerators()
}

const handleCurrentChange = (val) => {
  currentPage.value = val
  fetchModerators()
}

// 编辑版主
const handleEdit = (row) => {
  dialogTitle.value = '编辑版主'
  Object.assign(moderatorForm, row)
  dialogVisible.value = true
}

// 删除版主
const handleDelete = async (row) => {
  try {
    await ElMessageBox.confirm('确认删除该版主吗？', '提示', {
      type: 'warning'
    })
    
    request.delete(`/moderator/${row.id}`, {
      successMsg: '删除成功',
      errorMsg: '删除失败',
      onSuccess: () => {
        fetchModerators()
      },
      onError: (error) => {
        console.error('删除版主失败:', error)
      }
    })
  } catch (error) {
    // 用户取消删除，不做处理
  }
}

// 修改版主状态
const handleStatusChange = (id, status) => {
  request.put(`/moderator/${id}/status?status=${status}`, null, {
    successMsg: '状态更新成功',
    errorMsg: '状态更新失败',
    onError: (error) => {
      console.error('修改状态失败:', error)
      fetchModerators() // 更新失败时刷新列表
    }
  })
}

// 提交版主表单
const handleSubmit = async () => {
  if (!moderatorFormRef.value) return

  try {
    await moderatorFormRef.value.validate()
    
    request.put(`/moderator/${moderatorForm.id}`, {
      id: moderatorForm.id,
      remark: moderatorForm.remark,
      status: moderatorForm.status
    }, {
      successMsg: '更新成功',
      errorMsg: '更新失败',
      onSuccess: () => {
        dialogVisible.value = false
        fetchModerators()
      },
      onError: (error) => {
        console.error('更新版主失败:', error)
      }
    })
  } catch (error) {
    console.error('表单验证失败:', error)
  }
}

// 重置表单
const resetForm = () => {
  if (moderatorFormRef.value) {
    moderatorFormRef.value.resetFields()
  }
}

// 刷新
const handleRefresh = () => {
  fetchModerators()
  ElMessage.success('刷新成功')
}

// 批量删除
const handleBatchDelete = async () => {
  if (selectedRows.value.length === 0) return
  
  try {
    await ElMessageBox.confirm(`确认删除选中的 ${selectedRows.value.length} 个版主吗？`, '提示', {
      type: 'warning'
    })
    
    const ids = selectedRows.value.map(row => row.id)
    request.delete(`/moderator/batch?ids=${ids}`, {
      successMsg: '批量删除成功',
      errorMsg: '批量删除失败',
      onSuccess: () => {
        fetchModerators()
      },
      onError: (error) => {
        console.error('批量删除失败:', error)
      }
    })
  } catch (error) {
    // 用户取消删除，不做处理
  }
}

// 导出数据
const handleExport = () => {
  try {
    loading.value = true
    
    // 定义要导出的列
    const columns = [
      { field: 'id', title: 'ID' },
      { field: 'sectionName', title: '版区名称' },
      { field: 'username', title: '用户名' },
      { field: 'realName', title: '真实姓名' },
      { field: 'appointTime', title: '任命时间' },
      { field: 'appointByName', title: '任命人' },
      { field: 'remark', title: '备注' },
      { field: 'status', title: '状态' }
    ]
    
    // 准备导出数据
    const exportData = tableData.value.map(item => {
      const row = {}
      columns.forEach(col => {
        if (col.field === 'status') {
          row[col.title] = item.status === 1 ? '正常' : '停用'
        } else if (col.field === 'appointTime') {
          row[col.title] = formatDate(item.appointTime)
        } else {
          row[col.title] = item[col.field]
        }
      })
      return row
    })

    // 创建工作簿
    const worksheet = XLSX.utils.json_to_sheet(exportData)
    const workbook = XLSX.utils.book_new()
    XLSX.utils.book_append_sheet(workbook, worksheet, '版主列表')

    // 导出文件
    const today = new Date()
    const year = today.getFullYear()
    const month = String(today.getMonth() + 1).padStart(2, '0')
    const day = String(today.getDate()).padStart(2, '0')
    XLSX.writeFile(workbook, `版主列表_${year}-${month}-${day}.xlsx`)
    
    ElMessage.success('导出成功')
  } catch (error) {
    console.error('导出失败:', error)
    ElMessage.error('导出失败')
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  fetchSections()
  fetchModerators()
})
</script>

<style scoped>
.moderator-management {
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
</style> 