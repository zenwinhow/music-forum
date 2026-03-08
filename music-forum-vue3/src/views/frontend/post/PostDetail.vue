<template>
  <div class="post-detail-container">
    <!-- 帖子内容卡片 -->
    <el-card class="post-card">
      <template #header>
        <div class="post-header">
          <h1 class="post-title">{{ post.title }}</h1>
          <div class="post-meta">
            <el-avatar :size="50" :src="'/api'+post?.user?.avatar" />
            
            <div class="author-info">
              <span class="author-name">{{ post.authorName }}</span>
              <span class="post-time">发布于 {{ formatDate(post.createTime) }}</span>
            </div>
            <div class="post-actions">
              <el-button 
                type="warning" 
                :icon="post.isFavorited ? Star : StarFilled"
                circle 
                @click="handleFavorite" 
                :class="{ 'is-favorited': post.isFavorited }"
              >
              </el-button>
              <el-button type="danger" circle @click="handleReport" v-if="!isAuthor">
                <el-icon><Warning /></el-icon>
              </el-button>
              <el-dropdown v-if="isAuthor">
                <el-button type="primary" color="#8e44ad">
                  操作<el-icon class="el-icon--right"><ArrowDown /></el-icon>
                </el-button>
                <template #dropdown>
                  <el-dropdown-menu>
                    <el-dropdown-item @click="handleEdit">
                      <el-icon><Edit /></el-icon> 编辑
                    </el-dropdown-item>
                    <el-dropdown-item @click="handleDelete" divided>
                      <el-icon><Delete /></el-icon> 删除
                    </el-dropdown-item>
                  </el-dropdown-menu>
                </template>
              </el-dropdown>
            </div>
          </div>
        </div>
      </template>
      
      <!-- 帖子内容 -->
      <div class="post-content" v-html="post.content"></div>
      
      <div class="post-footer">
        <div class="post-stats">
          <div class="stat-item">
            <el-icon><View /></el-icon> 
            <span>{{ post.viewCount }} 阅读</span>
          </div>
          <div class="stat-item">
            <el-icon><ChatRound /></el-icon> 
            <span>{{ post.commentCount }} 评论</span>
          </div>
          <div class="stat-item">
            <el-icon v-if="post.isFavorited"><StarFilled /></el-icon>
            <el-icon v-else><Star /></el-icon> 
            <span>{{ post.favoriteCount || 0 }} 收藏</span>
          </div>
        </div>
        <div class="post-tags" v-if="post.sectionId">
          <el-tag type="info" effect="plain" size="small">
            {{ getSectionName(post.sectionId) }}
          </el-tag>
        </div>
      </div>
    </el-card>

    <!-- 评论区 -->
    <el-card class="comment-card">
      <template #header>
        <div class="comment-header">
          <div class="header-title">
            <el-icon><ChatDotRound /></el-icon>
            <h3>评论区 ({{ totalComments }})</h3>
          </div>
        </div>
      </template>

      <!-- 发表评论 -->
      <div class="comment-form" v-if="userStore.isLoggedIn">
        <div class="form-header">
          <el-avatar :size="40" :src="'/api'+userStore.userInfo?.avatar">
            {{ userStore.userInfo?.username?.charAt(0) }}
          </el-avatar>
          <span class="form-tip">发表您的评论...</span>
        </div>
        <el-input
          v-model="commentForm.content"
          type="textarea"
          :rows="3"
          placeholder="写下你的评论..."
          :maxlength="500"
          show-word-limit
        />
        <div class="form-actions">
          <el-button type="primary" color="#8e44ad" round @click="submitComment" :loading="submitting">
            <el-icon><ChatSquare /></el-icon> 发表评论
          </el-button>
        </div>
      </div>
      <div v-else class="login-tip">
        <el-icon><Lock /></el-icon>
        <el-link type="primary" @click="$router.push('/login')">登录</el-link> 后参与评论
      </div>

      <!-- 评论列表 - 树状结构 -->
      <div class="comment-list">
        <div v-if="commentTree.length === 0" class="no-comment">
          <el-empty description="暂无评论，快来抢沙发吧！" :image-size="120">
            <template #description>
              <p>成为第一个发表评论的人</p>
            </template>
          </el-empty>
        </div>
        <div v-else>
          <!-- 使用递归组件渲染评论树 -->
          <transition-group name="comment-fade">
            <comment-tree-item
              v-for="comment in commentTree"
              :key="comment.id"
              :comment="comment"
              @reply="handleReply"
              @submit-reply="submitReply"
              @delete="handleCommentDelete"
              @like-updated="onCommentLikeUpdated"
              @update:comment="updateComment"
            />
          </transition-group>
        </div>
      </div>
    </el-card>

    <!-- 举报对话框 -->
    <teleport to="body">
      <report-dialog
        v-model:visible="reportDialogVisible"
        :type="reportForm.type"
        :target-id="reportForm.targetId"
        :title="reportForm.type === 1 ? post.title : '评论'"
        @success="onReportSuccess"
      />
    </teleport>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted, defineAsyncComponent, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { 
  View, ChatRound, Warning, ArrowDown, Star, StarFilled, 
  Edit, Delete, ChatDotRound, ChatSquare, Lock 
} from '@element-plus/icons-vue'
import { useUserStore } from '@/store/user'
import request from '@/utils/request'
import { formatDate } from '@/utils/format'
import ReportDialog from '@/components/common/ReportDialog.vue'

