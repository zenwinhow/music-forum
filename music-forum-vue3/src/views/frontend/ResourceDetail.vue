<template>
  <div class="resource-detail">
    <!-- 面包屑导航 -->
    <div class="breadcrumb">
      <el-breadcrumb separator="/">
        <el-breadcrumb-item :to="{ path: '/' }">首页</el-breadcrumb-item>
        <el-breadcrumb-item :to="{ path: '/resources' }">资源中心</el-breadcrumb-item>
        <el-breadcrumb-item>{{ resource.resourceName }}</el-breadcrumb-item>
      </el-breadcrumb>
    </div>

    <!-- 资源详情卡片 -->
    <div class="detail-card">
      <el-card>
        <template #header>
          <div class="card-header">
            <h2 class="resource-title">
              {{ resource.resourceName }}
              <el-tag size="small" type="success" class="category-tag">
                {{ resource.categoryName }}
              </el-tag>
            </h2>
          </div>
        </template>

        <div class="resource-info">
          <!-- 资源基本信息 -->
          <div class="info-section">
            <div class="info-item">
              <el-icon><User /></el-icon>
              <span>上传者：{{ resource.uploadUsername }}</span>
            </div>
            <div class="info-item">
              <el-icon><Timer /></el-icon>
              <span>上传时间：{{ formatDate(resource.createTime) }}</span>
            </div>
            <div class="info-item">
              <el-icon><Download /></el-icon>
              <span>下载次数：{{ resource.downloadCount }}</span>
            </div>
            <div class="info-item">
              <el-icon><Files /></el-icon>
              <span>文件大小：{{ formatFileSize(resource.fileSize * 1024) }}</span>
            </div>
            <div class="info-item">
              <el-icon><Document /></el-icon>
              <span>文件类型：{{ resource.fileType }}</span>
            </div>
          </div>

          <!-- 资源描述 -->
          <div class="description-section">
            <h3>资源描述</h3>
            <p>{{ resource.description || '暂无描述' }}</p>
          </div>

          <!-- 下载按钮 -->
          <div class="action-section">
            <el-button type="primary" size="large" @click="handleDownload" :loading="downloading">
              <el-icon><Download /></el-icon> 下载资源
            </el-button>
            <el-button type="danger" size="large" @click="handleReport">
              <el-icon><Warning /></el-icon> 举报资源
            </el-button>
          </div>
        </div>
      </el-card>
    </div>

    <!-- 相关资源推荐 -->
    <div class="related-resources" v-if="relatedResources.length > 0">
      <h3 class="section-title">相关资源推荐</h3>
      <el-row :gutter="20">
        <el-col :xs="24" :sm="12" :md="8" v-for="item in relatedResources" :key="item.id">
          <div class="resource-card" @click="goToResource(item.id)">
            <div class="resource-type">
              <el-icon v-if="item.fileType.includes('doc')"><Document /></el-icon>
              <el-icon v-else-if="item.fileType.includes('pdf')"><Tickets /></el-icon>
              <el-icon v-else-if="item.fileType.includes('jpg') || item.fileType.includes('png')"><Picture /></el-icon>
              <el-icon v-else-if="item.fileType.includes('mp4') || item.fileType.includes('avi')"><VideoPlay /></el-icon>
              <el-icon v-else><Files /></el-icon>
            </div>
            <div class="resource-info">
              <h3 class="resource-name">{{ item.resourceName }}</h3>
              <p class="resource-category">分类：{{ item.categoryName }}</p>
              <p class="resource-uploader">上传者：{{ item.uploadUsername }}</p>
              <div class="resource-size">{{ formatFileSize(item.fileSize * 1024) }}</div>
            </div>
          </div>
        </el-col>
      </el-row>
    </div>

    <!-- 举报对话框 -->
    <report-dialog
      v-model:visible="reportDialogVisible"
      :type="3"
      :target-id="Number(route.params.id)"
      :title="resource.resourceName"
      @success="onReportSuccess"
    />
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { useUserStore } from '@/store/user'
import { 
  User, Timer, Download, Document, Files, 
  Picture, VideoPlay, Tickets, Warning
} from '@element-plus/icons-vue'
import request from '@/utils/request'
import ReportDialog from '@/components/common/ReportDialog.vue'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()

// 资源详情数据
const resource = ref({})
const relatedResources = ref([])
const downloading = ref(false)
const reportDialogVisible = ref(false)

// 格式化日期
const formatDate = (date) => {
  if (!date) return ''
  return new Date(date).toLocaleString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  })
}

// 格式化文件大小
const formatFileSize = (bytes) => {
  if (bytes === 0) return '0 B'
  const k = 1024
  const sizes = ['B', 'KB', 'MB', 'GB', 'TB']
  const i = Math.floor(Math.log(bytes) / Math.log(k))
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
}

// 获取资源详情
const getResourceDetail = async () => {
  try {
    const res = await request.get(`/resource/${route.params.id}`,null,{
      showDefaultMsg:false,
      onSuccess:(data)=>{
        // 处理数据
        resource.value = {
          ...data,
          // 添加下载链接属性用于显示
          downloadUrl: `/api${data.filePath}`
        }
        // 获取相关资源
        getRelatedResources()
      }
    })
  } catch (error) {
    ElMessage.error('获取资源详情失败')
  }
}

