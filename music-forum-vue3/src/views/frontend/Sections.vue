<template>
  <div class="sections">
    <!-- 页面标题和操作区 -->
    <div class="page-header">
      <div class="header-title">
        <el-icon><Grid /></el-icon>
        <h1>论坛板块</h1>
      </div>
      <div class="header-actions">
        <el-radio-group v-model="viewMode" size="large">
          <el-radio-button label="all">全部板块</el-radio-button>
          <el-radio-button label="managed" v-if="userStore.isLoggedIn">我管理的</el-radio-button>
        </el-radio-group>
      </div>
    </div>

    <!-- 板块列表 -->
    <div class="section-list">
      <el-row :gutter="20">
        <el-col :xs="24" :sm="12" :md="8" :lg="6" v-for="section in sectionList" :key="section.id">
          <div class="section-card" :class="{'disabled': section.status === 0}">
            <div class="card-bg" :style="{ backgroundImage: `linear-gradient(135deg, ${getSectionColor(section.id)} 0%, ${getLighterColor(getSectionColor(section.id))} 100%)` }"></div>
            <div class="section-header">
              <div class="section-icon">
                <el-icon :size="30"><component :is="getIconComponent(section.id)" /></el-icon>
              </div>
              <el-tag 
                :type="section.status === 1 ? 'success' : 'danger'"
                class="status-tag"
                size="small"
                effect="dark"
              >
                {{ section.status === 1 ? '正常' : '已禁用' }}
              </el-tag>
            </div>
            <div class="section-info">
              <h3 class="section-name">{{ section.sectionName }}</h3>
              <p class="section-description">{{ section.description || '暂无描述' }}</p>
              <div class="section-meta">
                <div class="meta-item">
                  <el-icon><Document /></el-icon>
                  <span>帖子：{{ section.postCount || 0 }}</span>
                </div>
                <div class="meta-item">
                  <el-icon><Timer /></el-icon>
                  <span>今日：+{{ section.todayPosts || 0 }}</span>
                </div>
                <div class="meta-item">
                  <el-icon><Calendar /></el-icon>
                  <span>{{ formatDate(section.createTime) }}</span>
                </div>
              </div>
              <div class="section-actions">
                <el-button type="primary" color="#8e44ad" round @click="goToSection(section.id)">
                  <el-icon><View /></el-icon>查看
                </el-button>
                <template v-if="viewMode === 'managed'">
                  <el-button type="warning" round @click="handleEdit(section)">
                    <el-icon><Edit /></el-icon>编辑
                  </el-button>
                  <el-tooltip
                    :content="section.status === 1 ? '点击禁用板块' : '点击启用板块'"
                    placement="top"
                  >
                    <el-switch
                      v-model="section.status"
                      :active-value="1"
                      :inactive-value="0"
                      :loading="section.statusLoading"
                      @change="(val) => handleStatusChange(section, val)"
                      inline-prompt
                      :active-text="'启用'"
                      :inactive-text="'禁用'"
                      style="margin-left: 10px"
                    />
                  </el-tooltip>
                </template>
              </div>
            </div>
          </div>
        </el-col>
      </el-row>
    </div>

    <!-- 空状态提示 -->
    <div class="empty-container" v-if="sectionList.length === 0">
      <el-empty description="暂无板块" :image-size="200">
        <template #description>
          <p>{{ viewMode === 'managed' ? '您没有管理的板块' : '暂无可用板块' }}</p>
        </template>
      </el-empty>
    </div>

    <!-- 分页器 -->
    <div class="pagination-container" v-if="total > pageSize">
      <el-pagination
        v-model:current-page="currentPage"
        v-model:page-size="pageSize"
        :page-sizes="[12, 24, 36, 48]"
        :total="total"
        layout="total, sizes, prev, pager, next, jumper"
        @size-change="handleSizeChange"
        @current-change="handleCurrentChange"
        background
      />
    </div>

    <!-- 编辑对话框 -->
    <el-dialog
      v-model="editDialogVisible"
      width="500px"
      :close-on-click-modal="false"
      center
      destroy-on-close
    >
      <template #header>
        <div class="dialog-header">
          <el-icon class="dialog-icon"><Edit /></el-icon>
          <span>{{ editForm.id ? '编辑板块' : '新增板块' }}</span>
        </div>
      </template>
      <el-form
        ref="editFormRef"
        :model="editForm"
        :rules="editRules"
        label-width="100px"
      >
        <el-form-item label="板块名称" prop="sectionName">
          <el-input v-model="editForm.sectionName" placeholder="请输入板块名称" />
        </el-form-item>
        <el-form-item label="板块描述" prop="description">
          <el-input
            v-model="editForm.description"
            type="textarea"
            :rows="4"
            placeholder="请输入板块描述"
            maxlength="500"
            show-word-limit
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="editDialogVisible = false" round>取消</el-button>
          <el-button type="primary" color="#8e44ad" @click="submitEdit" :loading="submitting" round>
            确定
          </el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted, reactive, watch } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { 
  ChatDotRound, View, Edit, Calendar, Document, 
  Timer, Grid, Reading, Collection, Sunny, 
  Monitor, School 
} from '@element-plus/icons-vue'
import { useUserStore } from '@/store/user'
import request from '@/utils/request'

