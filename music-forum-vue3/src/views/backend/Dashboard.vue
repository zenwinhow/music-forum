<template>
  <div class="dashboard">
    <!-- 欢迎卡片 -->
    <el-card class="welcome-card">
      <template #header>
        <div class="welcome-header">
          <el-avatar :size="64" :src="userInfo?.avatar ? '/api' + userInfo.avatar : ''">
            {{ userInfo?.name?.charAt(0) || userInfo?.username?.charAt(0) }}
          </el-avatar>
          <div class="welcome-info">
            <h2>欢迎回来, {{ userInfo?.realName || userInfo?.username }}</h2>
            <p>{{ currentTime }}</p>
          </div>
        </div>
      </template>
      <div class="role-info">
        <el-tag>{{ roleLabel }}</el-tag>
      </div>
    </el-card>

    <!-- 数据统计卡片 -->
    <div class="data-overview">
      <el-row :gutter="20">
        <el-col :span="6" v-for="(item, index) in statsCards" :key="index">
          <el-card shadow="hover" class="stats-card">
            <div class="stats-icon" :style="{ backgroundColor: item.bgColor }">
              <el-icon :size="36" :color="item.color">
                <component :is="item.icon"></component>
              </el-icon>
            </div>
            <div class="stats-info">
              <div class="stats-value">{{ item.value }}</div>
              <div class="stats-label">{{ item.label }}</div>
              <div class="stats-today">
                今日: <b>+{{ item.today }}</b>
              </div>
            </div>
          </el-card>
        </el-col>
      </el-row>
    </div>

    <!-- 图表区域 -->
    <div class="charts-section">
      <el-row :gutter="20">
        <!-- 热门帖子 -->
        <el-col :span="12">
          <el-card class="chart-card">
            <template #header>
              <div class="card-header">
                <span>热门帖子</span>
                <el-button text type="primary" @click="goToPostList">查看全部</el-button>
              </div>
            </template>
            <div class="hot-posts-list">
              <el-table :data="hotPosts" style="width: 100%" :show-header="false">
                <el-table-column width="40">
                  <template #default="scope">
                    <div class="post-rank" :class="scope.$index < 3 ? 'top-rank' : ''">
                      {{ scope.$index + 1 }}
                    </div>
                  </template>
                </el-table-column>
                <el-table-column prop="title">
                  <template #default="scope">
                    <span class="post-title" @click="viewPost(scope.row)">{{ scope.row.title }}</span>
                    <div class="post-info">
                      <el-icon><User /></el-icon> {{ scope.row.authorName }}
                      <el-divider direction="vertical"></el-divider>
                      <el-icon><View /></el-icon> {{ scope.row.viewCount }}
                    </div>
                  </template>
                </el-table-column>
              </el-table>
            </div>
          </el-card>
        </el-col>

        <!-- 版区统计 -->
        <el-col :span="12">
          <el-card class="chart-card">
            <template #header>
              <div class="card-header">
                <span>版区活跃度</span>
              </div>
            </template>
            <div id="section-chart" style="height: 310px;"></div>
          </el-card>
        </el-col>
      </el-row>

      <el-row :gutter="20" style="margin-top: 20px;">
        <!-- 用户活跃度 -->
        <el-col :span="12">
          <el-card class="chart-card">
            <template #header>
              <div class="card-header">
                <span>活跃用户</span>
              </div>
            </template>
            <div class="active-users-list">
              <el-table :data="activeUsers" style="width: 100%">
                <el-table-column width="60">
                  <template #default="scope">
                    <el-avatar :size="40" :src="scope.row.avatar ? '/api' + scope.row.avatar : ''">
                      {{ (scope.row.realName || scope.row.username)?.charAt(0) }}
                    </el-avatar>
                  </template>
                </el-table-column>
                <el-table-column prop="username">
                  <template #default="scope">
                    <div class="user-info">
                      <span class="user-name">{{ scope.row.realName || scope.row.username }}</span>
                      <div class="post-count">
                        <el-icon><Document /></el-icon> 发帖数: {{ scope.row.postCount }}
                      </div>
                    </div>
                  </template>
                </el-table-column>
              </el-table>
            </div>
          </el-card>
        </el-col>

        <!-- 资源统计 -->
        <el-col :span="12">
          <el-card class="chart-card">
            <template #header>
              <div class="card-header">
                <span>热门资源</span>
                <el-button text type="primary" @click="goToResourceList">查看全部</el-button>
              </div>
            </template>
            <div class="hot-resources-list">
              <el-table :data="hotResources" style="width: 100%">
                <el-table-column prop="resourceName" width="220">
                  <template #default="scope">
                    <div class="resource-name-cell">
                      <el-icon class="file-icon" :class="getResourceIconClass(scope.row.fileType)">
                        <component :is="getResourceIcon(scope.row.fileType)"></component>
                      </el-icon>
                      <el-tooltip :content="scope.row.resourceName" placement="top">
                        <span class="resource-name">{{ scope.row.resourceName }}</span>
                      </el-tooltip>
                    </div>
                  </template>
                </el-table-column>
                <el-table-column prop="downloadCount" width="100">
                  <template #default="scope">
                    <div class="download-count">
                      <el-icon><Download /></el-icon> {{ scope.row.downloadCount }}
                    </div>
                  </template>
                </el-table-column>
                <el-table-column>
                  <template #default="scope">
                    <div class="resource-uploader">
                      <el-icon><User /></el-icon> {{ scope.row.uploadUsername }}
                    </div>
                  </template>
                </el-table-column>
              </el-table>
            </div>
          </el-card>
        </el-col>
      </el-row>
    </div>
  </div>