// 使用异步组件导入递归组件
const CommentTreeItem = defineAsyncComponent(() => 
  import('@/components/comment/CommentTreeItem.vue')
)

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()

// 帖子数据
const post = ref({
  id: 0,
  title: '',
  content: '',
  authorId: 0,
  authorName: '',
  authorAvatar: '',
  createTime: '',
  updateTime: '',
  viewCount: 0,
  commentCount: 0,
  favoriteCount: 0,
  isFavorited: false,
  sectionId: 0
})

// 评论相关
const commentTree = ref([])
const totalComments = ref(0)

const commentForm = reactive({
  postId: 0,
  content: '',
  parentId: null
})

// 举报相关
const reportDialogVisible = ref(false)
const reportForm = reactive({
  type: 1, // 1-帖子 2-评论
  targetId: 0
})

// 其他状态
const submitting = ref(false)
const isAuthor = computed(() => post.value.authorId === userStore.userInfo?.id)

// 获取帖子详情
const fetchPostDetail = async () => {
  try {
    const postId = route.params.id
    await request.get('/post/' + postId, null, {
      showDefaultMsg: false,
      onSuccess: (res) => {
        post.value = res
        // 增加浏览量
        incrementPostView()
        // 如果用户已登录，获取收藏状态
        if (userStore.isLoggedIn) {
          checkFavoriteStatus(postId)
        }
      }
    })
  } catch (error) {
    console.error('获取帖子详情失败:', error)
    ElMessage.error('获取帖子详情失败')
  }
}

// 获取版块名称
const getSectionName = (sectionId) => {
  const sectionNames = {
    1: '学术交流',
    2: '教学资源',
    3: '课外活动',
    4: '技术交流',
    5: '校园生活'
  }
  return sectionNames[sectionId] || '未知版块'
}

// 增加帖子浏览量
const incrementPostView = async () => {
  try {
    await request.put('/post/' + route.params.id + '/view', null, {
      showDefaultMsg: false,
      onSuccess: () => {
        post.value.viewCount++
      }
    })
  } catch (error) {
    console.error('更新浏览量失败:', error)
  }
}

// 检查收藏状态
const checkFavoriteStatus = async (postId) => {
  try {
    await request.get(`/post/favorite/check/${postId}`, null, {
      showDefaultMsg: false,
      onSuccess: (res) => {
        post.value.isFavorited = res
      }
    })
  } catch (error) {
    console.error('获取收藏状态失败:', error)
  }
}

// 获取收藏数量
const fetchFavoriteCount = async () => {
  try {
    const postId = route.params.id
    await request.get(`/post/favorite/count/${postId}`, null, {
      showDefaultMsg: false,
      onSuccess: (res) => {
        post.value.favoriteCount = res
      }
    })
  } catch (error) {
    console.error('获取收藏数量失败:', error)
  }
}

// 获取评论树
const fetchCommentTree = async () => {
  try {
    await request.get('/comment/tree/' + route.params.id, null, {
      showDefaultMsg: false,
      onSuccess: (res) => {
        commentTree.value = res
          
        // 计算评论总数（递归计算所有子评论）
        const countComments = (comments) => {
          let count = comments.length
          for (const comment of comments) {
            if (comment.children && comment.children.length > 0) {
              count += countComments(comment.children)
            }
          }
          return count
        }
        
        totalComments.value = countComments(commentTree.value)
        post.value.commentCount = totalComments.value
      }
    })
  } catch (error) {
    console.error('获取评论树失败:', error)
    ElMessage.error('获取评论树失败')
  }
}

// 提交评论
const submitComment = async () => {
  if (!userStore.isLoggedIn) {
    ElMessage.warning('请先登录')
    return
  }

  if (!commentForm.content.trim()) {
    ElMessage.warning('请输入评论内容')
    return
  }

  submitting.value = true
  try {
    const data = {
      postId: Number(route.params.id),
      content: commentForm.content.trim(),
      parentId: null  // 主评论的 parentId 为 null
    }
    await request.post('/comment/add', data, {
      successMsg: '评论发表成功',
      onSuccess: () => {
        commentForm.content = ''
        fetchCommentTree() // 重新获取评论树
      }
    })
  } catch (error) {
    console.error('发表评论失败:', error)
  } finally {
    submitting.value = false
  }
}

