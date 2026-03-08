<template>
  <div class="notification-panel">
    <div class="panel-header">
      <h3 class="panel-title">
        <el-icon><Bell /></el-icon>
        系统通知
      </h3>
      <el-button v-if="notifications.length > 0" text @click="showAllNotifications">查看全部</el-button>
    </div>

    <div v-if="loading" class="loading-container">
      <el-skeleton :rows="3" animated />
    </div>
    
    <div v-else-if="notifications.length === 0" class="empty-container">
      <el-empty description="暂无系统通知" />
    </div>
    
    <div v-else class="notification-list">
      <div
        v-for="item in notifications.slice(0, displayCount)"
        :key="item.id"
        class="notification-item"
        @click="handleViewNotification(item)"
      >
        <div class="notification-content">
          <div class="notification-title">{{ item.title }}</div>
          <div class="notification-time">{{ formatDate(item.createTime) }}</div>
        </div>
        <el-icon><ArrowRight /></el-icon>
      </div>
    </div>

    <!-- 查看通知详情对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="currentNotification.title"
      width="60%"
      destroy-on-close
    >
      <div class="notification-detail">
        <div class="notification-meta">
          <span>发布时间：{{ formatDate(currentNotification.createTime) }}</span>
        </div>
        <div class="notification-body">
          {{ currentNotification.content }}
        </div>
      </div>
    </el-dialog>

    <!-- 所有通知列表抽屉 -->
    <el-drawer
      v-model="drawerVisible"
      title="系统通知"
      direction="rtl"
      size="80%"
    >
      <div class="all-notifications">
        <el-table :data="notifications" style="width: 100%" v-loading="loading">
          <el-table-column prop="title" label="通知标题" min-width="200" show-overflow-tooltip />
          <el-table-column prop="createTime" label="发布时间" width="180">
            <template #default="{ row }">
              {{ formatDate(row.createTime) }}
            </template>
          </el-table-column>
          <el-table-column label="操作" width="100">
            <template #default="{ row }">
              <el-button type="primary" link @click="handleViewFromDrawer(row)">查看</el-button>
            </template>
          </el-table-column>
        </el-table>
      </div>
    </el-drawer>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { Bell, ArrowRight } from '@element-plus/icons-vue'
import request from '@/utils/request'

// 控制显示的通知数量
const displayCount = ref(3)

// 通知数据
const notifications = ref([])
const loading = ref(false)

// 对话框控制
const dialogVisible = ref(false)
const currentNotification = ref({})

// 抽屉控制
const drawerVisible = ref(false)

// 获取所有已发布通知
const fetchNotifications = () => {
  loading.value = true
  
  request.get('/notification/published', {
    showDefaultMsg: false,
    onSuccess: (data) => {
      notifications.value = data
    },
    onError: (error) => {
      console.error('获取通知失败:', error)
    },
    onComplete: () => {
      loading.value = false
    }
  })
}

// 格式化日期
const formatDate = (date) => {
  if (!date) return ''
  const d = new Date(date)
  const year = d.getFullYear()
  const month = String(d.getMonth() + 1).padStart(2, '0')
  const day = String(d.getDate()).padStart(2, '0')
  return `${year}-${month}-${day}`
}

// 查看通知详情
const handleViewNotification = (notification) => {
  currentNotification.value = notification
  dialogVisible.value = true
}

// 从抽屉中查看通知
const handleViewFromDrawer = (notification) => {
  currentNotification.value = notification
  dialogVisible.value = true
}

// 显示所有通知
const showAllNotifications = () => {
  drawerVisible.value = true
}

onMounted(() => {
  fetchNotifications()
})
</script>

<style scoped>
.notification-panel {
  background-color: #fff;
  border-radius: 4px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
  padding: 16px;
  margin-bottom: 20px;
}

.panel-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
  padding-bottom: 10px;
  border-bottom: 1px solid #ebeef5;
}

.panel-title {
  margin: 0;
  font-size: 16px;
  display: flex;
  align-items: center;
  gap: 8px;
  color: #303133;
}

.loading-container,
.empty-container {
  padding: 20px 0;
}

.notification-list {
  display: flex;
  flex-direction: column;
}

.notification-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 12px 0;
  border-bottom: 1px solid #ebeef5;
  cursor: pointer;
  transition: background-color 0.3s;
}

.notification-item:hover {
  background-color: #f5f7fa;
}

.notification-item:last-child {
  border-bottom: none;
}

.notification-content {
  flex: 1;
  overflow: hidden;
}

.notification-title {
  font-size: 14px;
  color: #303133;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  margin-bottom: 4px;
}

.notification-time {
  font-size: 12px;
  color: #909399;
}

.notification-detail {
  padding: 10px;
}

.notification-meta {
  margin-bottom: 20px;
  color: #909399;
  font-size: 14px;
}

.notification-body {
  font-size: 15px;
  line-height: 1.8;
  color: #303133;
  white-space: pre-wrap;
}

.all-notifications {
  padding: 20px;
}
</style> 