</template>

<script setup>
import { computed, ref, onMounted, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '@/store/user'
// 修改ECharts的导入方式，按需导入而不是全量导入
import * as echarts from 'echarts/core'
import { PieChart } from 'echarts/charts'
import { 
  TooltipComponent, 
  LegendComponent,
  GridComponent 
} from 'echarts/components'
import { CanvasRenderer } from 'echarts/renderers'
import request from '@/utils/request'

// 注册必需的组件
echarts.use([
  PieChart,
  TooltipComponent,
  LegendComponent,
  GridComponent,
  CanvasRenderer
])

import { 
  User, View, Document, Download, 
  UserFilled, ChatDotRound, Folder, Document as DocumentIcon, Warning
} from '@element-plus/icons-vue'

const router = useRouter()
const userStore = useUserStore()
const userInfo = computed(() => userStore.userInfo)

// 图表实例
const sectionChart = ref(null)

// 角色标签
const roleLabel = computed(() => {
  const roleMap = {
    1: '系统管理员',
    2: '用户'
  }
  return roleMap[userInfo.value?.role] || '未知角色'
})

// 当前时间
const currentTime = ref('')
const updateTime = () => {
  const now = new Date()
  const options = { 
    year: 'numeric', 
    month: 'long', 
    day: 'numeric', 
    weekday: 'long',
    hour: '2-digit',
    minute: '2-digit'
  }
  currentTime.value = now.toLocaleDateString('zh-CN', options)
}

// 统计数据
const statistics = ref({
  overview: {
    userCount: 0,
    postCount: 0,
    commentCount: 0,
    resourceCount: 0,
    pendingReportCount: 0,
    todayUserCount: 0,
    todayPostCount: 0,
    todayCommentCount: 0,
    todayResourceCount: 0
  },
  posts: {
    hotPosts: [],
    sectionPostCounts: []
  },
  users: {
    activeUsers: []
  },
  resources: {
    hotResources: []
  }
})

// 统计卡片数据
const statsCards = computed(() => [
  {
    label: '用户总数',
    value: statistics.value.overview?.userCount || 0,
    icon: UserFilled,
    color: '#409EFF',
    bgColor: 'rgba(64, 158, 255, 0.1)',
    today: statistics.value.overview?.todayUserCount || 0
  },
  {
    label: '帖子总数',
    value: statistics.value.overview?.postCount || 0,
    icon: DocumentIcon,
    color: '#67C23A',
    bgColor: 'rgba(103, 194, 58, 0.1)',
    today: statistics.value.overview?.todayPostCount || 0
  },
  {
    label: '评论总数',
    value: statistics.value.overview?.commentCount || 0,
    icon: ChatDotRound,
    color: '#E6A23C',
    bgColor: 'rgba(230, 162, 60, 0.1)',
    today: statistics.value.overview?.todayCommentCount || 0
  },
  {
    label: '资源总数',
    value: statistics.value.overview?.resourceCount || 0,
    icon: Folder,
    color: '#909399',
    bgColor: 'rgba(144, 147, 153, 0.1)',
    today: statistics.value.overview?.todayResourceCount || 0
  }
])

// 热门帖子数据
const hotPosts = computed(() => {
  try {
    return statistics.value.posts?.hotPosts || []
  } catch (error) {
    console.error('获取热门帖子数据失败', error)
    return []
  }
})

// 活跃用户数据
const activeUsers = computed(() => {
  try {
    return statistics.value.users?.activeUsers || []
  } catch (error) {
    console.error('获取活跃用户数据失败', error)
    return []
  }
})

// 热门资源数据
const hotResources = computed(() => {
  try {
    return statistics.value.resources?.hotResources || []
  } catch (error) {
    console.error('获取热门资源数据失败', error)
    return []
  }
})

// 获取统计数据
const fetchStatistics = async () => {
  try {
    const { data } = await request.get('/statistics/all', null, {
      showDefaultMsg: false,
      onSuccess: (res) => {
        statistics.value = res
        // 初始化图表
        renderSectionChart()
      }
    })
  } catch (error) {
    console.error('获取统计数据失败', error)
  }
}

// 渲染版区统计图表
const renderSectionChart = () => {
  try {
    if (!statistics.value.posts?.sectionPostCounts || statistics.value.posts.sectionPostCounts.length === 0) {
      console.warn('没有版区统计数据可用');
      return;
    }
    
    const chartDom = document.getElementById('section-chart');
    if (!chartDom) {
      console.warn('找不到图表DOM元素');
      return;
    }
    
    // 如果已经有实例，先销毁
    if (sectionChart.value) {
      sectionChart.value.dispose();
    }
    
    sectionChart.value = echarts.init(chartDom);
    
    const sections = statistics.value.posts.sectionPostCounts;
    const option = {
      tooltip: {
        trigger: 'item',
        formatter: '{a} <br/>{b}: {c} ({d}%)'
      },
      legend: {
        orient: 'vertical',
        right: 10,
        top: 'center',
        data: sections.map(item => item.sectionName)
      },
      series: [
        {
          name: '版区统计',
          type: 'pie',
          radius: ['40%', '70%'],
          avoidLabelOverlap: false,
          itemStyle: {
            borderRadius: 10,
            borderColor: '#fff',
            borderWidth: 2
          },
          label: {
            show: false,
            position: 'center'
          },
          emphasis: {
            label: {
              show: true,
              fontSize: 20,
              fontWeight: 'bold'
            }
          },
          labelLine: {
            show: false
          },
          data: sections.map(item => ({
            value: item.postCount || 0,
            name: item.sectionName
          }))
        }
      ]
    };
    
    sectionChart.value.setOption(option);
    
    // 为了解决初始渲染时可能的大小问题，延迟执行一次resize
    setTimeout(() => {
      if (sectionChart.value) {
        sectionChart.value.resize();
      }
    }, 200);
  } catch (error) {
    console.error('渲染版区统计图表失败', error);
  }
}

// 获取资源图标
const getResourceIcon = (fileType) => {
  if (!fileType) return DocumentIcon
  
  fileType = fileType.toLowerCase()
  
  if (fileType.includes('image') || ['jpg', 'jpeg', 'png', 'gif', 'bmp'].includes(fileType)) {
    return 'Picture'
  } else if (fileType.includes('pdf') || fileType === 'pdf') {
    return 'Document'
  } else if (fileType.includes('word') || ['doc', 'docx'].includes(fileType)) {
    return 'Document'
  } else if (fileType.includes('excel') || ['xls', 'xlsx'].includes(fileType)) {
    return 'Document'
  } else if (fileType.includes('ppt') || ['ppt', 'pptx'].includes(fileType)) {
    return 'Document'
  } else if (fileType.includes('zip') || fileType.includes('rar') || ['zip', 'rar', '7z'].includes(fileType)) {
    return 'Folder'
  } else if (fileType.includes('video') || ['mp4', 'avi', 'mov', 'flv', 'wmv'].includes(fileType)) {
    return 'VideoPlay'
  } else if (fileType.includes('audio') || ['mp3', 'wav', 'ogg', 'flac'].includes(fileType)) {
    return 'Headset'
  } else {
    return 'Document'
  }
}

// 获取资源图标样式类
const getResourceIconClass = (fileType) => {
  if (!fileType) return ''
  
  fileType = fileType.toLowerCase()
  
  if (fileType.includes('image') || ['jpg', 'jpeg', 'png', 'gif', 'bmp'].includes(fileType)) {
    return 'image-file'
  } else if (fileType.includes('pdf') || fileType === 'pdf') {
    return 'pdf-file'
  } else if (fileType.includes('word') || ['doc', 'docx'].includes(fileType)) {
    return 'word-file'
  } else if (fileType.includes('excel') || ['xls', 'xlsx'].includes(fileType)) {
    return 'excel-file'
  } else if (fileType.includes('ppt') || ['ppt', 'pptx'].includes(fileType)) {
    return 'ppt-file'
  } else if (fileType.includes('zip') || fileType.includes('rar') || ['zip', 'rar', '7z'].includes(fileType)) {
    return 'zip-file'
  } else if (fileType.includes('video') || ['mp4', 'avi', 'mov', 'flv', 'wmv'].includes(fileType)) {
    return 'video-file'
  } else if (fileType.includes('audio') || ['mp3', 'wav', 'ogg', 'flac'].includes(fileType)) {
    return 'audio-file'
  } else {
    return 'other-file'
  }
}

// 查看帖子详情
const viewPost = (post) => {
  router.push(`/back/post/${post.id}`)
}

// 跳转到帖子列表
const goToPostList = () => {
  router.push('/back/posts')
}

// 跳转到资源列表
const goToResourceList = () => {
  router.push('/back/resources')
}

// 窗口大小改变时重新渲染图表
const handleResize = () => {
  if (sectionChart.value) {
    sectionChart.value.resize()
  }
}

// 定义一个变量用于存储定时器ID，以便在组件卸载时清除
let timeInterval = null

onMounted(() => {
  // 更新时间
  updateTime()
  // 每分钟更新一次时间
  timeInterval = setInterval(updateTime, 60000)
  
  // 获取统计数据
  fetchStatistics()

  // 监听窗口大小变化
  window.addEventListener('resize', handleResize)
})

onUnmounted(() => {
  // 清除定时器
  if (timeInterval) {
    clearInterval(timeInterval)
  }
  // 移除事件监听
  window.removeEventListener('resize', handleResize)
  // 销毁图表实例
  if (sectionChart.value) {
    sectionChart.value.dispose()
  }
})
</script>

<style lang="scss" scoped>
.dashboard {
  .welcome-card {
    margin-bottom: 20px;
    transition: all 0.3s ease;
    
    &:hover {
      transform: translateY(-2px);
      box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
    }
    
    .welcome-header {
      display: flex;
      align-items: center;
      gap: 20px;
      
      .el-avatar {
        transition: transform 0.3s ease;
        
        &:hover {
          transform: scale(1.1);
        }
      }
      
      .welcome-info {
        h2 {
          margin: 0 0 8px 0;
          font-size: 24px;
          background: linear-gradient(to right, #409eff, #67c23a);
          -webkit-background-clip: text;
          -webkit-text-fill-color: transparent;
          animation: gradientText 6s infinite;
        }
        p {
          margin: 0;
          color: #666;
        }
      }
    }
    
    .role-info {
      margin-top: 16px;
    }
  }
  
  .data-overview {
    margin-bottom: 20px;
    
    .stats-card {
      height: 120px;
      display: flex;
      flex-direction: row;
      align-items: center;
      padding: 0 16px;
      transition: all 0.3s ease;
      
      &:hover {
        transform: translateY(-4px);
        box-shadow: 0 8px 16px rgba(0, 0, 0, 0.1);
      }
      
      .stats-icon {
        display: flex;
        align-items: center;
        justify-content: center;
        width: 64px;
        height: 64px;
        border-radius: 12px;
        background-color: rgba(64, 158, 255, 0.1);
        margin-right: 16px;
        flex-shrink: 0;
      }
      
      .stats-info {
        flex: 1;
        
        .stats-value {
          font-size: 28px;
          font-weight: bold;
          color: #333;
          margin-bottom: 6px;
          line-height: 1.2;
        }
        
        .stats-label {
          font-size: 14px;
          color: #888;
        }
      }
      
      .stats-today {
        font-size: 12px;
        color: #67c23a;
        margin-top: 10px;
      }
    }
  }
  
  .charts-section {
    .chart-card {
      height: 400px;
      margin-bottom: 20px;
      transition: all 0.3s ease;
      
      &:hover {
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
      }
      
      .card-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        font-weight: bold;
      }
      
      .hot-posts-list {
        .post-rank {
          display: flex;
          align-items: center;
          justify-content: center;
          width: 24px;
          height: 24px;
          border-radius: 4px;
          background-color: #f2f2f2;
          color: #666;
          font-weight: bold;
          
          &.top-rank {
            background-color: #f56c6c;
            color: white;
          }
        }
        
        .post-title {
          font-size: 14px;
          color: #333;
          cursor: pointer;
          display: block;
          white-space: nowrap;
          overflow: hidden;
          text-overflow: ellipsis;
          max-width: 90%;
          
          &:hover {
            color: #409eff;
          }
        }
        
        .post-info {
          display: flex;
          align-items: center;
          font-size: 12px;
          color: #999;
          margin-top: 4px;
          
          .el-icon {
            margin-right: 4px;
          }
        }
      }
      
      .active-users-list {
        .user-info {
          display: flex;
          flex-direction: column;
          
          .user-name {
            font-size: 14px;
            color: #333;
            margin-bottom: 4px;
          }
          
          .post-count {
            font-size: 12px;
            color: #999;
            display: flex;
            align-items: center;
            
            .el-icon {
              margin-right: 4px;
            }
          }
        }
      }
      
      .hot-resources-list {
        .resource-name-cell {
          display: flex;
          align-items: center;
          
          .file-icon {
            margin-right: 8px;
            font-size: 18px;
            
            &.image-file { color: #67c23a; }
            &.pdf-file { color: #f56c6c; }
            &.word-file { color: #409eff; }
            &.excel-file { color: #67c23a; }
            &.ppt-file { color: #e6a23c; }
            &.zip-file { color: #909399; }
            &.video-file { color: #9370db; }
            &.audio-file { color: #20b2aa; }
            &.other-file { color: #909399; }
          }
          
          .resource-name {
            font-size: 14px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            max-width: 180px;
            display: inline-block;
          }
        }
        
        .download-count {
          display: flex;
          align-items: center;
          font-size: 14px;
          color: #666;
          
          .el-icon {
            margin-right: 4px;
            color: #409eff;
          }
        }
        
        .resource-uploader {
          display: flex;
          align-items: center;
          font-size: 14px;
          color: #666;
          
          .el-icon {
            margin-right: 4px;
          }
        }
      }
    }
  }
}

@keyframes gradientText {
  0% { background-position: 0% 50% }
  50% { background-position: 100% 50% }
  100% { background-position: 0% 50% }
}
.dashboard .data-overview .stats-card{
  height: auto;
}
</style> 
