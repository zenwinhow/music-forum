<template>
  <div class="search-page">
    <div class="search-header">
      <div class="search-container">
        <el-input
          v-model="keyword"
          placeholder="搜索帖子、资源..."
          clearable
          class="search-input"
          size="large"
          @keyup.enter="handleSearch"
        >
          <template #prefix>
            <el-icon><Search /></el-icon>
          </template>
        </el-input>
        <div class="search-options">
          <el-radio-group v-model="searchType" @change="handleSearch">
            <el-radio-button label="all">全部</el-radio-button>
            <el-radio-button label="post">帖子</el-radio-button>
            <el-radio-button label="resource">资源</el-radio-button>
          </el-radio-group>
        </div>
      </div>
    </div>

    <div class="search-results" v-loading="loading">
      <!-- 帖子搜索结果 -->
      <div class="result-section" v-if="searchType === 'all' || searchType === 'post'">
        <h2>帖子</h2>
        <div class="posts-list" v-if="posts.records && posts.records.length > 0">
          <div v-for="post in posts.records" :key="post.id" class="post-card">
            <div class="post-meta">
              <el-avatar :src="'/api' + post.user?.avatar" :size="40">
                {{ post.user?.username?.charAt(0) }}
              </el-avatar>
              <div class="post-info">
                <span class="author">{{ post.user?.username }}</span>
                <span class="time">{{ formatDate(post.createTime) }}</span>
              </div>
            </div>
            <router-link :to="`/forum/post/${post.id}`" class="post-content">
              <h3>{{ post.title }}</h3>
              <p>{{ post.content.substring(0, 200) }}...</p>
            </router-link>
            <div class="post-stats">
              <span><el-icon><View /></el-icon> {{ post.viewCount }}</span>
              <span><el-icon><ChatLineRound /></el-icon> {{ post.commentCount }}</span>
            </div>
          </div>
          <el-pagination
            v-if="posts.total > 10"
            :current-page="currentPage"
            :page-size="pageSize"
            :total="posts.total"
            @current-change="handlePageChange"
            layout="prev, pager, next"
            background
          />
        </div>
        <el-empty v-else description="暂无相关帖子" />
      </div>

      <!-- 资源搜索结果 -->
      <div class="result-section" v-if="searchType === 'all' || searchType === 'resource'">
        <h2>资源</h2>
        <div class="resources-grid" v-if="resources.records && resources.records.length > 0">
          <div v-for="resource in resources.records" :key="resource.id" class="resource-card">
            <div class="resource-icon">
              <el-icon>
                <component :is="getResourceIcon(resource.fileType)" />
              </el-icon>
            </div>
            <div class="resource-info">
              <h3>{{ resource.resourceName }}</h3>
              <p>{{ resource.description || '暂无描述' }}</p>
              <div class="resource-meta">
                <span>{{ formatFileSize(resource.fileSize * 1024) }}</span>
                <span>{{ formatDate(resource.createTime) }}</span>
              </div>
            </div>
          </div>
          <el-pagination
            v-if="resources.total > 10"
            :current-page="currentPage"
            :page-size="pageSize"
            :total="resources.total"
            @current-change="handlePageChange"
            layout="prev, pager, next"
            background
          />
        </div>
        <el-empty v-else description="暂无相关资源" />
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { Search, View, ChatLineRound, Document, Tickets, Picture, VideoPlay, Files } from '@element-plus/icons-vue'
import request from '@/utils/request'

const route = useRoute()
const router = useRouter()

const keyword = ref('')
const searchType = ref('all')
const currentPage = ref(1)
const pageSize = ref(10)
const loading = ref(false)

const posts = ref({ records: [], total: 0 })
const resources = ref({ records: [], total: 0 })

// 初始化搜索参数
onMounted(() => {
  if (route.query.keyword) {
    keyword.value = route.query.keyword
    searchType.value = route.query.type || 'all'
    handleSearch()
  }
})

// 处理搜索
const handleSearch = async () => {
  if (!keyword.value.trim()) {
    return
  }

  loading.value = true
  try {
    const response = await request.get('/search', {
      keyword: keyword.value,
      type: searchType.value,
      currentPage: currentPage.value,
      size: pageSize.value
    }, {
      showDefaultMsg: false,
      onSuccess: (data) => {
        if (data.posts) {
          posts.value = data.posts
        }
        if (data.resources) {
          resources.value = data.resources
        }
        
        // 更新URL参数
        router.push({
          query: {
            keyword: keyword.value,
            type: searchType.value
          }
        })
      }
    })
  } catch (error) {
    console.error('搜索失败:', error)
  } finally {
    loading.value = false
  }
}

