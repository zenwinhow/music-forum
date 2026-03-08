<template>
  <div class="section-management">
    <!-- 搜索栏 -->
    <el-card class="search-card">
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="版区名称">
          <el-input v-model="searchForm.sectionName" placeholder="请输入版区名称" clearable />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="searchForm.status" placeholder="请选择状态" clearable style="width: 200px">
            <el-option :value="1" label="正常" />
            <el-option :value="0" label="禁用" />
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
            <span class="title">版区列表</span>
            <el-button :icon="Refresh" circle @click="handleRefresh" />
          </div>
          <div class="right">
            <el-button :icon="Download" @click="handleExport">导出</el-button>
            <el-button type="danger" :disabled="selectedRows.length === 0" @click="handleBatchDelete">批量删除</el-button>
            <el-button type="primary" @click="handleAdd">新增版区</el-button>
          </div>
        </div>
      </template>

      <!-- 表格 -->
      <el-table v-loading="loading" :data="tableData" border style="width: 100%" @selection-change="handleSelectionChange">
        <el-table-column type="selection" width="55" />
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="sectionName" label="版区名称" />
        <el-table-column prop="description" label="版区描述" show-overflow-tooltip />
        <el-table-column prop="createTime" label="创建时间">
          <template #default="{ row }">
            {{ formatDate(row.createTime) }}
          </template>
        </el-table-column>
        <el-table-column prop="status" label="状态">
          <template #default="{ row }">
            <el-switch v-model="row.status" :active-value="1" :inactive-value="0" @change="(val) => handleStatusChange(row.id, val)" />
          </template>
        </el-table-column>
        <el-table-column label="操作" width="280">
          <template #default="{ row }">
            <el-button type="primary" link @click="handleEdit(row)">编辑</el-button>
            <el-button type="primary" link @click="handleModerators(row)">版主管理</el-button>
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

    <!-- 版区表单对话框 -->
    <el-dialog :title="dialogTitle" v-model="dialogVisible" width="500px" @close="resetForm">
      <el-form ref="sectionFormRef" :model="sectionForm" :rules="sectionFormRules" label-width="100px">
        <el-form-item label="版区名称" prop="sectionName">
          <el-input v-model="sectionForm.sectionName" placeholder="请输入版区名称" />
        </el-form-item>
        <el-form-item label="版区描述" prop="description">
          <el-input v-model="sectionForm.description" type="textarea" :rows="3" placeholder="请输入版区描述" />
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-radio-group v-model="sectionForm.status">
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

    <!-- 版主管理对话框 -->
    <el-dialog title="版主管理" v-model="moderatorDialogVisible" width="800px">
      <div class="moderator-header">
        <h3>{{ currentSection?.sectionName }} - 版主列表</h3>
        <el-button type="primary" @click="handleAddModerator">添加版主</el-button>
      </div>
      
      <el-table v-loading="moderatorLoading" :data="moderators" border style="width: 100%; margin-top: 20px;">
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
            <el-switch v-model="row.status" :active-value="1" :inactive-value="0" @change="(val) => handleModeratorStatusChange(row.id, val)" />
          </template>
        </el-table-column>
        <el-table-column label="操作" width="160">
          <template #default="{ row }">
            <el-button type="primary" link @click="handleEditModerator(row)">编辑</el-button>
            <el-button type="danger" link @click="handleDeleteModerator(row)">移除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-dialog>

    <!-- 添加/编辑版主对话框 -->
    <el-dialog :title="moderatorFormTitle" v-model="moderatorFormVisible" width="500px" @close="resetModeratorForm">
      <el-form ref="moderatorFormRef" :model="moderatorForm" :rules="moderatorFormRules" label-width="100px">
        <el-form-item label="用户" prop="userId" v-if="!moderatorForm.id">
          <el-select v-model="moderatorForm.userId" placeholder="请选择用户" filterable remote :remote-method="searchUsers" :loading="userSearchLoading">
            <el-option
              v-for="item in userOptions"
              :key="item.id"
              :label="`${item.username}${item.realName ? ' (' + item.realName + ')' : ''}`"
              :value="item.id"
            ></el-option>
          </el-select>
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
          <el-button @click="moderatorFormVisible = false">取消</el-button>
          <el-button type="primary" @click="submitModeratorForm">确定</el-button>
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
import { useUserStore } from '@/store/user'

const userStore = useUserStore();

// 搜索表单
const searchForm = reactive({
  sectionName: '',
  status: ''
})

// 表格数据
const loading = ref(false)
const tableData = ref([])
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)
const selectedRows = ref([])

// 版区表单对话框
const dialogVisible = ref(false)
const dialogTitle = ref('新增版区')
const sectionFormRef = ref(null)
const sectionForm = reactive({
  id: '',
  sectionName: '',
  description: '',
  status: 1
})

