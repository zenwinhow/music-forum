<template>
  <div class="notification-page">
    <!-- 页面标题 -->
    <div class="page-header">
      <div class="header-title">
        <el-icon><Bell /></el-icon>
        <h1>通知公告</h1>
      </div>
      <div class="header-actions">
        <el-input
          v-model="searchKeyword"
          placeholder="搜索通知标题..."
          clearable
          @keyup.enter="handleSearch"
          class="search-input"
        >
          <template #prefix>
            <el-icon><Search /></el-icon>
          </template>
          <template #append>
            <el-button @click="handleSearch">
              <el-icon><Search /></el-icon>
            </el-button>
          </template>
        </el-input>
      </div>
    </div>

    <!-- 通知列表卡片 -->
    <el-card v-loading="loading" class="notification-list-card">
      <transition-group name="notification-fade" tag="div" class="notification-list">
        <div
          v-for="notification in notifications"
          :key="notification.id"
          class="notification-item"
          @click="showNotificationDetail(notification)"
        >
          <div class="notification-icon">
            <el-icon><Notification /></el-icon>
          </div>
          <div class="notification-content">
            <h3 class="notification-title">
              <el-tag 
                v-if="notification.status === 1" 
                type="success" 
                size="small" 
                effect="dark"
                class="status-tag"
              >已发布</el-tag>
              {{ notification.title }}
            </h3>
            <p class="notification-summary">{{ truncateContent(notification.content) }}</p>
            <div class="notification-meta">
              <span class="publish-time">
                <el-icon><Timer /></el-icon>
                {{ formatDate(notification.createTime) }}
              </span>
            </div>
          </div>
          <div class="notification-action">
            <el-button text>
              <el-icon><ArrowRight /></el-icon>
            </el-button>
          </div>
        </div>
      </transition-group>
      
      <!-- 空状态展示 -->
      <div class="empty-container" v-if="notifications.length === 0 && !loading">
        <el-empty description="暂无通知" :image-size="200">
          <template #description>
            <p>暂无通知公告，请稍后查看</p>
          </template>
        </el-empty>
      </div>

      <!-- 分页器 -->
      <div class="pagination-container" v-if="total > 0">
        <el-pagination
          v-model:current-page="currentPage"
          v-model:page-size="pageSize"
          :page-sizes="[10, 20, 50, 100]"
          :total="total"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="handleSizeChange"
          @current-change="handleCurrentChange"
          background
        />
      </div>
    </el-card>

    <!-- 通知详情对话框 -->
    <el-dialog
      v-model="detailDialogVisible"
      width="600px"
      center
      destroy-on-close
    >
      <template #header>
        <div class="dialog-header">
          <el-icon class="dialog-icon"><Notification /></el-icon>
          <span>{{ currentNotification?.title }}</span>
        </div>
      </template>
      <div class="notification-detail" v-if="currentNotification">
        <div class="detail-meta">
          <el-tag type="success" effect="dark" size="small" v-if="currentNotification.status === 1">已发布</el-tag>
          <span class="publish-time">
            <el-icon><Timer /></el-icon>
            {{ formatDate(currentNotification.createTime) }}
          </span>
        </div>
        <div class="detail-content" v-html="currentNotification.content"></div>
      </div>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
import { Search, Timer, ArrowRight, Bell, Notification } from '@element-plus/icons-vue'
import request from '@/utils/request'
import { ElMessage } from 'element-plus'

// 状态变量
const loading = ref(false)
const searchKeyword = ref('')
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)
const notifications = ref([])
const detailDialogVisible = ref(false)
const currentNotification = ref(null)

// 获取通知列表
const fetchNotifications = async () => {
  loading.value = true
  try {
    const params = {
      title: searchKeyword.value,
      status: 1, // 只获取已发布的通知
      currentPage: currentPage.value,
      size: pageSize.value
    }

    await request.get('/notification/page', params, {
      showDefaultMsg: false,
      onSuccess: (data) => {
        notifications.value = data.records || []
        total.value = data.total || 0
      }
    })
  } catch (error) {
    console.error('获取通知列表失败:', error)
    ElMessage.error('获取通知列表失败')
  } finally {
    loading.value = false
  }
}

// 搜索处理
const handleSearch = () => {
  currentPage.value = 1
  fetchNotifications()
}

// 分页处理
const handleSizeChange = (val) => {
  pageSize.value = val
  fetchNotifications()
}

const handleCurrentChange = (val) => {
  currentPage.value = val
  fetchNotifications()
}

// 显示通知详情
const showNotificationDetail = (notification) => {
  currentNotification.value = notification
  detailDialogVisible.value = true
}