const router = useRouter()
const userStore = useUserStore()

// 视图模式
const viewMode = ref('all')

// 分页参数
const currentPage = ref(1)
const pageSize = ref(12)
const total = ref(0)

// 板块列表数据
const sectionList = ref([])

// 编辑相关
const editDialogVisible = ref(false)
const editFormRef = ref(null)
const editForm = reactive({
  id: '',
  sectionName: '',
  description: ''
})
const editRules = {
  sectionName: [
    { required: true, message: '请输入板块名称', trigger: 'blur' },
    { min: 2, max: 100, message: '长度在 2 到 100 个字符', trigger: 'blur' }
  ],
  description: [
    { max: 500, message: '长度不能超过 500 个字符', trigger: 'blur' }
  ]
}
const submitting = ref(false)

// 获取板块列表
const getSectionList = async () => {
  try {
    if (viewMode.value === 'managed') {
      // 获取我管理的板块
      await request.get(`/moderator/user/${userStore.userInfo.id}`, {}, {
        showDefaultMsg: false,
        onSuccess: async (data) => {
          const moderatorData = data || []
          const sectionIds = moderatorData.map(m => m.sectionId)
          if (sectionIds.length > 0) {
            // 获取这些板块的详细信息
            await request.get('/section/all', { status: -1 }, {
              showDefaultMsg: false,
              onSuccess: async (sectionsData) => {
                const allSections = Array.isArray(sectionsData) ? sectionsData : []
                sectionList.value = allSections.filter(s => sectionIds.includes(s.id))
                
                // 获取每个板块的帖子统计信息
                for (const section of sectionList.value) {
                  await request.get(`/post/section/stats/${section.id}`, null, {
                    showDefaultMsg: false,
                    onSuccess: (stats) => {
                      section.postCount = stats.totalPosts || 0
                      section.todayPosts = stats.todayPosts || 0
                    }
                  })
                }
                
                total.value = sectionList.value.length
              }
            })
          } else {
            sectionList.value = []
            total.value = 0
          }
        }
      })
    } else {
      // 获取所有板块，包括禁用的
      await request.get('/section/page', {
        currentPage: currentPage.value,
        size: pageSize.value,
        status: 1 
      }, {
        showDefaultMsg: false,
        onSuccess: async (data) => {
          sectionList.value = data.records || []
          
          // 获取每个板块的帖子统计信息
          for (const section of sectionList.value) {
            await request.get(`/post/section/stats/${section.id}`, null, {
              showDefaultMsg: false,
              onSuccess: (stats) => {
                section.postCount = stats.totalPosts || 0
                section.todayPosts = stats.todayPosts || 0
              }
            })
          }
          
          total.value = data.total || 0
        }
      })
    }
    
    // 为每个板块添加状态加载标志
    sectionList.value.forEach(section => {
      section.statusLoading = false
    })
  } catch (error) {
    console.error('获取板块列表失败:', error)
    ElMessage.error('获取板块列表失败')
  }
}

// 格式化日期
const formatDate = (date) => {
  if (!date) return ''
  return new Date(date).toLocaleString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit'
  })
}

// 获取板块颜色
const getSectionColor = (id) => {
  const colors = {
    1: '#409EFF', // 学术交流
    2: '#67C23A', // 教学资源
    3: '#E6A23C', // 课外活动
    4: '#F56C6C', // 技术交流
    5: '#9254DE'  // 校园生活
  }
  return colors[id] || '#8e44ad'
}

// 获取更亮的颜色（用于渐变）
const getLighterColor = (color) => {
  if (color === '#409EFF') return '#6abeff' 
  if (color === '#67C23A') return '#95e373'
  if (color === '#E6A23C') return '#ffc773'
  if (color === '#F56C6C') return '#ff9e9e'
  if (color === '#9254DE') return '#c596ff'
  if (color === '#8e44ad') return '#b66ad1'
  return '#c0c4cc'
}

// 获取图标组件
const getIconComponent = (id) => {
  const icons = {
    1: 'Reading',      // 学术交流
    2: 'Collection',   // 教学资源
    3: 'Sunny',        // 课外活动
    4: 'Monitor',      // 技术交流
    5: 'School'        // 校园生活
  }
  return icons[id] || 'Grid'
}

// 跳转到板块详情页
const goToSection = (id) => {
  router.push(`/forum/section/${id}`)
}

