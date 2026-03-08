# 创建新文件
<template>
  <div class="resources">
    <!-- 页面标题 -->
    <div class="page-header">
      <div class="header-title">
        <el-icon><Collection /></el-icon>
        <h1>资源中心</h1>
      </div>
      <div class="header-actions">
        <el-button type="primary" color="#8e44ad" round @click="handleUpload" v-if="userStore.isLoggedIn">
          <el-icon><Upload /></el-icon> 上传资源
        </el-button>
      </div>
    </div>

    <!-- 搜索和筛选区域 -->
    <div class="filter-section">
      <el-form :inline="true" :model="queryParams" class="filter-form">
        <el-form-item label="资源名称">
          <el-input
            v-model="queryParams.resourceName"
            placeholder="请输入资源名称"
            clearable
            @keyup.enter="handleSearch"
          />
        </el-form-item>
        <el-form-item label="资源分类">
          <el-select style="width:200px" v-model="queryParams.categoryId" placeholder="请选择分类" clearable>
            <el-option
              v-for="item in categories"
              :key="item.id"
              :label="item.categoryName"
              :value="item.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="文件类型">
          <el-select style="width:200px" v-model="queryParams.fileType" placeholder="请选择文件类型" clearable>
            <el-option label="Word (docx)" value="docx" />
            <el-option label="Word (doc)" value="doc" />
            <el-option label="PDF (pdf)" value="pdf" />
            <el-option label="PPT (pptx)" value="pptx" />
            <el-option label="PPT (ppt)" value="ppt" />
            <el-option label="Excel (xlsx)" value="xlsx" />
            <el-option label="Excel (xls)" value="xls" />
            <el-option label="图片 (jpg)" value="jpg" />
            <el-option label="图片 (png)" value="png" />
            <el-option label="图片 (gif)" value="gif" />
            <el-option label="视频 (mp4)" value="mp4" />
            <el-option label="视频 (avi)" value="avi" />
            <el-option label="压缩包 (zip)" value="zip" />
            <el-option label="压缩包 (rar)" value="rar" />
            <el-option label="其他" value="other" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" color="#8e44ad" round @click="handleSearch">
            <el-icon><Search /></el-icon> 搜索
          </el-button>
          <el-button round @click="resetQuery">
            <el-icon><Refresh /></el-icon> 重置
          </el-button>
        </el-form-item>
      </el-form>
    </div>

    <!-- 资源列表 -->
    <div class="resource-list">
      <el-row :gutter="20">
        <el-col :xs="24" :sm="12" :md="8" :lg="6" v-for="item in resourceList" :key="item.id">
          <div class="resource-card" @click="goToDetail(item.id)">
            <div class="resource-type" :class="getResourceClass(item.fileType)">
              <el-icon v-if="item.fileType.includes('doc')"><Document /></el-icon>
              <el-icon v-else-if="item.fileType.includes('pdf')"><Tickets /></el-icon>
              <el-icon v-else-if="item.fileType.includes('ppt')"><Reading /></el-icon>
              <el-icon v-else-if="item.fileType.includes('xls')"><Grid /></el-icon>
              <el-icon v-else-if="item.fileType.includes('jpg') || item.fileType.includes('png') || item.fileType.includes('gif')"><Picture /></el-icon>
              <el-icon v-else-if="item.fileType.includes('mp4') || item.fileType.includes('avi')"><VideoPlay /></el-icon>
              <el-icon v-else-if="item.fileType.includes('zip') || item.fileType.includes('rar')"><Files /></el-icon>
              <el-icon v-else><Files /></el-icon>
              
              <div class="file-type-label">{{ getFileTypeLabel(item.fileType) }}</div>
            </div>
            <div class="resource-info">
              <h3 class="resource-name">{{ item.resourceName }}</h3>
              <div class="resource-meta-info">
                <p class="resource-category">
                  <el-icon><FolderOpened /></el-icon>
                  <span>{{ item.categoryName }}</span>
                </p>
                <p class="resource-uploader">
                  <el-icon><User /></el-icon>
                  <span>{{ item.uploadUsername }}</span>
                </p>
                <p class="resource-time">
                  <el-icon><Calendar /></el-icon>
                  <span>{{ formatDate(item.createTime) }}</span>
                </p>
              </div>
              <div class="resource-stats">
                <span class="size">
                  <el-icon><Folder /></el-icon>
                  {{ formatFileSize(item.fileSize * 1024) }}
                </span>
                <span class="downloads">
                  <el-icon><Download /></el-icon>
                  {{ item.downloadCount }} 次下载
                </span>
              </div>
            </div>
          </div>
        </el-col>
      </el-row>
    </div>
    
    <!-- 空状态提示 -->
    <div class="empty-container" v-if="resourceList.length === 0">
      <el-empty description="暂无资源" :image-size="200">
        <template #description>
          <p>暂无符合条件的资源，可以尝试重置筛选条件</p>
        </template>
        <el-button type="primary" color="#8e44ad" round @click="resetQuery">
          <el-icon><Refresh /></el-icon> 重置筛选
        </el-button>
      </el-empty>
    </div>

    <!-- 分页 -->
    <div class="pagination-container" v-if="total > 0">
      <el-pagination
        v-model:current-page="queryParams.currentPage"
        v-model:page-size="queryParams.pageSize"
        :page-sizes="[12, 24, 36, 48]"
        :total="total"
        layout="total, sizes, prev, pager, next, jumper"
        @size-change="handleSizeChange"
        @current-change="handleCurrentChange"
        background
      />
    </div>

    <!-- 上传资源对话框 -->
    <el-dialog
      v-model="uploadDialogVisible"
      width="500px"
      :close-on-click-modal="false"
      @closed="handleDialogClosed"
      center
      destroy-on-close
    >
      <template #header>
        <div class="dialog-header">
          <el-icon class="dialog-icon"><Upload /></el-icon>
          <span>上传资源</span>
        </div>
      </template>
      <el-form
        ref="uploadFormRef"
        :model="uploadForm"
        :rules="uploadRules"
        label-width="80px"
      >
        <el-form-item label="资源名称" prop="resourceName">
          <el-input v-model="uploadForm.resourceName" placeholder="请输入资源名称" />
        </el-form-item>
        <el-form-item label="资源分类" prop="categoryId">
          <el-select v-model="uploadForm.categoryId" placeholder="请选择分类" style="width: 100%">
            <el-option
              v-for="item in categories"
              :key="item.id"
              :label="item.categoryName"
              :value="item.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="资源描述" prop="description">
          <el-input
            v-model="uploadForm.description"
            type="textarea"
            :rows="3"
            placeholder="请输入资源描述"
            maxlength="500"
            show-word-limit
          />
        </el-form-item>
        <el-form-item label="上传文件" prop="file">
          <el-upload
            class="file-uploader"
            action="#"
            :show-file-list="false"
            :auto-upload="false"
            :on-change="handleFileChange"
          >
            <div class="file-wrapper">
              <div v-if="selectedFile" class="file-preview">
                <el-icon class="file-icon" :size="40">
                  <Document v-if="selectedFile.type.includes('word') || selectedFile.type.includes('doc')" />
                  <Tickets v-else-if="selectedFile.type.includes('pdf')" />
                  <Picture v-else-if="selectedFile.type.includes('image')" />
                  <VideoPlay v-else-if="selectedFile.type.includes('video')" />
                  <Files v-else />
                </el-icon>
                <div class="file-info">
                  <div class="file-name">{{ selectedFile.name }}</div>
                  <div class="file-size">{{ formatFileSize(selectedFile.size) }}</div>
                </div>
              </div>
              <div v-else class="upload-placeholder">
                <el-icon class="upload-icon"><Upload /></el-icon>
                <div class="upload-text">点击上传文件</div>
              </div>
              <div class="file-hover-mask">
                <el-icon><Plus /></el-icon>
              </div>
            </div>
          </el-upload>
          <div class="upload-tip">支持各种类型的文件，单个文件不超过50MB</div>
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="uploadDialogVisible = false" round>取消</el-button>
          <el-button type="primary" color="#8e44ad" @click="submitUpload" :loading="uploading" round>
            确认上传
          </el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { useUserStore } from '@/store/user'
