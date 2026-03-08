<template>
  <div class="section-detail">
    <!-- 板块信息卡片 -->
    <el-card class="section-info-card" v-loading="sectionLoading" :body-style="{padding: '0'}">
      <div class="card-bg" :style="{ backgroundImage: `linear-gradient(135deg, ${sectionColor} 0%, ${getLighterColor(sectionColor)} 100%)` }"></div>
      <div class="section-header">
        <div class="section-basic">
          <div class="section-icon" :style="{ backgroundColor: sectionColor }">
            <el-icon :size="30"><component :is="getIconComponent(section.id)" /></el-icon>
          </div>
          <div class="section-text">
            <h1 class="section-name">{{ section.sectionName }}</h1>
            <p class="section-desc">{{ section.description }}</p>
            <div class="section-meta">
              <div class="meta-item">
                <el-icon><Document /></el-icon>
                帖子数：<span class="meta-value">{{ postCount }}</span>
              </div>
              <div class="meta-item">
                <el-icon><Timer /></el-icon>
                今日：<span class="meta-value">+{{ todayPosts }}</span>
              </div>
              <div class="meta-item">
                <el-icon><Calendar /></el-icon>
                创建于：<span class="meta-value">{{ formatDate(section.createTime) }}</span>
              </div>
            </div>
          </div>
        </div>
        <div class="section-actions">
          <el-button type="primary" color="#8e44ad" round @click="handleCreatePost">
            <el-icon><Plus /></el-icon>发表帖子
          </el-button>
          <el-button v-if="isModerator" type="warning" round @click="handleEditSection">
            <el-icon><Edit /></el-icon>编辑板块
          </el-button>
          <el-tooltip
            v-if="isModerator"
            :content="section.status === 1 ? '点击禁用板块' : '点击启用板块'"
            placement="top"
          >
            <el-switch
              v-model="section.status"
              :active-value="1"
              :inactive-value="0"
              :loading="statusLoading"
              @change="handleStatusChange"
              style="margin-left: 10px;"
              inline-prompt
              :active-text="'启用'"
              :inactive-text="'禁用'"
            />
          </el-tooltip>
        </div>
      </div>

      <!-- 版主信息 -->
      <div class="moderator-list" v-if="moderators.length > 0">
        <h4 class="moderator-title">
          <el-icon><User /></el-icon> 版主团队
        </h4>
        <div class="moderator-items">
          <div
            v-for="moderator in moderators"
            :key="moderator.id"
            class="moderator-item"
            @click="showModeratorDetail(moderator)"
          >
            <el-avatar :size="40" :src="'/api' + moderator.user?.avatar">
              {{ moderator.user?.username?.charAt(0) }}
            </el-avatar>
            <div class="moderator-info">
              <span class="moderator-name">{{ moderator.user?.username }}</span>
              <el-tag size="small" effect="dark" type="success">版主</el-tag>
            </div>
          </div>
        </div>
      </div>
    </el-card>

    <!-- 帖子列表 -->
    <div class="post-list-section">
      <el-card class="post-filter-card" :body-style="{padding: '20px'}">
        <div class="filter-options">
          <div class="filter-tabs">
            <div
              v-for="tab in [
                { label: '全部', value: 'all' },
                { label: '精华', value: 'essence' },
                { label: '最新', value: 'newest' },
                { label: '热门', value: 'hottest' }
              ]"
              :key="tab.value"
              :class="['filter-tab', { active: filterType === tab.value }]"
              @click="filterType = tab.value; handleFilterChange()"
            >
              <div class="tab-icon" v-if="tab.value === 'all'"><el-icon><Menu /></el-icon></div>
              <div class="tab-icon" v-else-if="tab.value === 'essence'"><el-icon><Star /></el-icon></div>
              <div class="tab-icon" v-else-if="tab.value === 'newest'"><el-icon><Timer /></el-icon></div>
              <div class="tab-icon" v-else-if="tab.value === 'hottest'"><el-icon><FireFilled /></el-icon></div>
              {{ tab.label }}
            </div>
          </div>

          <div class="search-container">
            <el-input
              v-model="searchKeyword"
              placeholder="搜索帖子"
              clearable
              @keyup.enter="handleSearch"
              class="search-input"
            >
              <template #prefix>
                <el-icon><Search /></el-icon>
              </template>
            </el-input>
            <el-button type="primary" round @click="handleSearch">搜索</el-button>
          </div>
        </div>
      </el-card>
      
      <el-card class="post-list-card" v-loading="postsLoading">
        <template v-if="posts.length > 0">
          <transition-group name="post-list" tag="div" class="posts-container">
            <div v-for="post in posts" :key="post.id" class="post-item" :class="{'deleting': post.isDeleting}">
              <div class="post-author">
                <el-avatar :size="50" :src="'/api' + post.user?.avatar">
                  {{ post.username?.charAt(0) }}
                </el-avatar>
                <div class="author-info">
                  <div class="author-name">{{ post.username }}</div>
                  <div class="post-time">{{ formatDate(post.createTime) }}</div>
                </div>
              </div>
              <div class="post-content">
                <router-link :to="`/forum/post/${post.id}`" class="post-title">
                  <el-tag v-if="post.isEssence" type="success" effect="dark" size="small" class="essence-tag">精华</el-tag>
                  {{ post.title }}
                </router-link>
                <div class="post-summary">{{ truncateContent(post.content) }}</div>
                <div class="post-footer">
                  <div class="post-stats">
                    <span class="post-views">
                      <el-icon><View /></el-icon>
                      {{ post.viewCount }}
                    </span>
                    <span class="post-comments">
                      <el-icon><ChatDotRound /></el-icon>
                      {{ post.commentCount || 0 }}
                    </span>
                  </div>
                  <div class="post-actions">
                    <span 
                      v-if="post.userId === userStore.userId" 
                      class="post-delete" 
                      @click.stop="handleDeletePost(post)"
                    >
                      <el-icon><Delete /></el-icon>
                      <span v-if="post.isDeleting">删除中...</span>
                      <span v-else>删除</span>
                    </span>
                    <span class="post-report" @click="handleReportPost(post)">
                      <el-icon><Warning /></el-icon>
                      举报
                    </span>
                  </div>
                </div>
              </div>
            </div>
          </transition-group>
        </template>
        <template v-else>
          <div class="empty-container">
            <el-empty description="暂无帖子" :image-size="200">
              <template #description>
                <p>还没有任何帖子，快来发表第一篇吧！</p>
              </template>
              <el-button type="primary" round @click="handleCreatePost">
                <el-icon><Plus /></el-icon>发表帖子
              </el-button>
            </el-empty>
          </div>
        </template>
        
        <!-- 分页器 -->
        <div class="pagination-container" v-if="total > 0">
          <el-pagination
            :current-page="currentPage"
            :page-size="pageSize"
            @update:current-page="handleCurrentChange"
            @update:page-size="handleSizeChange"
            :page-sizes="[10, 20, 50, 100]"
            :background="true"
            layout="total, sizes, prev, pager, next, jumper"
            :total="total"
          />
        </div>
      </el-card>
    </div>

    <!-- 举报对话框 -->
    <el-dialog
      v-model="reportDialogVisible"
      title="举报帖子"
      width="500px"
      :show-close="true"
      :close-on-click-modal="false"
      destroy-on-close
      center
    >
      <template #header>
        <div class="dialog-header">
          <el-icon class="dialog-icon"><Warning /></el-icon>
          <span>举报帖子</span>
        </div>
      </template>
      <el-form :model="reportForm" label-width="100px" ref="reportFormRef" :rules="reportRules">
        <el-form-item label="举报类型">
          <el-radio-group v-model="reportForm.type">
            <el-radio :label="1">帖子</el-radio>
            <el-radio :label="2">评论</el-radio>
            <el-radio :label="3">资源</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="举报对象">
          <div class="report-target">{{ reportForm.targetContent }}</div>
        </el-form-item>
        <el-form-item label="举报原因" prop="reason">
          <el-input
            v-model="reportForm.reason"
            type="textarea"
            :rows="4"
            placeholder="请详细描述举报原因..."
            maxlength="500"
            show-word-limit
          ></el-input>
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="reportDialogVisible = false" round>取消</el-button>
          <el-button type="primary" @click="submitReport" :loading="reportSubmitting" round>
            提交举报
          </el-button>
        </span>
      </template>
    </el-dialog>

    <!-- 编辑板块对话框 -->
    <el-dialog
      v-model="editDialogVisible"
      width="500px"
      :close-on-click-modal="false"
      destroy-on-close
      center
    >
      <template #header>
        <div class="dialog-header">
          <el-icon class="dialog-icon"><Edit /></el-icon>
          <span>编辑板块信息</span>
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
        <span class="dialog-footer">
          <el-button @click="editDialogVisible = false" round>取消</el-button>
          <el-button type="primary" @click="submitEdit" :loading="submitting" round>
            保存修改
          </el-button>
        </span>
      </template>
    </el-dialog>

    <!-- 版主详情对话框 -->
    <el-dialog
      v-model="moderatorDetailVisible"
      width="500px"
      destroy-on-close
      center
    >
      <template #header>
        <div class="dialog-header">
          <el-icon class="dialog-icon"><User /></el-icon>
          <span>{{ currentModerator?.user?.username }} 的详细信息</span>
        </div>
      </template>
      <div class="moderator-detail" v-if="currentModerator">
        <div class="detail-header">
          <el-avatar :size="80" :src="'/api'+currentModerator.user?.avatar">
            {{ currentModerator.user?.username?.charAt(0) }}
          </el-avatar>
          <div class="user-basic">
            <h3>{{ currentModerator.user?.username }}</h3>
            <p class="real-name" v-if="currentModerator.user?.realName">
              <el-tag type="info" effect="plain" size="small">{{ currentModerator.user?.realName }}</el-tag>
            </p>
            <p class="role-tag">
              <el-tag type="warning" effect="dark">
                {{ getRoleLabel(currentModerator.user?.role) }}
              </el-tag>
            </p>
          </div>
        </div>

        <div class="user-info-cards">
          <div class="info-card">
            <div class="info-icon"><el-icon><Calendar /></el-icon></div>
            <div class="info-content">
              <div class="info-label">任命时间</div>
              <div class="info-value">{{ formatDate(currentModerator.appointTime) }}</div>
            </div>
          </div>
          
          <div class="info-card">
            <div class="info-icon"><el-icon><User /></el-icon></div>
            <div class="info-content">
              <div class="info-label">任命人</div>
              <div class="info-value">{{ currentModerator.appointByName }}</div>
            </div>
          </div>
          
          <div class="info-card" v-if="currentModerator.user?.email">
            <div class="info-icon"><el-icon><Message /></el-icon></div>
            <div class="info-content">
              <div class="info-label">联系邮箱</div>
              <div class="info-value">{{ currentModerator.user.email }}</div>
            </div>
          </div>
          
          <div class="info-card" v-if="currentModerator.user?.phone">
            <div class="info-icon"><el-icon><Phone /></el-icon></div>
            <div class="info-content">
              <div class="info-label">联系电话</div>
              <div class="info-value">{{ currentModerator.user.phone }}</div>
            </div>
          </div>
        </div>
        
        <div class="user-description" v-if="currentModerator.user?.signature">
          <div class="description-title">
            <el-icon><ChatDotRound /></el-icon> 个性签名
          </div>
          <div class="description-content">{{ currentModerator.user.signature }}</div>
        </div>
        
        <div class="user-description" v-if="currentModerator.user?.profile">
          <div class="description-title">
            <el-icon><Document /></el-icon> 个人简介
          </div>
          <div class="description-content">{{ currentModerator.user.profile }}</div>
        </div>
        
        <div class="user-description" v-if="currentModerator.remark">
          <div class="description-title">
            <el-icon><InfoFilled /></el-icon> 备注说明
          </div>
          <div class="description-content">{{ currentModerator.remark }}</div>
        </div>
      </div>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted, computed, reactive } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { 
  Plus, View, ChatDotRound, Search, Warning,
  ArrowUp, ArrowDown, Share, Star, Delete, Edit,
  Document, Calendar, Timer, User, Menu, Reading,
  Collection, Sunny, Monitor, School, Grid, FireFilled,
  Message, Phone, InfoFilled, ChatSquare
} from '@element-plus/icons-vue'
import request from '@/utils/request'
import { formatDate as formatDateUtil } from '@/utils/format'
import { useUserStore } from '@/store/user'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()