// 处理编辑
const handleEdit = (section) => {
  editForm.id = section.id
  editForm.sectionName = section.sectionName
  editForm.description = section.description
  editDialogVisible.value = true
}

// 提交编辑
const submitEdit = async () => {
  if (!editFormRef.value) return
  
  await editFormRef.value.validate(async (valid) => {
    if (!valid) return
    
    submitting.value = true
    try {
      await request.put(`/section/${editForm.id}`, editForm, {
        successMsg: '板块信息更新成功',
        onSuccess: () => {
          editDialogVisible.value = false
          getSectionList() // 重新获取列表
        }
      })
    } catch (error) {
      console.error('更新板块信息失败:', error)
    } finally {
      submitting.value = false
    }
  })
}

// 处理状态变更
const handleStatusChange = async (section, status) => {
  section.statusLoading = true
  try {
    await request.put(`/section/${section.id}/status?status=${status}`, null, {
      successMsg: `板块已${status === 1 ? '启用' : '禁用'}`,
      onSuccess: () => {
        section.status = status
      },
      onError: () => {
        section.status = status === 1 ? 0 : 1
      }
    })
  } catch (error) {
    console.error('更新板块状态失败:', error)
  } finally {
    section.statusLoading = false
  }
}

// 分页大小改变
const handleSizeChange = (val) => {
  pageSize.value = val
  getSectionList()
}

// 当前页改变
const handleCurrentChange = (val) => {
  currentPage.value = val
  getSectionList()
}

// 监听视图模式变化
watch(viewMode, () => {
  currentPage.value = 1
  getSectionList()
})

// 初始化
onMounted(() => {
  getSectionList()
})
</script>

<style lang="scss" scoped>
.sections {
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
      align-items: flex-start;
      
      .header-actions {
        align-self: center;
      }
    }
  }

  .section-list {
    margin-bottom: 30px;

    .section-card {
      position: relative;
      background-color: #fff;
      padding: 0;
      border-radius: 16px;
      margin-bottom: 20px;
      transition: all 0.3s;
      border: none;
      overflow: hidden;
      box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
      min-height: 100%;
      display: flex;
      flex-direction: column;

      &:hover {
        transform: translateY(-8px);
        box-shadow: 0 15px 35px rgba(0, 0, 0, 0.15);
      }
      
      &.disabled {
        opacity: 0.7;
        
        .section-info {
          background-color: rgba(245, 245, 245, 0.9);
        }
      }
      
      .card-bg {
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 110px;
        z-index: 0;
      }

      .section-header {
        position: relative;
        display: flex;
        justify-content: space-between;
        align-items: flex-start;
        padding: 20px;
        z-index: 1;

        .section-icon {
          width: 60px;
          height: 60px;
          display: flex;
          align-items: center;
          justify-content: center;
          color: #fff;
          border-radius: 16px;
          background-color: rgba(255, 255, 255, 0.2);
          box-shadow: 0 8px 16px rgba(0, 0, 0, 0.2);
        }
        
        .status-tag {
          margin-top: 5px;
        }
      }

      .section-info {
        position: relative;
        flex: 1;
        display: flex;
        flex-direction: column;
        z-index: 1;
        background-color: rgba(255, 255, 255, 0.95);
        margin-top: 20px;
        padding: 20px;
        border-radius: 20px 20px 0 0;
        box-shadow: 0 -10px 20px rgba(0, 0, 0, 0.05);

        .section-name {
          margin: 0 0 15px 0;
          font-size: 20px;
          font-weight: 700;
          color: #333;
          word-break: break-word;
        }

        .section-description {
          flex: 1;
          margin: 0 0 15px 0;
          color: #606266;
          font-size: 14px;
          line-height: 1.6;
          overflow: hidden;
          text-overflow: ellipsis;
          display: -webkit-box;
          -webkit-line-clamp: 3;
          -webkit-box-orient: vertical;
          min-height: 60px;
        }

        .section-meta {
          display: flex;
          flex-wrap: wrap;
          gap: 15px;
          margin-bottom: 20px;
          
          .meta-item {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 14px;
            color: #606266;
            
            .el-icon {
              color: #8e44ad;
              font-size: 16px;
            }
          }
        }

        .section-actions {
          display: flex;
          align-items: center;
          gap: 10px;
          margin-top: auto;
          flex-wrap: wrap;
        }
      }
    }
    
    .el-col {
      margin-bottom: 20px;
      height: auto;
      display: flex;
      
      @media (max-width: 768px) {
        margin-bottom: 15px;
      }
    }
  }

  .empty-container {
    padding: 40px 0;
    text-align: center;
    
    p {
      color: #909399;
      margin-bottom: 20px;
    }
  }

  .pagination-container {
    display: flex;
    justify-content: center;
    margin-top: 30px;
  }
}

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
</style> 