import {
  Document, Tickets, Picture, VideoPlay, Files,
  Search, Refresh, Upload, Download, UploadFilled, Delete, Plus,
  Collection, Calendar, User, Folder, FolderOpened, Reading, Grid
} from '@element-plus/icons-vue'
import request from '@/utils/request'

const router = useRouter()
const userStore = useUserStore()

// 查询参数
const queryParams = reactive({
  resourceName: '',
  categoryId: '',
  fileType: '',
  currentPage: 1,
  pageSize: 12
})

// 资源列表数据
const resourceList = ref([])
const total = ref(0)
const categories = ref([])

// 上传相关
const uploadDialogVisible = ref(false)
const uploading = ref(false)
const uploadFormRef = ref(null)
const uploadForm = reactive({
  resourceName: '',
  categoryId: '',
  description: '',
  filePath: '',
  fileSize: 0,
  fileType: ''
})

// 上传规则
const uploadRules = {
  resourceName: [
    { required: true, message: '请输入资源名称', trigger: 'blur' },
    { min: 2, max: 50, message: '长度在 2 到 50 个字符', trigger: 'blur' }
  ],
  categoryId: [
    { required: true, message: '请选择资源分类', trigger: 'change' }
  ]
}

// 获取资源类型的CSS类名
const getResourceClass = (fileType) => {
  if (!fileType) return 'type-other'
  
  if (fileType.includes('doc')) return 'type-doc'
  if (fileType.includes('pdf')) return 'type-pdf'
  if (fileType.includes('ppt')) return 'type-ppt'
  if (fileType.includes('xls')) return 'type-excel'
  if (fileType.includes('jpg') || fileType.includes('png') || fileType.includes('gif')) return 'type-image'
  if (fileType.includes('mp4') || fileType.includes('avi')) return 'type-video'
  if (fileType.includes('zip') || fileType.includes('rar')) return 'type-archive'
  
  return 'type-other'
}

