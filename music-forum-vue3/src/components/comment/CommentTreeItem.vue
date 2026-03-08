<template>
  <div class="comment-item" :class="{'child-comment': isChild}">
    <!-- 评论头部信息 -->
    <div class="comment-header">
      <el-avatar :size="32" :src="'/api'+comment?.user?.avatar" />
      <div class="comment-info">
        <span class="username">{{ comment.username }}</span>
        <span class="comment-time">{{ formatDate(comment.createTime) }}</span>
      </div>
      <!-- 如果是自己的评论，显示删除按钮 -->
      <div class="comment-owner-actions" v-if="isCurrentUserComment">
        <el-button type="danger" link @click="handleDelete">
          <el-icon><Delete /></el-icon> 删除
        </el-button>
      </div>
      <!-- 非自己的评论，显示举报按钮 -->
      <div class="comment-actions-menu" v-else>
        <el-dropdown>
          <span class="el-dropdown-link">
            <el-icon><MoreFilled /></el-icon>
          </span>
          <template #dropdown>
            <el-dropdown-menu>
              <el-dropdown-item @click="handleReport">
                <el-icon><Warning /></el-icon> 举报
              </el-dropdown-item>
            </el-dropdown-menu>
          </template>
        </el-dropdown>
      </div>
    </div>

    <!-- 评论内容 -->
    <div class="comment-content">
      <!-- 如果是回复其他评论，则显示回复对象 -->
      <template v-if="comment.parentUsername">
        <span class="reply-to">@{{ comment.parentUsername }}</span>
      </template>
      {{ comment.content }}
    </div>

    <!-- 评论操作区域 -->
    <div class="comment-actions">
      <!-- 对于一级评论显示回复按钮 -->
      <el-button v-if="!isChild" type="primary" link @click="toggleReplyForm">
        <el-icon><ChatRound /></el-icon> 回复
      </el-button>
      
      <!-- 点赞按钮，对所有评论显示 -->
      <el-button type="primary" link @click="handleLike" class="like-button">
        <img :src="comment.isLiked ? likedIcon : unlikedIcon" class="like-icon" />
        {{ comment.likeCount || 0 }}
      </el-button>
    </div>

    <!-- 回复表单 -->
    <div class="reply-form" v-if="showReplyForm">
      <el-input
        v-model="replyContent"
        type="textarea"
        :rows="2"
        :placeholder="'回复 @' + comment.username"
        :maxlength="500"
        show-word-limit
      />
      <div class="form-actions">
        <el-button @click="showReplyForm = false">取消</el-button>
        <el-button type="primary" @click="handleSubmitReply" :loading="submitting">
          回复
        </el-button>
      </div>
    </div>

    <!-- 子评论列表 -->
    <div class="children-comments" v-if="comment.children && comment.children.length > 0">
      <comment-tree-item
        v-for="child in comment.children"
        :key="child.id"
        :comment="child"
        :is-child="true"
        @reply="handleChildReply"
        @submit-reply="handleChildSubmitReply"
        @delete="handleChildDelete"
        @like-updated="handleChildLikeUpdated"
      />
    </div>

    <!-- 举报对话框 -->
    <teleport to="body">
      <report-dialog
        v-if="reportDialogVisible"
        v-model:visible="reportDialogVisible"
        :type="2"
        :target-id="comment.id"
        :title="'评论'"
        @success="onReportSuccess"
      />
    </teleport>
  </div>
</template>

<script setup>
import { ref, defineProps, defineEmits, computed } from 'vue'
import { ChatRound, Delete, MoreFilled, Warning } from '@element-plus/icons-vue'
import { formatDate } from '@/utils/format'
import { useUserStore } from '@/store/user'
import { ElMessageBox, ElMessage } from 'element-plus'
import request from '@/utils/request'
import ReportDialog from '@/components/common/ReportDialog.vue'
import likedIcon from '@/assets/点赞.png'
import unlikedIcon from '@/assets/未点赞.png'

const userStore = useUserStore()