// 版区表单验证规则
const sectionFormRules = {
  sectionName: [
    { required: true, message: '请输入版区名称', trigger: 'blur' },
    { min: 2, max: 100, message: '长度在 2 到 100 个字符', trigger: 'blur' }
  ],
  description: [
    { max: 500, message: '长度不能超过 500 个字符', trigger: 'blur' }
  ]
}

// 版主管理相关
const moderatorDialogVisible = ref(false)
const moderatorLoading = ref(false)
const moderators = ref([])
const currentSection = ref(null)

// 添加/编辑版主表单
const moderatorFormVisible = ref(false)
const moderatorFormTitle = ref('添加版主')
const moderatorFormRef = ref(null)
const moderatorForm = reactive({
  id: '',
  sectionId: '',
  userId: '',
  remark: '',
  status: 1
})

// 版主表单验证规则
const moderatorFormRules = {
  userId: [
    { required: true, message: '请选择用户', trigger: 'change' }
  ]
}

// 用户选择相关
const userSearchLoading = ref(false)
const userOptions = ref([])

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

// 获取版区列表
const fetchSections = () => {
  loading.value = true
  const params = {
    ...searchForm,
    currentPage: currentPage.value,
    size: pageSize.value
  }
  
  request.get('/section/page', params, {
    showDefaultMsg: false,
    onSuccess: (res) => {
      tableData.value = res.records
      total.value = res.total
      loading.value = false
    },
    onError: (error) => {
      console.error('获取版区列表失败:', error)
      loading.value = false
    }
  })
}

// 搜索
const handleSearch = () => {
  currentPage.value = 1
  fetchSections()
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
  fetchSections()
}

const handleCurrentChange = (val) => {
  currentPage.value = val
  fetchSections()
}

// 新增版区
const handleAdd = () => {
  dialogTitle.value = '新增版区'
  sectionForm.id = ''
  sectionForm.sectionName = ''
  sectionForm.description = ''
  sectionForm.status = 1
  dialogVisible.value = true
}

// 编辑版区
const handleEdit = (row) => {
  dialogTitle.value = '编辑版区'
  Object.assign(sectionForm, row)
  dialogVisible.value = true
}

// 删除版区
const handleDelete = async (row) => {
  try {
    await ElMessageBox.confirm('确认删除该版区吗？', '提示', {
      type: 'warning'
    })
    
    request.delete(`/section/${row.id}`, {
      successMsg: '删除成功',
      errorMsg: '删除失败',
      onSuccess: () => {
        fetchSections()
      },
      onError: (error) => {
        console.error('删除版区失败:', error)
      }
    })
  } catch (error) {
    // 用户取消删除，不做处理
  }
}

// 修改版区状态
const handleStatusChange = (id, status) => {
  request.put(`/section/${id}/status?status=${status}`, null, {
    successMsg: '状态更新成功',
    errorMsg: '状态更新失败',
    onError: (error) => {
      console.error('修改状态失败:', error)
      fetchSections() // 更新失败时刷新列表
    }
  })
}

// 提交版区表单
const handleSubmit = async () => {
  if (!sectionFormRef.value) return

  try {
    await sectionFormRef.value.validate()
    
    if (sectionForm.id) {
      // 编辑
      request.put(`/section/${sectionForm.id}`, sectionForm, {
        successMsg: '更新成功',
        errorMsg: '更新失败',
        onSuccess: () => {
          dialogVisible.value = false
          fetchSections()
        },
        onError: (error) => {
          console.error('更新版区失败:', error)
        }
      })
    } else {
      // 新增
      request.post('/section/add', sectionForm, {
        successMsg: '创建成功',
        errorMsg: '创建失败',
        onSuccess: () => {
          dialogVisible.value = false
          fetchSections()
        },
        onError: (error) => {
          console.error('创建版区失败:', error)
        }
      })
    }
  } catch (error) {
    console.error('表单验证失败:', error)
  }
}

// 重置表单
const resetForm = () => {
  if (sectionFormRef.value) {
    sectionFormRef.value.resetFields()
  }
}

// 刷新
const handleRefresh = () => {
  fetchSections()
  ElMessage.success('刷新成功')
}