// 获取版块ID
const sectionId = computed(() => Number(route.params.id))

// 版块信息
const section = ref({})
const sectionLoading = ref(false)
const sectionColor = ref('#409EFF')
const sectionIcon = ref('el-icon-s-grid')
const postCount = ref(0)
const todayPosts = ref(0)
const moderators = ref([])

// 帖子列表
const posts = ref([])
const postsLoading = ref(false)
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)
const filterType = ref('all')
const searchKeyword = ref('')

// 举报相关
const reportDialogVisible = ref(false)
const reportForm = ref({
  type: 1, // 默认为帖子
  targetId: null,
  targetContent: '',
  reason: ''
})
const reportFormRef = ref(null)
const reportRules = {
  reason: [
    { required: true, message: '请填写举报原因', trigger: 'blur' },
    { min: 5, max: 500, message: '举报原因长度应为5-500个字符', trigger: 'blur' }
  ]
}
const reportSubmitting = ref(false)

// 编辑相关
const editDialogVisible = ref(false)
const editFormRef = ref(null)
const editForm = reactive({
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

// 判断当前用户是否是版主
const isModerator = computed(() => {
  if (!userStore.isLoggedIn) return false
  console.log("LoginUserId:",userStore.userInfo)
  console.log("Moderators:",moderators.value)
  return moderators.value.some(m => m.userId === userStore.userInfo.id)
})

// 格式化日期
const formatDate = (date) => {
  if (!date) return '-'
  return formatDateUtil(date)
}

// 截断内容
const truncateContent = (content) => {
  if (!content) return ''
  // 移除HTML标签
  const plainText = content.replace(/<[^>]+>/g, '')
  // 移除特殊字符和多余空格
  const cleanText = plainText
    .replace(/&[^;]+;/g, '') // 移除HTML实体
    .replace(/\s+/g, ' ') // 将多个空格合并为一个
    .trim()
  return cleanText.length > 150 ? cleanText.substring(0, 150) + '...' : cleanText
}

// 获取版块详情
const fetchSectionDetail = async () => {
  sectionLoading.value = true
  try {
    await request.get(`/section/${sectionId.value}`, null, {
      showDefaultMsg: false,
      onSuccess: (data) => {
        section.value = data
        // 根据版块ID设置颜色和图标
        sectionColor.value = getSectionColor(sectionId.value)
        sectionIcon.value = getSectionIcon(sectionId.value)
      }
    })
    
    // 获取版主列表
    await request.get(`/moderator/section/${sectionId.value}`, null, {
      showDefaultMsg: false,
      onSuccess: async (data) => {
        moderators.value = data || []
      }
    })

    // 获取帖子统计信息
    await request.get(`/post/section/stats/${sectionId.value}`, null, {
      showDefaultMsg: false,
      onSuccess: (data) => {
        postCount.value = data.totalPosts || 0
        todayPosts.value = data.todayPosts || 0
      }
    })
  } catch (error) {
    console.error('获取版块详情失败:', error)
  } finally {
    sectionLoading.value = false
  }
}

// 获取帖子列表
const fetchPosts = async () => {
  postsLoading.value = true
  try {
    // 构建查询参数
    const params = {
      sectionId: sectionId.value,
      status: 1,
      currentPage: currentPage.value,
      size: pageSize.value
    }
    
    // 根据筛选类型添加参数
    if (filterType.value === 'essence') {
      params.isEssence = 1
    }
    
    // 添加搜索关键词
    if (searchKeyword.value) {
      params.title = searchKeyword.value
    }
    
    // 根据筛选类型设置排序
    let url = '/post/page'
    if (filterType.value === 'newest') {
      // 按创建时间降序，通常默认就是这样
    } else if (filterType.value === 'hottest') {
      // 按浏览量排序
      url = '/post/hot'
    }
    
    await request.get(url, params, {
      showDefaultMsg: false,
      onSuccess: (data) => {
        posts.value = (data.records || []).map(post => ({
          ...post,
          id: post.id || post.post_id,
          userId: post.userId || post.user_id,
          isEssence: post.isEssence === 1 || post.is_essence === 1
        }))
        total.value = data.total || 0
        
      }
    })
  } catch (error) {
    console.error('获取帖子列表失败:', error)
  } finally {
    postsLoading.value = false
  }
}

// 发布帖子
const handleCreatePost = () => {
  if (!userStore.isLoggedIn) {
    ElMessage.warning('请先登录')
    router.push('/login')
    return
  }
  
  // 跳转到发帖页面而不是显示对话框
  router.push({
    path: '/forum/create-post',
    query: {
      sectionId: sectionId.value,
      sectionName: section.value.sectionName
    }
  })
}

// 过滤器变化
const handleFilterChange = () => {
  currentPage.value = 1
  fetchPosts()
}

// 搜索
const handleSearch = () => {
  currentPage.value = 1
  fetchPosts()
}

// 页码变化
const handleCurrentChange = (val) => {
  currentPage.value = val
  fetchPosts()
}

// 每页条数变化
const handleSizeChange = (val) => {
  pageSize.value = val
  fetchPosts()
}

// 处理举报帖子
const handleReportPost = (post) => {
  if (!userStore.isLoggedIn) {
    ElMessage.warning('请先登录')
    router.push('/login')
    return
  }
  
  reportForm.value = {
    type: 1, // 帖子类型
    targetId: post.id,
    targetContent: post.title,
    reason: ''
  }
  
  reportDialogVisible.value = true
}

// 提交举报
const submitReport = async () => {
  if (!reportFormRef.value) return
  
  await reportFormRef.value.validate(async (valid) => {
    if (!valid) return
    
    reportSubmitting.value = true
    try {
      const reportData = {
        type: reportForm.value.type,
        targetId: reportForm.value.targetId,
        reason: reportForm.value.reason
      }
      
      await request.post('/report/add', reportData, {
        successMsg: '举报提交成功，管理员会尽快处理',
        onSuccess: () => {
          reportDialogVisible.value = false
          reportForm.value.reason = ''
        }
      })
    } catch (error) {
      console.error('提交举报失败:', error)
    } finally {
      reportSubmitting.value = false
    }
  })
}

// 获取版块颜色
const getSectionColor = (id) => {
  const colors = {
    1: '#409EFF', // 学术交流
    2: '#67C23A', // 教学资源
    3: '#E6A23C', // 课外活动
    4: '#F56C6C', // 技术交流
    5: '#9254DE'  // 校园生活
  }
  return colors[id] || '#909399'
}

// 获取版块图标
const getSectionIcon = (id) => {
  const icons = {
    1: 'Reading',      // 学术交流
    2: 'Collection',   // 教学资源
    3: 'Sunny',        // 课外活动
    4: 'Monitor',      // 技术交流
    5: 'School'        // 校园生活
  }
  return icons[id] || 'Grid'
}

// 处理编辑板块
const handleEditSection = () => {
  editForm.sectionName = section.value.sectionName
  editForm.description = section.value.description
  editDialogVisible.value = true
}

// 提交编辑
const submitEdit = async () => {
  if (!editFormRef.value) return
  
  await editFormRef.value.validate(async (valid) => {
    if (!valid) return
    
    submitting.value = true
    try {
      await request.put(`/section/${sectionId.value}`, editForm, {
        successMsg: '板块信息更新成功',
        onSuccess: () => {
          editDialogVisible.value = false
          fetchSectionDetail() // 重新获取板块信息
        }
      })
    } catch (error) {
      console.error('更新板块信息失败:', error)
    } finally {
      submitting.value = false
    }
  })
}

// 在 script setup 中添加
const moderatorDetailVisible = ref(false)
const currentModerator = ref(null)

// 显示版主详情
const showModeratorDetail = (moderator) => {
  currentModerator.value = moderator
  moderatorDetailVisible.value = true
}

// 获取角色标签
const getRoleLabel = (role) => {
  const roleMap = {
    1: '管理员',
    2: '用户'
  }
  return roleMap[role] || '未知'
}

// 在 script setup 中添加
const statusLoading = ref(false)

// 处理状态变更
const handleStatusChange = async (status) => {
  try {
    statusLoading.value = true
    await request.put(`/section/${sectionId.value}/status?status=${status}`, null, {
      successMsg: `板块已${status === 1 ? '启用' : '禁用'}`,
      onSuccess: () => {
        // 更新本地状态
        section.value.status = status
      },
      onError: () => {
        // 如果失败，回滚状态
        section.value.status = status === 1 ? 0 : 1
      }
    })
  } catch (error) {
    console.error('更新板块状态失败:', error)
  } finally {
    statusLoading.value = false
  }
}

// 添加删除状态变量
const deleteLoading = ref(false)

// 处理删除帖子
const handleDeletePost = (post) => {
  if (!userStore.isLoggedIn) {
    ElMessage.warning('请先登录')
    return
  }
  
  // 检查是否是作者
  if (post.userId !== userStore.userId) {
    ElMessage.warning('只能删除自己的帖子')
    return
  }
  
  // 如果正在删除，不重复操作
  if (post.isDeleting) {
    return
  }
  
  ElMessageBox.confirm('确定要删除这篇帖子吗？此操作不可恢复！', '警告', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(async () => {
    // 设置帖子删除中状态
    const postIndex = posts.value.findIndex(p => p.id === post.id)
    if (postIndex !== -1) {
      posts.value[postIndex].isDeleting = true
    }
    
    deleteLoading.value = true
    try {
      await request.delete(`/post/${post.id}`,{

        successMsg: '删除成功',
        onSuccess: () => {
          // 从列表中移除帖子，使用setTimeout显示过渡效果
          setTimeout(() => {
            posts.value = posts.value.filter(p => p.id !== post.id)
            // 更新帖子数量和分页
            total.value--
            postCount.value--
            // 如果帖子是今天发布的，减少今日帖子计数
            const today = new Date().toDateString()
            const postDate = new Date(post.createTime).toDateString()
            if (today === postDate) {
              todayPosts.value--
            }
          }, 500) // 500ms后删除，这样有动画过渡效果
          
      
        },
        onError: (error) => {
          // 删除失败，恢复帖子状态
          if (postIndex !== -1) {
            posts.value[postIndex].isDeleting = false
          }
          console.error('删除帖子失败:', error)
          ElMessage.error('删除帖子失败：' + (error?.message || '未知错误'))
        }
      })
    } catch (error) {
      // 删除失败，恢复帖子状态
      if (postIndex !== -1) {
        posts.value[postIndex].isDeleting = false
      }
      console.error('删除帖子失败:', error)
      ElMessage.error('删除帖子失败：' + (error?.message || '未知错误'))
    } finally {
      deleteLoading.value = false
    }
  }).catch(() => {
    // 用户取消删除操作，什么也不做
  })
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
  // 返回对应的组件名称
  return icons[id] || 'Grid'
}

// 获取更亮的颜色（用于渐变）
const getLighterColor = (color) => {
  // 简单实现，实际可以用色彩处理库
  if (color === '#409EFF') return '#6abeff' 
  if (color === '#67C23A') return '#95e373'
  if (color === '#E6A23C') return '#ffc773'
  if (color === '#F56C6C') return '#ff9e9e'
  if (color === '#9254DE') return '#c596ff'
  return '#c0c4cc'
}

onMounted(() => {
  fetchSectionDetail()
  fetchPosts()
})
</script>

<style lang="scss" scoped>
.section-detail {
  width: 100%;
  max-width: 1200px;
  margin: 0 auto;
}

.section-info-card {
  margin-bottom: 30px;
  border-radius: 16px;
  overflow: hidden;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
  position: relative;
  
  .card-bg {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 220px;
    z-index: 0;
    filter: saturate(1.05);
  }

  .card-bg::after {
    content: '';
    position: absolute;
    inset: 0;
    background: linear-gradient(
      to bottom,
      rgba(0, 0, 0, 0.12) 0%,
      rgba(0, 0, 0, 0.26) 100%
    );
  }
}

.section-header {
  display: flex;
  align-items: flex-start;
  padding: 30px 30px 64px;
  min-height: 220px;
  position: relative;
  z-index: 1;
  
  @media (max-width: 768px) {
    flex-direction: column;
    gap: this;
  }
}

.section-basic {
  flex: 1;
  display: flex;
  align-items: flex-start;
  gap: 20px;
}

.section-icon {
  width: 70px;
  height: 70px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  border-radius: 16px;
  margin-right: 5px;
  box-shadow: 0 8px 16px rgba(0, 0, 0, 0.2);
  
  .el-icon {
    font-size: 30px;
  }
}

.section-text {
  flex: 1;
}

.section-name {
  font-size: 28px;
  margin: 0 0 8px;
  font-weight: 700;
  color: #fff;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
}

.section-desc {
  font-size: 16px;
  color: rgba(255, 255, 255, 0.9);
  margin: 0 0 15px;
  text-shadow: 0 1px 2px rgba(0, 0, 0, 0.1);
}

.section-meta {
  display: flex;
  gap: 20px;
  
  .meta-item {
    display: flex;
    align-items: center;
    font-size: 14px;
    color: rgba(255, 255, 255, 0.85);
    gap: 5px;
    
    .el-icon {
      font-size: 16px;
    }
    
    .meta-value {
      font-weight: 700;
    }
  }
}

.section-actions {
  display: flex;
  gap: 10px;
  align-items: center;
  margin-top: 20px;
  
  @media (max-width: 768px) {
    margin-top: 20px;
    align-self: flex-end;
  }
}

.moderator-list {
  background-color: #f8f9fa;
  padding: 20px 30px;
  border-top: 1px solid rgba(0, 0, 0, 0.05);
  
  .moderator-title {
    margin: 0 0 15px;
    font-size: 18px;
    font-weight: 600;
    color: #333;
    display: flex;
    align-items: center;
    gap: 8px;
    
    .el-icon {
      color: #8e44ad;
    }
  }
  
  .moderator-items {
    display: flex;
    gap: 20px;
    flex-wrap: wrap;
  }
  
  .moderator-item {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 10px 15px;
    background-color: #ffffff;
    border-radius: 12px;
    transition: all 0.3s;
    cursor: pointer;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
    
    &:hover {
      transform: translateY(-5px);
      box-shadow: 0 8px 16px rgba(0, 0, 0, 0.1);
    }
    
    .moderator-info {
      display: flex;
      flex-direction: column;
      gap: 5px;
    }
    
    .moderator-name {
      font-size: 15px;
      font-weight: 600;
      color: #333;
    }
  }
}

.post-list-section {
  margin-bottom: 30px;
}

.post-filter-card {
  margin-bottom: 20px;
  border-radius: 16px;
  overflow: hidden;
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.05);
}

.filter-options {
  display: flex;
  justify-content: space-between;
  align-items: center;
  
  @media (max-width: 768px) {
    flex-direction: column;
    gap: 15px;
  }
}

.filter-tabs {
  display: flex;
  gap: 5px;
  background: #f5f7fa;
  padding: 5px;
  border-radius: 12px;
  
  .filter-tab {
    padding: 8px 16px;
    border-radius: 8px;
    cursor: pointer;
    display: flex;
    align-items: center;
    gap: 6px;
    font-size: 14px;
    font-weight: 500;
    color: #606266;
    transition: all 0.3s;
    
    &:hover {
      background: rgba(142, 68, 173, 0.1);
      color: #8e44ad;
    }
    
    &.active {
      background: #8e44ad;
      color: white;
      
      .tab-icon {
        color: white;
      }
    }
    
    .tab-icon {
      color: #8e44ad;
      display: flex;
      align-items: center;
      
      .el-icon {
        font-size: 16px;
      }
    }
  }
}

.search-container {
  display: flex;
  gap: 10px;
  
  .search-input {
    width: 250px;
    .el-input__wrapper {
      border-radius: 20px;
    }
  }
}

.post-list-card {
  margin-bottom: 20px;
  border-radius: 16px;
  overflow: hidden;
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.05);
}

.empty-container {
  padding: 40px 0;
  text-align: center;
  
  p {
    color: #909399;
    margin-bottom: 20px;
  }
}

.post-item {
  display: flex;
  padding: 25px;
  border-bottom: 1px solid rgba(0, 0, 0, 0.05);
  transition: all 0.3s;
  
  &:hover {
    background-color: #f9f9fe;
  }

  &:last-child {
    border-bottom: none;
  }
  
  &.deleting {
    opacity: 0.5;
    background-color: #fef0f0;
  }
  
  @media (max-width: 768px) {
    flex-direction: column;
    gap: 15px;
  }
}

.post-author {
  margin-right: 25px;
  display: flex;
  flex-direction: column;
  align-items: center;
  
  @media (max-width: 768px) {
    flex-direction: row;
    gap: 15px;
    margin-right: 0;
  }
}

.author-info {
  text-align: center;
  margin-top: 10px;
  
  @media (max-width: 768px) {
    text-align: left;
    margin-top: 0;
  }
}

.author-name {
  font-size: 15px;
  font-weight: 600;
  margin-bottom: 5px;
  color: #333;
}

.post-time {
  font-size: 13px;
  color: #8e44ad;
}

.post-content {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.post-title {
  font-size: 18px;
  font-weight: 700;
  color: #303133;
  text-decoration: none;
  margin-bottom: 12px;
  display: block;
  line-height: 1.4;

  &:hover {
    color: #8e44ad;
  }
}

.essence-tag {
  margin-right: 8px;
  border-radius: 4px;
}

.post-summary {
  font-size: 15px;
  color: #606266;
  margin-bottom: 20px;
  line-height: 1.6;
  flex: 1;
}

.post-footer {
  display: flex;
  align-items: center;
  justify-content: space-between;
  
  .post-stats, .post-actions {
    display: flex;
    align-items: center;
    gap: 20px;
  }
}

.post-views,
.post-comments,
.post-delete,
.post-report {
  display: flex;
  align-items: center;
  gap: 5px;
  font-size: 14px;
  color: #909399;
}

.post-delete {
  cursor: pointer;
  transition: all 0.3s;

  &:hover {
    color: #f56c6c;
    transform: scale(1.05);
  }
}

.post-report {
  cursor: pointer;
  transition: all 0.3s;

  &:hover {
    color: #f56c6c;
    transform: scale(1.05);
  }
}

.pagination-container {
  margin-top: 25px;
  display: flex;
  justify-content: center;
}

.moderator-detail {
  .detail-header {
    display: flex;
    align-items: center;
    margin-bottom: 25px;
    padding-bottom: 20px;
    border-bottom: 1px solid #ebeef5;

    .user-basic {
      margin-left: 20px;

      h3 {
        margin: 0 0 8px;
        font-size: 20px;
        color: #303133;
      }

      .real-name, .role-tag {
        margin: 5px 0;
      }
    }
  }
  
  .user-info-cards {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 15px;
    margin-bottom: 25px;
    
    .info-card {
      display: flex;
      align-items: center;
      gap: 12px;
      padding: 15px;
      background-color: #f5f7fa;
      border-radius: 10px;
      
      .info-icon {
        width: 40px;
        height: 40px;
        border-radius: 10px;
        background-color: #8e44ad;
        color: white;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 18px;
      }
      
      .info-content {
        flex: 1;
        
        .info-label {
          font-size: 12px;
          color: #909399;
          margin-bottom: 5px;
        }
        
        .info-value {
          font-size: 14px;
          font-weight: 600;
          color: #303133;
        }
      }
    }
  }
  
  .user-description {
    margin-bottom: 20px;
    
    .description-title {
      display: flex;
      align-items: center;
      gap: 8px;
      font-size: 16px;
      font-weight: 600;
      color: #303133;
      margin-bottom: 10px;
      
      .el-icon {
        color: #8e44ad;
      }
    }
    
    .description-content {
      background-color: #f5f7fa;
      padding: 15px;
      border-radius: 10px;
      font-size: 14px;
      color: #606266;
      line-height: 1.6;
    }
  }
}

/* 帖子列表的动画 */
.post-list-enter-active,
.post-list-leave-active {
  transition: all 0.5s ease;
}
.post-list-enter-from,
.post-list-leave-to {
  opacity: 0;
  transform: translateY(30px);
}

.dialog-header {
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 18px;
  font-weight: 600;
  
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

.report-target {
  font-size: 14px;
  color: #606266;
  background-color: #f5f7fa;
  padding: 10px 15px;
  border-radius: 8px;
  max-height: 80px;
  overflow-y: auto;
  word-break: break-all;
}
</style> 
