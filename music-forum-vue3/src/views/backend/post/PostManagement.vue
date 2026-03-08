<template>
  <div class="post-management">
    <!-- 搜索栏 -->
    <el-card class="search-card">
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="标题">
          <el-input v-model="searchForm.title" placeholder="请输入帖子标题" clearable />
        </el-form-item>
        <el-form-item label="版区">
          <el-select v-model="searchForm.sectionId" placeholder="请选择版区" clearable style="width: 200px">
            <el-option
              v-for="item in sectionOptions"
              :key="item.id"
              :label="item.sectionName"
              :value="item.id"
            ></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="是否精华">
          <el-select v-model="searchForm.isEssence" placeholder="请选择精华状态" clearable style="width: 200px">
            <el-option :value="1" label="精华" />
            <el-option :value="0" label="普通" />
          </el-select>
        </el-form-item>
        <el-form-item label="状态">
          <el-select  v-model="searchForm.status" placeholder="请选择状态" clearable style="width: 200px">
            <el-option :value="1" label="正常" />
            <el-option :value="0" label="已删除" />
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
            <span class="title">帖子列表</span>
            <el-button :icon="Refresh" circle @click="handleRefresh" />
          </div>
          <div class="right">
            <el-button :icon="Download" @click="handleExport">导出</el-button>
            <el-button type="danger" :disabled="selectedRows.length === 0" @click="handleBatchDelete">批量删除</el-button>
            <el-button type="primary" @click="handleAdd">新增帖子</el-button>
          </div>
        </div>
      </template>

      <!-- 表格 -->
      <el-table v-loading="loading" :data="tableData" border style="width: 100%" @selection-change="handleSelectionChange">
        <el-table-column type="selection" width="55" />
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="title" label="标题" min-width="200">
          <template #default="{ row }">
            <span class="post-title">{{ row.title }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="username" label="发帖人" width="120" />
        <el-table-column prop="sectionName" label="所属版区" width="120" />
        <el-table-column prop="createTime" label="发布时间" width="180">
          <template #default="{ row }">
            {{ formatDate(row.createTime) }}
          </template>
        </el-table-column>
        <el-table-column prop="viewCount" label="浏览次数" width="100" />
        <el-table-column prop="isEssence" label="是否精华" width="100">
          <template #default="{ row }">
            <el-tag :type="row.isEssence === 1 ? 'success' : 'info'">
              {{ row.isEssence === 1 ? '精华' : '普通' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-switch v-model="row.status" :active-value="1" :inactive-value="0" @change="(val) => handleStatusChange(row.id, val)" />
          </template>
        </el-table-column>
        <el-table-column label="操作" width="250">
          <template #default="{ row }">
            <el-button type="primary" link @click="handleEdit(row)">编辑</el-button>
            <el-button type="success" link @click="handleToggleEssence(row)">
              {{ row.isEssence === 1 ? '取消精华' : '设为精华' }}
            </el-button>
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

    <!-- 帖子表单对话框 -->
    <el-dialog :title="dialogTitle" v-model="dialogVisible" width="650px" @close="resetForm">
      <el-form ref="postFormRef" :model="postForm" :rules="postFormRules" label-width="100px">
        <el-form-item label="标题" prop="title">
          <el-input v-model="postForm.title" placeholder="请输入帖子标题" />
        </el-form-item>
        <el-form-item label="版区" prop="sectionId">
          <el-select v-model="postForm.sectionId" placeholder="请选择版区" style="width: 100%">
            <el-option
              v-for="item in sectionOptions"
              :key="item.id"
              :label="item.sectionName"
              :value="item.id"
            ></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="内容" prop="content">
          <el-input v-model="postForm.content" type="textarea" :rows="10" placeholder="请输入帖子内容" />
        </el-form-item>
        <el-form-item label="是否精华" prop="isEssence">
          <el-radio-group v-model="postForm.isEssence">
            <el-radio :label="1">精华</el-radio>
            <el-radio :label="0">普通</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-radio-group v-model="postForm.status">
            <el-radio :label="1">正常</el-radio>
            <el-radio :label="0">删除</el-radio>
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
  title: '',
  sectionId: '',
  isEssence: '',
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

// 表单对话框
const dialogVisible = ref(false)
const dialogTitle = ref('新增帖子')
const postFormRef = ref(null)
const postForm = reactive({
  id: '',
  title: '',
  sectionId: '',
  content: '',
  isEssence: 0,
  status: 1
})

// 表单验证规则
const postFormRules = {
  title: [
    { required: true, message: '请输入帖子标题', trigger: 'blur' },
    { min: 2, max: 200, message: '长度在 2 到 200 个字符', trigger: 'blur' }
  ],
  sectionId: [
    { required: true, message: '请选择版区', trigger: 'change' }
  ],
  content: [
    { required: true, message: '请输入帖子内容', trigger: 'blur' }
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

// 获取版区列表
const fetchSections = () => {
  request.get('/section/all', null,{
    // showDefaultMsg: false,
    onSuccess: (res) => {
      sectionOptions.value = res
    },
    onError: (error) => {

      console.error('获取版区列表失败:', error)
    }
  })
}

// 获取帖子列表
const fetchPosts = () => {
  loading.value = true
  const params = {
    ...searchForm,
    currentPage: currentPage.value,
    size: pageSize.value
  }
  
  request.get('/post/page', params, {
    showDefaultMsg: false,
    onSuccess: (res) => {
      tableData.value = res.records
      total.value = res.total
      loading.value = false
    },
    onError: (error) => {
      console.error('获取帖子列表失败:', error)
      loading.value = false
    }
  })
}

// 搜索
const handleSearch = () => {
  currentPage.value = 1
  fetchPosts()
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
  fetchPosts()
}

const handleCurrentChange = (val) => {
  currentPage.value = val
  fetchPosts()
}

// 新增帖子
const handleAdd = () => {
  dialogTitle.value = '新增帖子'
  postForm.id = ''
  postForm.title = ''
  postForm.sectionId = ''
  postForm.content = ''
  postForm.isEssence = 0
  postForm.status = 1
  dialogVisible.value = true
}

// 编辑帖子
const handleEdit = (row) => {
  dialogTitle.value = '编辑帖子'
  Object.assign(postForm, {
    id: row.id,
    title: row.title,
    sectionId: row.sectionId,
    content: row.content,
    isEssence: row.isEssence,
    status: row.status
  })
  dialogVisible.value = true
}

// 删除帖子
const handleDelete = async (row) => {
  try {
    await ElMessageBox.confirm('确认删除该帖子吗？', '提示', {
      type: 'warning'
    })
    
    request.delete(`/post/${row.id}`, {
      successMsg: '删除成功',
      errorMsg: '删除失败',
      onSuccess: () => {
        fetchPosts()
      },
      onError: (error) => {
        console.error('删除帖子失败:', error)
      }
    })
  } catch (error) {
    // 用户取消删除，不做处理
  }
}

// 切换精华状态
const handleToggleEssence = (row) => {
  const newEssence = row.isEssence === 1 ? 0 : 1
  request.put(`/post/${row.id}/essence?isEssence=${newEssence}`, null, {
    successMsg: newEssence === 1 ? '设为精华成功' : '取消精华成功',
    errorMsg: '操作失败',
    onSuccess: () => {
      fetchPosts()
    }
  })
}

// 修改帖子状态
const handleStatusChange = (id, status) => {
  request.put(`/post/${id}/status?status=${status}`, null, {
    successMsg: '状态更新成功',
    errorMsg: '状态更新失败',
    onError: (error) => {
      console.error('修改状态失败:', error)
      fetchPosts() // 更新失败时刷新列表
    }
  })
}

// 提交表单
const handleSubmit = async () => {
  if (!postFormRef.value) return

  try {
    await postFormRef.value.validate()
    
    if (postForm.id) {
      // 编辑
      request.put(`/post/${postForm.id}`, {
        sectionId: postForm.sectionId,
        title: postForm.title,
        content: postForm.content,
        isEssence: postForm.isEssence,
        status: postForm.status
      }, {
        successMsg: '更新成功',
        errorMsg: '更新失败',
        onSuccess: () => {
          dialogVisible.value = false
          fetchPosts()
        },
        onError: (error) => {
          console.error('更新帖子失败:', error)
        }
      })
    } else {
      // 新增，获取当前登录用户ID，这里假设有个全局的userStore
      const userId = 1 // 这里应该从store中获取，或者通过其他方式获取
      
      request.post('/post/add', {
        sectionId: postForm.sectionId,
        title: postForm.title,
        content: postForm.content,
        isEssence: postForm.isEssence,
        status: postForm.status
      }, {
        params: { userId },
        successMsg: '创建成功',
        errorMsg: '创建失败',
        onSuccess: () => {
          dialogVisible.value = false
          fetchPosts()
        },
        onError: (error) => {
          console.error('创建帖子失败:', error)
        }
      })
    }
  } catch (error) {
    console.error('表单验证失败:', error)
  }
}

// 重置表单
const resetForm = () => {
  if (postFormRef.value) {
    postFormRef.value.resetFields()
  }
}

// 刷新
const handleRefresh = () => {
  fetchPosts()
  ElMessage.success('刷新成功')
}

// 批量删除
const handleBatchDelete = async () => {
  if (selectedRows.value.length === 0) return
  
  try {
    await ElMessageBox.confirm(`确认删除选中的 ${selectedRows.value.length} 个帖子吗？`, '提示', {
      type: 'warning'
    })
    
    const ids = selectedRows.value.map(row => row.id)
    request.delete(`/post/batch?ids=${ids}`, {
      successMsg: '批量删除成功',
      errorMsg: '批量删除失败',
      onSuccess: () => {
        fetchPosts()
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
      { field: 'title', title: '标题' },
      { field: 'username', title: '发帖人' },
      { field: 'sectionName', title: '所属版区' },
      { field: 'createTime', title: '发布时间' },
      { field: 'viewCount', title: '浏览次数' },
      { field: 'isEssence', title: '是否精华' },
      { field: 'status', title: '状态' }
    ]
    
    // 准备导出数据
    const exportData = tableData.value.map(item => {
      const row = {}
      columns.forEach(col => {
        if (col.field === 'isEssence') {
          row[col.title] = item.isEssence === 1 ? '精华' : '普通'
        } else if (col.field === 'status') {
          row[col.title] = item.status === 1 ? '正常' : '已删除'
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
    XLSX.utils.book_append_sheet(workbook, worksheet, '帖子列表')

    // 导出文件
    const today = new Date()
    const year = today.getFullYear()
    const month = String(today.getMonth() + 1).padStart(2, '0')
    const day = String(today.getDate()).padStart(2, '0')
    XLSX.writeFile(workbook, `帖子列表_${year}-${month}-${day}.xlsx`)
    
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
  fetchPosts()
})
</script>

<style scoped>
.post-management {
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

.post-title {
  display: inline-block;
  max-width: 400px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
</style> 