// 处理回复
const handleReply = (commentId) => {
  if (!userStore.isLoggedIn) {
    ElMessage.warning('请先登录')
    return false
  }
  return true
}

// 提交回复
const submitReply = async (content, parentId) => {
  if (!userStore.isLoggedIn) {
    ElMessage.warning('请先登录')
    return false
  }

  if (!content.trim()) {
    ElMessage.warning('请输入回复内容')
    return false
  }

  submitting.value = true
  try {
    const data = {
      postId: Number(route.params.id),
      content: content.trim(),
      parentId: parentId
    }
    await request.post('/comment/add', data, {
      successMsg: '回复发表成功',
      onSuccess: () => {
        fetchCommentTree() // 重新获取评论树
      }
    })
    return true
  } catch (error) {
    console.error('发表回复失败:', error)
    return false
  } finally {
    submitting.value = false
  }
}

// 处理评论删除
const handleCommentDelete = (commentId) => {
  // 删除成功后重新获取评论树
  fetchCommentTree()
}

// 收藏帖子
const handleFavorite = async () => {
  if (!userStore.isLoggedIn) {
    ElMessage.warning('请先登录')
    return
  }

  try {
    const postId = route.params.id
    await request.post('/post/favorite/' + postId,null, {
      successMsg: post.value.isFavorited ? '取消收藏成功' : '收藏成功',
      onSuccess: (res) => {
        post.value.isFavorited = res
        // 更新收藏数量
        fetchFavoriteCount()
      }
    })
  } catch (error) {
    console.error('收藏操作失败:', error)
  }
}

// 处理举报
const handleReport = () => {
  if (!userStore.isLoggedIn) {
    ElMessage.warning('请先登录')
    return
  }
  reportForm.type = 1
  reportForm.targetId = post.value.id
  reportDialogVisible.value = true
  console.log('Report dialog should open now:', reportDialogVisible.value)
}

// 举报成功回调
const onReportSuccess = () => {
  ElMessage.success('举报已提交，感谢您的反馈')
}

// 编辑帖子
const handleEdit = () => {
  router.push('/post/edit/' + post.value.id)
}

// 删除帖子
const handleDelete = () => {
  ElMessageBox.confirm('确定要删除这篇帖子吗？此操作不可恢复！', '警告', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(async () => {
    try {
      await request.delete('/post/' + post.value.id, null, {
        successMsg: '删除成功',
        onSuccess: () => {
          router.push('/forum/section/' + post.value.sectionId)
        }
      })
    } catch (error) {
      console.error('删除帖子失败:', error)
    }
  }).catch(() => {})
}

// 添加处理评论点赞事件的方法
const onCommentLikeUpdated = ({ commentId, isLiked }) => {
  // 在评论树中查找并更新点赞状态
  const updateCommentInTree = (comments) => {
    for (const comment of comments) {
      if (comment.id === commentId) {
        comment.isLiked = isLiked
        return true
      }
      
      if (comment.children && comment.children.length > 0) {
        if (updateCommentInTree(comment.children)) {
          return true
        }
      }
    }
    
    return false
  }
  
  updateCommentInTree(commentTree.value)
}

// 处理评论更新
const updateComment = (updatedComment) => {
  const updateCommentInTree = (comments) => {
    for (let i = 0; i < comments.length; i++) {
      if (comments[i].id === updatedComment.id) {
        comments[i] = { ...updatedComment }
        return true
      }
      if (comments[i].children && comments[i].children.length > 0) {
        if (updateCommentInTree(comments[i].children)) {
          return true
        }
      }
    }
    return false
  }
  
  updateCommentInTree(commentTree.value)
}

// 加载帖子数据的函数
const loadPostData = () => {
  if (route.params.id) {
    // 重置数据状态
    post.value = {
      id: 0,
      title: '',
      content: '',
      authorId: 0,
      authorName: '',
      authorAvatar: '',
      createTime: '',
      updateTime: '',
      viewCount: 0,
      commentCount: 0,
      favoriteCount: 0,
      isFavorited: false
    }
    commentTree.value = []
    totalComments.value = 0
    
    // 获取新数据
    fetchPostDetail()
    fetchCommentTree()
    fetchFavoriteCount()
  } else {
    ElMessage.error('帖子ID不存在')
    router.push('/home')
  }
}

// 组件挂载时获取数据
onMounted(() => {
  loadPostData()
})

// 监听路由参数变化，重新获取数据
watch(() => route.params.id, (newId, oldId) => {
  if (newId !== oldId) {
    loadPostData()
  }
}, { immediate: false })
</script>

<style lang="scss" scoped>
.post-detail-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
}