// 获取文件类型标签
const getFileTypeLabel = (fileType) => {
  if (!fileType) return '未知'
  
  if (fileType.includes('doc')) return 'WORD'
  if (fileType.includes('pdf')) return 'PDF'
  if (fileType.includes('ppt')) return 'PPT'
  if (fileType.includes('xls')) return 'EXCEL'
  if (fileType.includes('jpg') || fileType.includes('png') || fileType.includes('gif')) return 'IMAGE'
  if (fileType.includes('mp4') || fileType.includes('avi')) return 'VIDEO'
  if (fileType.includes('zip') || fileType.includes('rar')) return 'ZIP'
  
  return fileType.toUpperCase()
}

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

// 文件上传相关
const selectedFile = ref(null)

// 获取资源列表
const getResourceList = async () => {
  const params = {
    ...queryParams,
    status: 1
  }
  try {
    const res = await request.get('/resource/page', params, {
      showDefaultMsg:false,
      onSuccess:(data)=>{
        // 确保资源列表数据正确
        resourceList.value = (data.records || []).map(item => ({
          ...item,
          // 添加完整下载链接
          downloadUrl: item.filePath && !item.filePath.startsWith('/api') ? 
            `/api${item.filePath}` : item.filePath
        }))
        total.value = data.total || 0
      }
    })
  } catch (error) {
    console.error('获取资源列表失败:', error)
  }
}

// 获取资源分类
const getCategories = async () => {
  try {
    const res = await request.get('/resource/category/valid',null,{
      showDefaultMsg:false,
      onSuccess:(data )=>{
        categories.value = data||[]
      }
    })
  } catch (error) {
    console.error('获取资源分类失败:', error)
  }
}

// 搜索
const handleSearch = () => {
  queryParams.currentPage = 1
  getResourceList()
}

// 重置查询
const resetQuery = () => {
  queryParams.resourceName = ''
  queryParams.categoryId = ''
  queryParams.fileType = ''
  queryParams.currentPage = 1
  getResourceList()
}

// 分页大小改变
const handleSizeChange = (val) => {
  queryParams.pageSize = val
  getResourceList()
}

// 页码改变
const handleCurrentChange = (val) => {
  queryParams.currentPage = val
  getResourceList()
}

// 跳转到详情页
const goToDetail = (id) => {
  router.push(`/resource/${id}`)
}

// 处理上传
const handleUpload = () => {
  if (!userStore.isLoggedIn) {
    ElMessage.warning('请先登录')
    return
  }
  uploadDialogVisible.value = true
}

// 处理文件选择变化
const handleFileChange = (file) => {
  // 文件大小检查
  const isLt50M = file.size / 1024 / 1024 < 50
  
  if (!isLt50M) {
    ElMessage.error('上传文件大小不能超过50MB!')
    return
  }
  
  selectedFile.value = file.raw
  
  // 获取文件扩展名
  const fileExt = file.name.substring(file.name.lastIndexOf('.') + 1).toLowerCase()
  
  // 设置资源文件名（如果用户还没有输入）
  if (!uploadForm.resourceName) {
    uploadForm.resourceName = file.name.substring(0, file.name.lastIndexOf('.'))
  }
}