const props = defineProps({
  comment: {
    type: Object,
    required: true
  },
  isChild: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['reply', 'submit-reply', 'delete', 'like-updated', 'update:comment'])

// 检查评论是否属于当前用户
const isCurrentUserComment = computed(() => {
  return userStore.isLoggedIn && userStore.userInfo && userStore.userInfo.id === props.comment.userId
})

// 回复表单相关
const showReplyForm = ref(false)
const replyContent = ref('')
const submitting = ref(false)

// 切换回复表单显示
const toggleReplyForm = () => {
  // 二级评论不允许回复
  if (props.isChild) {
    return
  }
  
  // emit 事件并获取返回值
  // 之前的问题是 emit('reply') 并不会返回 handleReply 的返回值，
  // 所以这里需要直接操作 showReplyForm 而不是依赖返回值
  emit('reply', props.comment.id)
  // 不再检查 canReply 的返回值，而是直接切换显示状态
  showReplyForm.value = !showReplyForm.value
  if (!showReplyForm.value) {
    replyContent.value = ''
  }
}

// 提交回复
const handleSubmitReply = async () => {
  if (!replyContent.value.trim()) {
    return
  }
  
  submitting.value = true
  try {
    // 直接调用emit，不再依赖返回值
    emit('submit-reply', replyContent.value, props.comment.id)
    
    // 无论是否成功，都清空内容并关闭回复框
    // 实际提交结果会由父组件处理，如果失败会显示错误信息
    replyContent.value = ''
    showReplyForm.value = false
  } finally {
    submitting.value = false
  }
}

// 处理子评论的回复事件
const handleChildReply = (commentId) => {
  return emit('reply', commentId)
}

// 处理子评论的提交回复事件
const handleChildSubmitReply = (content, parentId) => {
  return emit('submit-reply', content, parentId)
}

// 删除自己的评论
const handleDelete = () => {
  if (!isCurrentUserComment.value) {
    return
  }
  
  ElMessageBox.confirm('确定要删除这条评论吗？此操作不可恢复！', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(async () => {
    try {
      await request.delete(`/comment/user/${props.comment.id}`, {
        successMsg: '评论删除成功',
        onSuccess: () => {
          emit('delete', props.comment.id)
        }
      })
    } catch (error) {
      console.error('删除评论失败:', error)
    }
  }).catch(() => {})
}

// 处理子评论的删除事件
const handleChildDelete = (commentId) => {
  emit('delete', commentId)
}

// 举报相关
const reportDialogVisible = ref(false)

// 处理举报
const handleReport = () => {
  if (!userStore.isLoggedIn) {
    ElMessage.warning('请先登录')
    return
  }
  reportDialogVisible.value = true
}

// 举报成功回调
const onReportSuccess = () => {
  ElMessage.success('举报已提交，感谢您的反馈')
}

// 处理点赞
const handleLike = async () => {
  if (!userStore.isLoggedIn) {
    ElMessage.warning('请先登录')
    return
  }
  
  try {
    await request.post(`/comment/like/${props.comment.id}`, null, {
      showDefaultMsg: false,
      onSuccess: (isLiked) => {
        // 通过emit更新评论数据
        emit('update:comment', {
          ...props.comment,
          isLiked: isLiked,
          likeCount: (props.comment.likeCount || 0) + (isLiked ? 1 : -1)
        })
        
        // 触发事件通知父组件
        emit('like-updated', { 
          commentId: props.comment.id, 
          isLiked: isLiked 
        })
        
        ElMessage.success(isLiked ? '点赞成功' : '取消点赞成功')
      }
    })
  } catch (error) {
    console.error('点赞操作失败:', error)
    ElMessage.error('点赞操作失败')
  }
}

// 添加子评论点赞事件处理函数
const handleChildLikeUpdated = (data) => {
  // 将子评论的点赞事件向上传递
  emit('like-updated', data)
}
</script>

<style lang="scss" scoped>
.comment-item {
  padding: 20px 0;
  border-bottom: 1px solid #eee;
  
  &:last-child {
    border-bottom: none;
  }
  
  &.child-comment {
    padding: 15px 0;
    border-bottom: 1px dashed #eee;
  }
  
  .comment-header {
    display: flex;
    align-items: center;
    gap: 10px;
    margin-bottom: 10px;
    
    .comment-info {
      flex: 1;
      
      .username {
        font-weight: bold;
        margin-right: 10px;
      }
      
      .comment-time {
        color: #999;
        font-size: 14px;
      }
    }
    
    .comment-owner-actions {
      .el-button {
        font-size: 14px;
      }
    }
    
    .comment-actions-menu {
      .el-dropdown-link {
        cursor: pointer;
        color: #909399;
        
        .el-icon {
          font-size: 18px;
        }
      }
    }
  }
  
  .comment-content {
    margin: 10px 0;
    line-height: 1.6;
    
    .reply-to {
      color: #409eff;
      font-weight: bold;
      margin-right: 5px;
    }
  }
  
  .comment-actions {
    margin-top: 10px;
  }
  
  .reply-form {
    margin: 15px 0;
    padding: 15px;
    background: #f8f9fa;
    border-radius: 4px;
    
    .form-actions {
      margin-top: 10px;
      text-align: right;
      
      .el-button + .el-button {
        margin-left: 10px;
      }
    }
  }
  
  .children-comments {
    margin-top: 15px;
    margin-left: 40px;
    border-left: 2px solid #ebeef5;
    padding-left: 15px;
  }
}

.like-button {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  
  .like-icon {
    width: 20px;
    height: 20px;
  }
}
</style> 