// 获取相关资源
const getRelatedResources = async () => {
  try {
    const res = await request.get('/resource/getByCategory/' + resource.value.categoryId,null,{
      showDefaultMsg:false,
      onSuccess:(data)=>{
        // 过滤掉当前资源，并添加下载链接
        relatedResources.value = data
          .filter(item => item.id !== resource.value.id)
          .slice(0, 3)
          .map(item => ({
            ...item,
            // 添加完整下载链接
            downloadUrl: item.filePath && !item.filePath.startsWith('/api') ? 
              `/api${item.filePath}` : item.filePath
          }))
      }
    })
  } catch (error) {
    console.error('获取相关资源失败:', error)
  }
}

// 处理下载
const handleDownload = async () => {
  if (!userStore.isLoggedIn) {
    ElMessage.warning('请先登录后下载资源')
    return
  }

  try {
    downloading.value = true
    // 增加下载次数
    await request.put(`/resource/${resource.value.id}/download`)
    
    // 构建完整下载URL
    let downloadUrl = resource.value.filePath;
    
    // 检查URL是否已经包含了api前缀
    if (!downloadUrl.startsWith('/api') && !downloadUrl.startsWith('http')) {
      downloadUrl = `/api${downloadUrl}`;
    }
    
    console.log('下载文件URL:', downloadUrl);
    
    // 使用fetch API进行下载，添加token
    const response = await fetch(downloadUrl, {
      method: 'GET',
      headers: {
        'token': userStore.token
      }
    });
    
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    
    // 获取文件名
    const filename = resource.value.resourceName + '.' + resource.value.fileType;
    
    // 获取文件blob
    const blob = await response.blob();
    const url = window.URL.createObjectURL(blob);
    
    // 创建下载链接并模拟点击
    const a = document.createElement('a');
    a.href = url;
    a.download = filename;
    document.body.appendChild(a);
    a.click();
    
    // 清理
    window.URL.revokeObjectURL(url);
    document.body.removeChild(a);
    
    ElMessage.success('下载成功')
  } catch (error) {
    console.error('下载失败:', error);
    ElMessage.error('下载失败，请稍后重试')
  } finally {
    downloading.value = false
  }
}

// 跳转到其他资源详情页
const goToResource = (id) => {
  // 如果ID相同，刷新数据
  if (Number(route.params.id) === id) {
    getResourceDetail()
    return
  }
  
  // 不同资源，进行跳转
  router.push(`/resource/${id}`)
}

// 监听路由变化，重新加载数据
watch(() => route.params.id, (newId, oldId) => {
  if (newId !== oldId) {
    getResourceDetail()
  }
})

// 处理举报
const handleReport = () => {
  if (!userStore.isLoggedIn) {
    ElMessage.warning('请先登录')
    return
  }
  reportDialogVisible.value = true
  console.log('Resource report dialog should open now:', reportDialogVisible.value)
}

// 举报成功回调
const onReportSuccess = () => {
  ElMessage.success('举报已提交，感谢您的反馈')
}

onMounted(() => {
  getResourceDetail()
})
</script>

<style lang="scss" scoped>
.resource-detail {
  padding: 20px;
  max-width: 1200px;
  margin: 0 auto;

  .breadcrumb {
    margin-bottom: 20px;
  }

  .detail-card {
    margin-bottom: 30px;

    .card-header {
      display: flex;
      align-items: center;
      justify-content: space-between;

      .resource-title {
        margin: 0;
        font-size: 1.5rem;
        display: flex;
        align-items: center;
        gap: 10px;

        .category-tag {
          margin-left: 10px;
        }
      }
    }

    .resource-info {
      .info-section {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
        gap: 20px;
        margin-bottom: 30px;

        .info-item {
          display: flex;
          align-items: center;
          gap: 8px;
          color: #666;

          .el-icon {
            font-size: 18px;
            color: #409eff;
          }
        }
      }

      .description-section {
        margin-bottom: 30px;
        padding: 20px;
        background-color: #f8f9fa;
        border-radius: 4px;

        h3 {
          margin-top: 0;
          margin-bottom: 10px;
          color: #333;
        }

        p {
          margin: 0;
          line-height: 1.6;
          color: #666;
        }
      }

      .action-section {
        text-align: center;
      }
    }
  }

  .related-resources {
    margin-top: 40px;

    .section-title {
      margin-bottom: 20px;
      font-size: 1.2rem;
      color: #333;
    }

    .resource-card {
      padding: 15px;
      border: 1px solid #ebeef5;
      border-radius: 4px;
      transition: all 0.3s;
      cursor: pointer;
      margin-bottom: 20px;

      &:hover {
        transform: translateY(-5px);
        box-shadow: 0 2px 12px 0 rgba(0,0,0,0.1);
      }

      .resource-type {
        font-size: 24px;
        color: #409eff;
        margin-bottom: 10px;
      }

      .resource-info {
        .resource-name {
          margin: 0 0 10px 0;
          font-size: 1.1rem;
          color: #333;
        }

        p {
          margin: 5px 0;
          color: #666;
          font-size: 0.9rem;
        }

        .resource-size {
          color: #909399;
          font-size: 0.9rem;
        }
      }
    }
  }
}
</style> 