// 处理分页
const handlePageChange = (page) => {
  currentPage.value = page
  handleSearch()
}

// 格式化日期
const formatDate = (dateString) => {
  const date = new Date(dateString)
  const now = new Date()
  const diff = Math.floor((now - date) / 1000) // 秒数差

  if (diff < 60) {
    return "刚刚"
  } else if (diff < 3600) {
    return Math.floor(diff / 60) + "分钟前"
  } else if (diff < 86400) {
    return Math.floor(diff / 3600) + "小时前"
  } else if (diff < 2592000) {
    return Math.floor(diff / 86400) + "天前"
  } else {
    return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, "0")}-${String(date.getDate()).padStart(2, "0")}`
  }
}

// 格式化文件大小
const formatFileSize = (bytes) => {
  if (bytes === 0) return "0 B"
  const k = 1024
  const sizes = ["B", "KB", "MB", "GB", "TB"]
  const i = Math.floor(Math.log(bytes) / Math.log(k))
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + " " + sizes[i]
}

// 获取资源图标
const getResourceIcon = (fileType) => {
  if (fileType.includes('doc')) return 'Document'
  if (fileType.includes('pdf')) return 'Tickets'
  if (fileType.includes('jpg') || fileType.includes('png')) return 'Picture'
  if (fileType.includes('mp4') || fileType.includes('avi')) return 'VideoPlay'
  return 'Files'
}
</script>

<style scoped>
.search-page {
  min-height: 100vh;
  background-color: #f6f8fa;
  padding: 20px;
}

.search-header {
  background: #fff;
  padding: 20px 0;
  margin-bottom: 20px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.search-container {
  max-width: 800px;
  margin: 0 auto;
  padding: 0 20px;
}

.search-input {
  margin-bottom: 16px;
}

.search-input :deep(.el-input__wrapper) {
  border-radius: 12px;
  padding: 4px 16px;
}

.search-options {
  display: flex;
  justify-content: center;
}

.search-results {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 20px;
}

.result-section {
  background: #fff;
  border-radius: 12px;
  padding: 24px;
  margin-bottom: 24px;
}

.result-section h2 {
  font-size: 20px;
  font-weight: 600;
  margin: 0 0 20px;
  color: #1a1a1a;
}

/* 帖子卡片样式 */
.posts-list {
  display: grid;
  gap: 20px;
}

.post-card {
  padding: 20px;
  border-radius: 12px;
  background: #f8f9fa;
  transition: transform 0.2s;
}

.post-card:hover {
  transform: translateY(-2px);
}

.post-meta {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 16px;
}

.post-info {
  display: flex;
  flex-direction: column;
}

.author {
  font-size: 14px;
  font-weight: 500;
  color: #1a1a1a;
}

.time {
  font-size: 12px;
  color: #8c8c8c;
}

.post-content {
  text-decoration: none;
  color: inherit;
  display: block;
}

.post-content h3 {
  font-size: 16px;
  font-weight: 500;
  color: #1a1a1a;
  margin: 0 0 8px;
}

.post-content p {
  font-size: 14px;
  color: #666;
  margin: 0;
  line-height: 1.5;
}

.post-stats {
  display: flex;
  gap: 16px;
  margin-top: 16px;
  font-size: 13px;
  color: #8c8c8c;
}

.post-stats span {
  display: flex;
  align-items: center;
  gap: 4px;
}

/* 资源卡片样式 */
.resources-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 20px;
}

.resource-card {
  padding: 20px;
  border-radius: 12px;
  background: #f8f9fa;
  display: flex;
  gap: 16px;
  transition: transform 0.2s;
}

.resource-card:hover {
  transform: translateY(-2px);
}

.resource-icon {
  width: 40px;
  height: 40px;
  border-radius: 10px;
  background: #e6f4ff;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #409EFF;
}

.resource-info {
  flex: 1;
}

.resource-info h3 {
  font-size: 15px;
  font-weight: 500;
  color: #1a1a1a;
  margin: 0 0 4px;
}

.resource-info p {
  font-size: 13px;
  color: #666;
  margin: 0 0 8px;
}

.resource-meta {
  display: flex;
  justify-content: space-between;
  font-size: 12px;
  color: #8c8c8c;
}

/* 分页样式 */
.el-pagination {
  margin-top: 20px;
  justify-content: center;
}

@media (max-width: 768px) {
  .search-page {
    padding: 10px;
  }

  .search-container {
    padding: 0 15px;
  }

  .search-results {
    padding: 0 15px;
  }

  .result-section {
    padding: 16px;
  }

  .resources-grid {
    grid-template-columns: 1fr;
  }
}
</style> 