// 批量删除
const handleBatchDelete = async () => {
  if (selectedRows.value.length === 0) return
  
  try {
    await ElMessageBox.confirm(`确认删除选中的 ${selectedRows.value.length} 个版区吗？`, '提示', {
      type: 'warning'
    })
    
    const ids = selectedRows.value.map(row => row.id)
    request.delete(`/section/batch?ids=${ids}`, {
      successMsg: '批量删除成功',
      errorMsg: '批量删除失败',
      onSuccess: () => {
        fetchSections()
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
      { field: 'description', title: '版区描述' },
      { field: 'createTime', title: '创建时间' },
      { field: 'status', title: '状态' }
    ]
    
    // 准备导出数据
    const exportData = tableData.value.map(item => {
      const row = {}
      columns.forEach(col => {
        if (col.field === 'status') {
          row[col.title] = item.status === 1 ? '正常' : '禁用'
        } else if (col.field === 'createTime') {
          row[col.title] = formatDate(item.createTime)
        } else {
          row[col.title] = item[col.field]
        }
      })
      return row
    })

    // 创建工作簿
    const worksheet = XLSX.utils.json_to_sheet(exportData)
    const workbook = XLSX.utils.book_new()
    XLSX.utils.book_append_sheet(workbook, worksheet, '版区列表')

    // 导出文件
    const today = new Date()
    const year = today.getFullYear()
    const month = String(today.getMonth() + 1).padStart(2, '0')
    const day = String(today.getDate()).padStart(2, '0')
    XLSX.writeFile(workbook, `版区列表_${year}-${month}-${day}.xlsx`)
    
    ElMessage.success('导出成功')
  } catch (error) {
    console.error('导出失败:', error)
    ElMessage.error('导出失败')
  } finally {
    loading.value = false
  }
}

// 打开版主管理对话框
const handleModerators = (row) => {
  currentSection.value = row
  moderatorForm.sectionId = row.id
  moderatorDialogVisible.value = true
  fetchModerators(row.id)
}

// 获取版主列表
const fetchModerators = (sectionId) => {
  moderatorLoading.value = true
  request.get(`/moderator/section/${sectionId}`,null, {
    showDefaultMsg: false,
    onSuccess: (res) => {
      moderators.value = res
      moderatorLoading.value = false
    },
    onError: (error) => {
      console.error('获取版主列表失败:', error)
      moderatorLoading.value = false
    }
  })
}

// 添加版主
const handleAddModerator = () => {
  moderatorFormTitle.value = '添加版主'
  moderatorForm.id = ''
  moderatorForm.userId = ''
  moderatorForm.remark = ''
  moderatorForm.status = 1
  moderatorFormVisible.value = true
}

// 编辑版主
const handleEditModerator = (row) => {
  moderatorFormTitle.value = '编辑版主'
  moderatorForm.id = row.id
  moderatorForm.userId = row.userId
  moderatorForm.remark = row.remark
  moderatorForm.status = row.status
  moderatorFormVisible.value = true
}

// 删除版主
const handleDeleteModerator = async (row) => {
  try {
    await ElMessageBox.confirm('确认移除该版主吗？', '提示', {
      type: 'warning'
    })
    
    request.delete(`/moderator/${row.id}`, {
      successMsg: '移除成功',
      errorMsg: '移除失败',
      onSuccess: () => {
        fetchModerators(currentSection.value.id)
      },
      onError: (error) => {
        console.error('移除版主失败:', error)
      }
    })
  } catch (error) {
    // 用户取消删除，不做处理
  }
}

// 修改版主状态
const handleModeratorStatusChange = (id, status) => {
  request.put(`/moderator/${id}/status?status=${status}`, null, {
    successMsg: '状态更新成功',
    errorMsg: '状态更新失败',
    onSuccess: () => {
      fetchModerators(currentSection.value.id)
    },
    onError: (error) => {
      console.error('修改状态失败:', error)
    }
  })
}

// 重置版主表单
const resetModeratorForm = () => {
  if (moderatorFormRef.value) {
    moderatorFormRef.value.resetFields()
  }
}

// 提交版主表单
const submitModeratorForm = async () => {
  if (!moderatorFormRef.value) return

  try {
    await moderatorFormRef.value.validate()
    
    if (moderatorForm.id) {
      // 编辑
      request.put(`/moderator/${moderatorForm.id}`, moderatorForm, {
        successMsg: '更新成功',
        errorMsg: '更新失败',
        onSuccess: () => {
          moderatorFormVisible.value = false
          fetchModerators(currentSection.value.id)
        },
        onError: (error) => {
          console.error('更新版主失败:', error)
        }
      })
    } else {
      // 新增
      request.post('/moderator/appoint', {
        sectionId: moderatorForm.sectionId,
        userId: moderatorForm.userId,
        remark: moderatorForm.remark,
        status: moderatorForm.status
      }, {
        params: {
          appointBy: userStore.userId
        },
        successMsg: '任命成功',
        errorMsg: '任命失败',
        onSuccess: () => {
          moderatorFormVisible.value = false
          fetchModerators(currentSection.value.id)
        },
        onError: (error) => {
          console.error('任命版主失败:', error)
        }
      })
    }
  } catch (error) {
    console.error('表单验证失败:', error)
  }
}

// 搜索用户
const searchUsers = (query) => {
  if (query.length < 1) {
    userOptions.value = []
    return
  }
  
  userSearchLoading.value = true
  request.get('/user/page', {
    username: query,
    currentPage: 1,
    size: 20
  }, {
    showDefaultMsg: false,
    onSuccess: (res) => {
      userOptions.value = res.records
      userSearchLoading.value = false
    },
    onError: (error) => {
      console.error('搜索用户失败:', error)
      userSearchLoading.value = false
    }
  })
}

onMounted(() => {
  fetchSections()
})
</script>

<style scoped>
.section-management {
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

.moderator-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.moderator-header h3 {
  margin: 0;
  font-size: 16px;
}
</style> 