.post-card {
  margin-bottom: 30px;
  border-radius: 16px;
  overflow: hidden;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
  
  .post-header {
    .post-title {
      margin: 0 0 20px;
      font-size: 28px;
      font-weight: 700;
      color: #333;
      position: relative;
      
      &::after {
        content: '';
        position: absolute;
        bottom: -8px;
        left: 0;
        width: 60px;
        height: 4px;
        background: linear-gradient(90deg, #8e44ad, #9b59b6);
        border-radius: 2px;
      }
    }
    
    .post-meta {
      display: flex;
      align-items: center;
      gap: 15px;
      
      .author-info {
        flex: 1;
        
        .author-name {
          display: block;
          font-weight: 600;
          font-size: 16px;
          color: #8e44ad;
        }
        
        .post-time {
          color: #909399;
          font-size: 14px;
        }
      }
      
      .post-actions {
        display: flex;
        gap: 10px;
        
        .is-favorited {
          background-color: #E6A23C;
          border-color: #E6A23C;
          color: white;
        }
      }
    }
  }
  
  .post-content {
    margin: 25px 0;
    padding: 20px;
    line-height: 1.8;
    font-size: 16px;
    color: #303133;
    background-color: #fafafa;
    border-radius: 12px;
    
    :deep(img) {
      max-width: 100%;
      height: auto;
      border-radius: 8px;
      box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
    }
    
    :deep(a) {
      color: #8e44ad;
      text-decoration: none;
      font-weight: 500;
      transition: all 0.3s;
      
      &:hover {
        text-decoration: underline;
      }
    }
    
    :deep(pre) {
      background-color: #f5f7fa;
      padding: 15px;
      border-radius: 8px;
      overflow: auto;
    }
    
    :deep(blockquote) {
      border-left: 4px solid #8e44ad;
      padding: 12px 15px;
      margin: 15px 0;
      background-color: rgba(142, 68, 173, 0.05);
      color: #606266;
    }
    
    :deep(h1, h2, h3, h4, h5, h6) {
      margin-top: 30px;
      margin-bottom: 15px;
      color: #303133;
    }
    
    :deep(ul, ol) {
      padding-left: 30px;
    }
    
    :deep(table) {
      border-collapse: collapse;
      width: 100%;
      
      th, td {
        border: 1px solid #dcdfe6;
        padding: 10px;
      }
      
      th {
        background-color: #f5f7fa;
      }
    }
  }
  
  .post-footer {
    margin-top: 20px;
    padding-top: 20px;
    border-top: 1px solid #ebeef5;
    display: flex;
    justify-content: space-between;
    align-items: center;
    
    .post-stats {
      display: flex;
      gap: 20px;
      
      .stat-item {
        display: flex;
        align-items: center;
        gap: 8px;
        font-size: 14px;
        color: #606266;
        
        .el-icon {
          color: #8e44ad;
          font-size: 18px;
        }
      }
    }
    
    .post-tags {
      display: flex;
      gap: 10px;
    }
  }
}

.comment-card {
  border-radius: 16px;
  overflow: hidden;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
  
  .comment-header {
    .header-title {
      display: flex;
      align-items: center;
      gap: 10px;
      
      h3 {
        margin: 0;
        font-size: 18px;
        font-weight: 600;
      }
      
      .el-icon {
        color: #8e44ad;
        font-size: 20px;
      }
    }
  }
  
  .comment-form {
    margin-bottom: 30px;
    background-color: #f5f7fa;
    padding: 20px;
    border-radius: 12px;
    
    .form-header {
      display: flex;
      align-items: center;
      gap: 15px;
      margin-bottom: 15px;
      
      .form-tip {
        color: #909399;
        font-size: 14px;
      }
    }
    
    .form-actions {
      margin-top: 15px;
      text-align: right;
    }
  }
  
  .login-tip {
    text-align: center;
    color: #909399;
    padding: 30px;
    background-color: #f5f7fa;
    border-radius: 12px;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
    
    .el-icon {
      color: #8e44ad;
    }
  }
  
  .comment-list {
    .no-comment {
      text-align: center;
      color: #909399;
      padding: 40px 0;
    }
  }
}

/* 评论列表的过渡动画 */
.comment-fade-enter-active,
.comment-fade-leave-active {
  transition: all 0.5s;
}
.comment-fade-enter-from,
.comment-fade-leave-to {
  opacity: 0;
  transform: translateY(30px);
}

@media (max-width: 768px) {
  .post-meta {
    flex-direction: column;
    align-items: flex-start !important;
    
    .post-actions {
      align-self: flex-end;
      margin-top: 15px;
    }
  }
  
  .post-footer {
    flex-direction: column;
    gap: 15px;
    
    .post-tags {
      align-self: flex-start;
    }
  }
}
</style>