// 格式化日期
const formatDate = (dateString) => {
  if (!dateString) return '-'
  const date = new Date(dateString)
  const now = new Date()
  const diff = Math.floor((now - date) / 1000) // 秒数差
  
  if (diff < 60) {
    return '刚刚'
  } else if (diff < 3600) {
    return Math.floor(diff / 60) + '分钟前'
  } else if (diff < 86400) {
    return Math.floor(diff / 3600) + '小时前'
  } else if (diff < 2592000) {
    return Math.floor(diff / 86400) + '天前'
  } else {
    return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`
  }
}

// 截断内容
const truncateContent = (content) => {
  if (!content) return ''
  // 移除HTML标签
  const plainText = content.replace(/<[^>]+>/g, '')
  // 移除特殊字符和多余空格
  const cleanText = plainText
    .replace(/&[^;]+;/g, '')
    .replace(/\s+/g, ' ')
    .trim()
  return cleanText.length > 100 ? cleanText.substring(0, 100) + '...' : cleanText
}

// 初始化
onMounted(() => {
  fetchNotifications()
})
</script>

<style lang="scss" scoped>
.notification-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
}

.page-header {
  margin-bottom: 30px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: linear-gradient(90deg, #8e44ad, #9b59b6);
  padding: 20px 30px;
  border-radius: 16px;
  box-shadow: 0 10px 30px rgba(142, 68, 173, 0.2);
  
  .header-title {
    display: flex;
    align-items: center;
    gap: 15px;
    
    h1 {
      margin: 0;
      font-size: 28px;
      font-weight: 700;
      color: white;
    }
    
    .el-icon {
      font-size: 28px;
      color: white;
    }
  }
  
  .header-actions {
    .search-input {
      width: 300px;
      .el-input__wrapper {
        border-radius: 20px 0 0 20px;
      }
      
      :deep(.el-input-group__append) {
        border-radius: 0 20px 20px 0;
        background-color: white;
      }
    }
  }
  
  @media (max-width: 768px) {
    flex-direction: column;
    gap: 20px;
    
    .header-actions {
      width: 100%;
      
      .search-input {
        width: 100%;
      }
    }
  }
}

.notification-list-card {
  border-radius: 16px;
  overflow: hidden;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
  margin-bottom: 30px;
}

.notification-list {
  display: flex;
  flex-direction: column;
  gap: 5px;
}

.notification-item {
  display: flex;
  align-items: flex-start;
  padding: 20px;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.3s;
  background-color: #f9f9fb;
  margin-bottom: 10px;
  border-left: 4px solid #8e44ad;

  &:hover {
    transform: translateY(-4px);
    box-shadow: 0 8px 20px rgba(0, 0, 0, 0.1);
    background-color: #f5f0fa;
  }
  
  .notification-icon {
    font-size: 24px;
    color: #8e44ad;
    margin-right: 15px;
    display: flex;
    align-items: center;
    justify-content: center;
    background-color: rgba(142, 68, 173, 0.1);
    width: 40px;
    height: 40px;
    border-radius: 50%;
  }
}

.notification-content {
  flex: 1;
}

.notification-title {
  font-size: 18px;
  font-weight: 600;
  color: #303133;
  margin: 0 0 12px;
  display: flex;
  align-items: center;
  gap: 8px;

  .status-tag {
    font-weight: normal;
  }
}

.notification-summary {
  font-size: 14px;
  color: #606266;
  margin: 0 0 12px;
  line-height: 1.6;
}

.notification-meta {
  font-size: 13px;
  color: #909399;
  display: flex;
  align-items: center;
  gap: 15px;
}

.publish-time {
  display: flex;
  align-items: center;
  gap: 4px;
  
  .el-icon {
    color: #8e44ad;
  }
}

.notification-action {
  margin-left: 15px;
  
  .el-button {
    color: #8e44ad;
  }
}

.empty-container {
  padding: 40px 0;
  text-align: center;
  
  p {
    color: #909399;
    margin: 15px 0;
  }
}

.pagination-container {
  margin-top: 30px;
  display: flex;
  justify-content: center;
}

.notification-detail {
  .detail-meta {
    margin-bottom: 20px;
    padding-bottom: 15px;
    border-bottom: 1px solid #ebeef5;
    color: #909399;
    font-size: 14px;
    display: flex;
    align-items: center;
    gap: 15px;
    
    .publish-time {
      color: #8e44ad;
    }
  }

  .detail-content {
    font-size: 14px;
    line-height: 1.8;
    color: #303133;

    :deep(p) {
      margin: 1em 0;
    }

    :deep(img) {
      max-width: 100%;
      height: auto;
      border-radius: 8px;
      box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
    }
    
    :deep(a) {
      color: #8e44ad;
      text-decoration: none;
      
      &:hover {
        text-decoration: underline;
      }
    }
    
    :deep(h1, h2, h3, h4, h5, h6) {
      margin-top: 20px;
      margin-bottom: 15px;
      color: #333;
    }
    
    :deep(blockquote) {
      border-left: 4px solid #8e44ad;
      padding: 10px 15px;
      background-color: rgba(142, 68, 173, 0.05);
      margin: 15px 0;
    }
  }
}

// 对话框样式
.dialog-header {
  display: flex;
  align-items: center;
  gap: 10px;
  
  .dialog-icon {
    color: #8e44ad;
    font-size: 20px;
  }
}

// 通知列表的过渡动画
.notification-fade-enter-active,
.notification-fade-leave-active {
  transition: all 0.5s;
}
.notification-fade-enter-from,
.notification-fade-leave-to {
  opacity: 0;
  transform: translateY(30px);
}

@media (max-width: 768px) {
  .notification-page {
    padding: 10px;
  }

  .notification-item {
    padding: 15px;
  }

  .notification-title {
    font-size: 16px;
  }

  .notification-summary {
    font-size: 13px;
  }
  
  .notification-icon {
    display: none;
  }
}
</style> 