// 上传文件
const uploadFile = async () => {
  if (!selectedFile.value) {
    ElMessage.warning('请先选择文件')
    return false
  }
  
  // 创建表单数据
  const formData = new FormData()
  formData.append('file', selectedFile.value)
  
  try {
    uploading.value = true
    
    // 通过promise方式处理
    return new Promise((resolve, reject) => {
      request.post('/file/upload', formData, {
        headers: {
          'Content-Type': 'multipart/form-data'
        },
        showDefaultMsg: false,
        onSuccess: (res) => {
          // 设置文件路径、大小和类型
          uploadForm.filePath = res
          uploadForm.fileSize = selectedFile.value.size / 1024  // 转换为KB
          uploadForm.fileType = selectedFile.value.name.substring(
            selectedFile.value.name.lastIndexOf('.') + 1
          )
          ElMessage.success('文件上传成功')
          resolve(true)
        },
        onError: (error) => {
          console.error('文件上传失败:', error)
          ElMessage.error('文件上传失败')
          reject(false)
        }
      })
    })
  } catch (error) {
    console.error('文件上传失败:', error)
    ElMessage.error('文件上传失败')
    return false
  } finally {
    uploading.value = false
  }
}

// 提交上传
const submitUpload = async () => {
  // 表单验证
  if (!uploadFormRef.value) return
  
  const valid = await uploadFormRef.value.validate().catch(() => false)
  if (!valid) {
    ElMessage.warning('请完善表单信息')
    return
  }
  
  if (!selectedFile.value && !uploadForm.filePath) {
    ElMessage.warning('请选择要上传的文件')
    return
  }
  
  if (!uploadForm.filePath) {
    // 如果还没有上传文件，先上传
    try {
      const uploadSuccess = await uploadFile()
      if (!uploadSuccess) return
    } catch (error) {
      return
    }
  }
  
  try {
    uploading.value = true
    await request.post('/resource/add', uploadForm, {
      successMsg: '资源上传成功',
      onSuccess: () => {
        uploadDialogVisible.value = false
        getResourceList()
        // 重置表单和文件
        handleDialogClosed()
      }
    })
  } catch (error) {
    console.error('资源上传失败:', error)
  } finally {
    uploading.value = false
  }
}

// 对话框关闭后的清理
const handleDialogClosed = () => {
  // 重置表单和文件选择
  if (uploadFormRef.value) {
    uploadFormRef.value.resetFields()
  }
  
  uploadForm.resourceName = ''
  uploadForm.categoryId = ''
  uploadForm.description = ''
  uploadForm.filePath = ''
  uploadForm.fileSize = 0
  uploadForm.fileType = ''
  
  selectedFile.value = null
}

onMounted(() => {
  getResourceList()
  getCategories()
})
</script>

