<template>
  <div class="comment-management-container">
    <!-- 搜索卡片 -->
    <el-card class="search-card">
      <div class="search-form">
        <el-form :model="searchForm" inline>
          <el-form-item label="评论内容">
            <el-input v-model="searchForm.content" placeholder="请输入评论内容关键词" clearable></el-input>
          </el-form-item>
          <el-form-item label="用户名">
            <el-input v-model="searchForm.username" placeholder="请输入用户名" clearable></el-input>
          </el-form-item>
          <el-form-item label="帖子标题">
            <el-input v-model="searchForm.postTitle" placeholder="请输入帖子标题" clearable></el-input>
          </el-form-item>
          <el-form-item label="状态">
            <el-select style="width: 150px" v-model="searchForm.status" placeholder="请选择状态" clearable>
              <el-option label="已删除" :value="0"></el-option>
              <el-option label="正常" :value="1"></el-option>
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
      <el-button type="primary" @click="refreshCommentList">
        <el-icon><Refresh /></el-icon>刷新
      </el-button>
      <el-button type="danger" :disabled="selectedComments.length === 0" @click="handleBatchDelete">
        <el-icon><Delete /></el-icon>批量删除
      </el-button>
    </div>

    <!-- 数据表格 -->
    <el-card class="table-card">
      <el-table
        v-loading="tableLoading"
        :data="commentList"
        border
        stripe
        style="width: 100%"
        @selection-change="handleSelectionChange"
      >
        <el-table-column type="selection" width="55"></el-table-column>
        <el-table-column prop="id" label="ID" width="80"></el-table-column>
        <el-table-column prop="content" label="评论内容" show-overflow-tooltip></el-table-column>
        <el-table-column prop="username" label="评论用户" width="120"></el-table-column>
        <el-table-column prop="postTitle" label="帖子标题" width="180" show-overflow-tooltip></el-table-column>
        <el-table-column prop="parentUsername" label="回复用户" width="120">
          <template #default="scope">
            {{ scope.row.parentUsername || '无' }}
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="评论时间" width="180">
          <template #default="scope">
            {{ formatDate(scope.row.createTime) }}
          </template>
        </el-table-column>
        <el-table-column prop="status" label="状态" width="100">
          <template #default="scope">
            <el-tag :type="scope.row.status === 1 ? 'success' : 'danger'">
              {{ scope.row.status === 1 ? '正常' : '已删除' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="250">
          <template #default="scope">
            <el-button 
              v-if="scope.row.status === 1" 
              type="danger" 
              @click="handleStatusChange(scope.row.id, 0)" 
              size="small"
            >
              标记删除
            </el-button>
            <el-button 
              v-else 
              type="success" 
              @click="handleStatusChange(scope.row.id, 1)" 
              size="small"
            >
              恢复正常
            </el-button>
            <el-button 
              type="primary" 
              @click="handleEdit(scope.row)" 
              size="small"
            >
              <el-icon><Edit /></el-icon>编辑
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

    <!-- 编辑评论对话框 -->
    <el-dialog
      v-model="commentFormVisible"
      :title="formOperation === 'edit' ? '编辑评论' : '新增评论'"
      width="500px"
    >
      <el-form
        ref="commentFormRef"
        :model="commentForm"
        :rules="commentFormRules"
        label-width="100px"
      >
        <el-form-item label="评论内容" prop="content">
          <el-input
            v-model="commentForm.content"
            type="textarea"
            :rows="4"
            placeholder="请输入评论内容"
          ></el-input>
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-select v-model="commentForm.status" placeholder="请选择状态">
            <el-option label="已删除" :value="0"></el-option>
            <el-option label="正常" :value="1"></el-option>
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="commentFormVisible = false">取消</el-button>
        <el-button type="primary" @click="submitCommentForm" :loading="formLoading">
          确定
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { Search, Refresh, Edit, Delete } from '@element-plus/icons-vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import request from '@/utils/request'
import { formatDate } from '@/utils/format'

// 搜索表单
const searchForm = reactive({
  content: '',
  username: '',
  postTitle: '',
  status: ''
})

// 分页相关
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)

// 表格相关
const tableLoading = ref(false)
const commentList = ref([])
const selectedComments = ref([])

// 表单相关
const commentFormRef = ref(null)
const commentFormVisible = ref(false)
const formLoading = ref(false)
const formOperation = ref('edit') // 'add' 或 'edit'
const commentForm = reactive({
  id: '',
  content: '',
  status: 1
})

// 表单验证规则
const commentFormRules = {
  content: [
    { required: true, message: '请输入评论内容', trigger: 'blur' },
    { min: 1, max: 500, message: '评论内容长度在1-500个字符之间', trigger: 'blur' }
  ],
  status: [
    { required: true, message: '请选择状态', trigger: 'change' }
  ]
}

// 加载评论列表
const fetchCommentList = async () => {
  tableLoading.value = true
  try {
    const params = {
      content: searchForm.content || undefined,
      username: searchForm.username || undefined,
      postTitle: searchForm.postTitle || undefined,
      status: searchForm.status === '' ? undefined : searchForm.status,
      current: currentPage.value,
      size: pageSize.value
    }
    const response = await request.get('/comment/page', params, {
      showDefaultMsg: false,
      onSuccess: (res) => {
        commentList.value = res.records
        total.value = res.total
      },
      onError: (err) => {
        console.error('获取评论列表失败:', err)
        ElMessage.error('获取评论列表失败')
      }
    })
  } catch (error) {
    console.error('获取评论列表失败:', error)
    ElMessage.error('获取评论列表失败')
  } finally {
    tableLoading.value = false
  }
}

// 搜索
const handleSearch = () => {
  currentPage.value = 1
  fetchCommentList()
}

// 重置搜索
const resetSearch = () => {
  Object.keys(searchForm).forEach(key => {
    searchForm[key] = ''
  })
  currentPage.value = 1
  fetchCommentList()
}

// 刷新列表
const refreshCommentList = () => {
  fetchCommentList()
}

// 表格选择项变化
const handleSelectionChange = (selection) => {
  selectedComments.value = selection
}

// 分页大小变化
const handleSizeChange = (val) => {
  pageSize.value = val
  fetchCommentList()
}

// 当前页变化
const handleCurrentChange = (val) => {
  currentPage.value = val
  fetchCommentList()
}

// 编辑评论
const handleEdit = (row) => {
  commentForm.id = row.id
  commentForm.content = row.content
  commentForm.status = row.status
  formOperation.value = 'edit'
  commentFormVisible.value = true
}

// 提交评论表单
const submitCommentForm = async () => {
  if (!commentFormRef.value) return
  
  await commentFormRef.value.validate(async (valid) => {
    if (!valid) return
    
    formLoading.value = true
    try {
      const apiUrl = `/comment/${commentForm.id}`
      const response = await request.put(apiUrl,{
        content: commentForm.content,
        status: commentForm.status
      },{
        successMsg: '评论更新成功',
        onSuccess: (res) => {
          commentFormVisible.value = false
          fetchCommentList()
        }
      })
      
    } catch (error) {
      console.error('提交评论表单失败:', error)
      ElMessage.error('提交评论表单失败')
    } finally {
      formLoading.value = false
    }
  })
}

// 删除评论
const handleDelete = (id) => {
  ElMessageBox.confirm('确定要删除该评论吗？此操作不可恢复！', '警告', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(async () => {
    try {
      const response = await request.delete(`/comment/${id}`,null, {
        successMsg: '删除成功',
        onSuccess: (res) => {
       
          fetchCommentList()
        }
      })

    } catch (error) {
      console.error('删除评论失败:', error)
      ElMessage.error('删除评论失败')
    }
  }).catch(() => {})
}

// 批量删除
const handleBatchDelete = () => {
  if (selectedComments.value.length === 0) {
    ElMessage.warning('请至少选择一条评论')
    return
  }
  
  ElMessageBox.confirm(`确定要删除选中的 ${selectedComments.value.length} 条评论吗？此操作不可恢复！`, '警告', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(async () => {
    try {
      const ids = selectedComments.value.map(item => item.id)
      const response = await request.delete('/comment/batch?ids='+ids,null,{
        successMsg: '批量删除成功',
        onSuccess: (res) => {

          fetchCommentList()
        }
      })
      

    } catch (error) {
      console.error('批量删除评论失败:', error)
      ElMessage.error('批量删除评论失败')
    }
  }).catch(() => {})
}

// 修改评论状态
const handleStatusChange = async (id, status) => {
  try {
    const response = await request.put(`/comment/${id}/status?status=${status}`,null,{
      successMsg: status === 1 ? '评论已恢复正常' : '评论已标记为删除',
      onSuccess: (res) => {
        fetchCommentList()
      }
    })

  } catch (error) {
    console.error('修改评论状态失败:', error)
    ElMessage.error('修改评论状态失败')
  }
}

// 组件挂载时获取评论列表
onMounted(() => {
  fetchCommentList()
})
</script>

<style lang="scss" scoped>
.comment-management-container {
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