<style lang="scss" scoped>
.resources {
  padding: 20px;
  max-width: 1200px;
  margin: 0 auto;

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
    
    @media (max-width: 768px) {
      flex-direction: column;
      gap: 20px;
      
      .header-actions {
        align-self: flex-end;
      }
    }
  }

  .filter-section {
    background-color: #fff;
    padding: 25px;
    border-radius: 16px;
    margin-bottom: 30px;
    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);

    .filter-form {
      display: flex;
      flex-wrap: wrap;
      gap: 15px;
      
      @media (max-width: 768px) {
        flex-direction: column;
        
        .el-form-item {
          margin-right: 0 !important;
        }
      }
    }
  }

  .resource-list {
    margin-bottom: 30px;
    
    .el-row {
      margin: -10px;
    }
    
    .el-col {
      padding: 10px;
      height: auto;
      display: flex;
    }

    .resource-card {
      background-color: #fff;
      border-radius: 16px;
      margin-bottom: 0;
      cursor: pointer;
      transition: all 0.3s;
      border: none;
      overflow: hidden;
      box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
      display: flex;
      flex-direction: column;
      width: 100%;
      height: 100%;
      position: relative;

      &:hover {
        transform: translateY(-8px);
        box-shadow: 0 15px 35px rgba(0, 0, 0, 0.15);
      }

      .resource-type {
        padding: 30px 20px;
        color: white;
        font-size: 40px;
        text-align: center;
        position: relative;
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        min-height: 120px;
        
        &.type-doc {
          background: linear-gradient(135deg, #4285f4, #34a8eb);
        }
        
        &.type-pdf {
          background: linear-gradient(135deg, #FF5252, #FF8A80);
        }
        
        &.type-ppt {
          background: linear-gradient(135deg, #FF7043, #FFB74D);
        }
        
        &.type-excel {
          background: linear-gradient(135deg, #43A047, #81C784);
        }
        
        &.type-image {
          background: linear-gradient(135deg, #8e44ad, #9C27B0);
        }
        
        &.type-video {
          background: linear-gradient(135deg, #E91E63, #F48FB1);
        }
        
        &.type-archive {
          background: linear-gradient(135deg, #795548, #A1887F);
        }
        
        &.type-other {
          background: linear-gradient(135deg, #607D8B, #90A4AE);
        }
        
        .file-type-label {
          position: absolute;
          bottom: 8px;
          right: 8px;
          background-color: rgba(255, 255, 255, 0.2);
          color: white;
          font-size: 10px;
          padding: 3px 6px;
          border-radius: 4px;
          font-weight: bold;
        }
      }

      .resource-info {
        flex: 1;
        display: flex;
        flex-direction: column;
        padding: 15px;
        background-color: white;

        .resource-name {
          margin: 0 0 12px 0;
          font-size: 16px;
          font-weight: 600;
          color: #333;
          overflow: hidden;
          text-overflow: ellipsis;
          display: -webkit-box;
          -webkit-line-clamp: 2;
          -webkit-box-orient: vertical;
          line-height: 1.4;
          min-height: 40px;
          word-break: break-word;
        }
        
        .resource-meta-info {
          flex: 1;
          
          p {
            margin: 8px 0;
            color: #606266;
            font-size: 13px;
            display: flex;
            align-items: center;
            gap: 6px;
            
            .el-icon {
              color: #8e44ad;
              font-size: 14px;
            }
          }
        }

        .resource-stats {
          display: flex;
          justify-content: space-between;
          align-items: center;
          margin-top: 10px;
          color: #606266;
          font-size: 13px;
          padding-top: 10px;
          border-top: 1px solid #f0f0f0;

          .size, .downloads {
            display: flex;
            align-items: center;
            gap: 6px;
            
            .el-icon {
              color: #8e44ad;
              font-size: 14px;
            }
          }
        }
      }
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
    display: flex;
    justify-content: center;
    margin-top: 30px;
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

.dialog-footer {
  display: flex;
  justify-content: center;
  gap: 15px;
}

// 文件上传组件样式
.file-uploader {
  .file-wrapper {
    width: 100%;
    height: 120px;
    border: 1px dashed #d9d9d9;
    border-radius: 12px;
    cursor: pointer;
    position: relative;
    overflow: hidden;
    transition: all 0.3s;
    display: flex;
    justify-content: center;
    align-items: center;
    
    &:hover {
      border-color: #8e44ad;
      
      .file-hover-mask {
        opacity: 1;
      }
    }
    
    .upload-placeholder {
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      
      .upload-icon {
        font-size: 28px;
        color: #8c939d;
        margin-bottom: 8px;
      }
      
      .upload-text {
        color: #606266;
        font-size: 14px;
      }
    }
    
    .file-preview {
      display: flex;
      align-items: center;
      width: 90%;
      
      .file-icon {
        color: #8e44ad;
        margin-right: 15px;
        font-size: 40px;
      }
      
      .file-info {
        flex: 1;
        overflow: hidden;
        
        .file-name {
          font-size: 14px;
          color: #303133;
          margin-bottom: 5px;
          white-space: nowrap;
          overflow: hidden;
          text-overflow: ellipsis;
        }
        
        .file-size {
          font-size: 12px;
          color: #909399;
        }
      }
    }
    
    .file-hover-mask {
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      background: rgba(142, 68, 173, 0.5);
      display: flex;
      justify-content: center;
      align-items: center;
      opacity: 0;
      transition: opacity 0.3s;
      
      .el-icon {
        font-size: 24px;
        color: #fff;
      }
    }
  }
}

.upload-tip {
  margin-top: 8px;
  color: #909399;
  font-size: 12px;
}
</style>