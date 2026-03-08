<template>
  <div class="user-profile">
    <el-row :gutter="20">
      <!-- 左侧个人信息卡片 -->
      <el-col :xs="24" :sm="24" :md="8" :lg="6" :xl="5">
        <el-card class="user-card">
          <div class="user-avatar">
            <el-avatar :size="100" :src="avatarUrl">
              {{ userInfo.username?.charAt(0)?.toUpperCase() }}
            </el-avatar>
          </div>
          <div class="user-info">
            <h2 class="user-name">{{ userInfo.username }}</h2>
            <p class="user-role">{{ getRoleName(userInfo.role) }}</p>
            <div class="user-signature">{{ userInfo.signature || '这个人很懒，什么都没留下...' }}</div>
          </div>
          <div class="user-stats">
            <div class="stat-item">
              <div class="stat-value">{{ userStats.postCount }}</div>
              <div class="stat-label">帖子</div>
            </div>
            <div class="stat-item">
              <div class="stat-value">{{ userStats.commentCount }}</div>
              <div class="stat-label">评论</div>
            </div>
            <div class="stat-item">
              <div class="stat-value">{{ userStats.favoriteCount }}</div>
              <div class="stat-label">收藏</div>
            </div>
          </div>
        </el-card>
      </el-col>
      
      <!-- 右侧内容区 -->
      <el-col :xs="24" :sm="24" :md="16" :lg="18" :xl="19">
        <el-card>
          <template #header>
            <div class="card-header">
              <el-tabs v-model="activeTab">
                <el-tab-pane label="基本资料" name="basic"></el-tab-pane>
                <el-tab-pane label="我的帖子" name="posts"></el-tab-pane>
                <el-tab-pane label="我的评论" name="comments"></el-tab-pane>
                <el-tab-pane label="我的收藏" name="favorites"></el-tab-pane>
                <el-tab-pane label="安全设置" name="security"></el-tab-pane>
              </el-tabs>
            </div>
          </template>
          
          <!-- 基本资料 -->
          <div v-if="activeTab === 'basic'">
          
            <el-form :model="profileForm" label-width="100px" :rules="profileRules" ref="profileFormRef">
              <el-form-item label="用户名">
                <el-input v-model="profileForm.username" disabled />
              </el-form-item>
              <el-form-item label="真实姓名" prop="realName">
                <el-input v-model="profileForm.realName" />
              </el-form-item>
              <el-form-item label="电子邮箱" prop="email">
                <el-input v-model="profileForm.email" />
              </el-form-item>
              <el-form-item label="联系电话" prop="phone">
                <el-input v-model="profileForm.phone" />
              </el-form-item>
              <el-form-item label="个性签名" prop="signature">
                <el-input v-model="profileForm.signature" type="textarea" :rows="2" />
              </el-form-item>
              <el-form-item label="个人简介" prop="profile">
                <el-input v-model="profileForm.profile" type="textarea" :rows="4" placeholder="介绍一下你自己吧..." />
              </el-form-item>
              <el-form-item label="头像">
                <el-upload
                  class="avatar-uploader"
                  action="#"
                  :show-file-list="false"
                  :auto-upload="false"
                  :on-change="handleAvatarChange"
                >
                  <div class="avatar-wrapper">
                    <img v-if="avatarUrl" :src="avatarUrl" class="avatar-preview" />
                   
                    <el-icon v-else class="avatar-uploader-icon"><Plus /></el-icon>
                    <div class="avatar-hover-mask">
                      <el-icon><Plus /></el-icon>
                    </div>
                   
                  </div>
                </el-upload>
                <div class="upload-tip">点击上传头像，支持JPG、PNG、JPEG格式，大小不超过2MB</div>
               
              </el-form-item>
              <el-form-item>
                <el-button type="primary" @click="submitProfile" :loading="submitting">保存修改</el-button>
                <el-button @click="resetProfile">重置</el-button>
              </el-form-item>
            </el-form>
          </div>
          
          <!-- 我的帖子 -->
          <div v-else-if="activeTab === 'posts'">
            <div v-if="posts?.length === 0" class="empty-tip">
              暂无发布的帖子
            </div>
            <div v-else class="post-list">
              <div v-for="post in posts" :key="post.id" class="post-item">
                <div class="post-title">
                  <el-link @click="$router.push(`/forum/post/${post.id}`)">{{ post.title }}</el-link>
                </div>
                <div class="post-meta">
                  <span>{{ formatDate(post.createTime) }}</span>
                  <span>{{ post.viewCount }} 阅读</span>
                  <span>{{ post.commentCount }} 评论</span>
                </div>
              </div>
            </div>
          </div>
          
          <!-- 我的评论 -->
          <div v-else-if="activeTab === 'comments'">
            <div v-if="comments?.length === 0" class="empty-tip">
              暂无发表的评论
            </div>
            <div v-else class="comment-list">
              <div v-for="comment in comments" :key="comment.id" class="comment-item">
                <div class="comment-content">{{ comment.content }}</div>
                <div class="comment-meta">
                  <span>评论于：<el-link @click="$router.push(`/post/${comment.postId}`)">{{ comment.postTitle }}</el-link></span>
                  <span>{{ formatDate(comment.createTime) }}</span>
                </div>
              </div>
            </div>
          </div>
          
          <!-- 我的收藏 -->
          <div v-else-if="activeTab === 'favorites'">
            <div v-if="favorites?.length === 0" class="empty-tip">
              暂无收藏的帖子
            </div>
            <div v-else class="favorite-list">
              <div v-for="favorite in favorites" :key="favorite.id" class="favorite-item">
                <div class="favorite-title">
                  <el-link @click="$router.push(`/forum/post/${favorite.postId}`)">{{ favorite.postTitle }}</el-link>
                </div>
                <div class="favorite-meta">
                  <span>收藏于：{{ formatDate(favorite.createTime) }}</span>
                  <el-button type="danger" link @click="cancelFavorite(favorite.id)">
                    取消收藏
                  </el-button>
                </div>
              </div>
              <div class="pagination-container">
                <el-pagination
                  v-model:current-page="favoritePagination.currentPage"
                  v-model:page-size="favoritePagination.pageSize"
                  :total="favoritePagination.total"
                  :page-sizes="[10, 20, 30, 50]"
                  layout="total, sizes, prev, pager, next, jumper"
                  @size-change="fetchUserFavorites"
                  @current-change="handleFavoritePageChange"
                />
              </div>
            </div>
          </div>
          
          <!-- 安全设置 -->
          <div v-else-if="activeTab === 'security'">
            <el-form :model="passwordForm" label-width="120px" :rules="passwordRules" ref="passwordFormRef">
              <el-form-item label="当前密码" prop="currentPassword">
                <el-input v-model="passwordForm.currentPassword" type="password" show-password />
              </el-form-item>
              <el-form-item label="新密码" prop="newPassword">
                <el-input v-model="passwordForm.newPassword" type="password" show-password />
              </el-form-item>
              <el-form-item label="确认新密码" prop="confirmPassword">
                <el-input v-model="passwordForm.confirmPassword" type="password" show-password />
              </el-form-item>
              <el-form-item>
                <el-button type="primary" @click="submitPassword" :loading="submitting">修改密码</el-button>
                <el-button @click="resetPassword">重置</el-button>
              </el-form-item>
            </el-form>
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted, watch } from 'vue'
import { useUserStore } from '@/store/user'
import { ElMessage } from 'element-plus'
import { Plus } from '@element-plus/icons-vue'
import { formatDate } from '@/utils/format'
import request from '@/utils/request'

const userStore = useUserStore()
const activeTab = ref('basic')
const avatarUrl = ref('')
const submitting = ref(false)

// 表单引用
const profileFormRef = ref(null)
const passwordFormRef = ref(null)

// 从userStore获取用户基本信息
const userInfo = computed(() => ({
  userId: userStore.userId,
  username: userStore.username,
  avatar: userStore.avatar,
  role: userStore.userInfo?.role,
  realName: userStore.userInfo?.realName,
  email: userStore.userInfo?.email,
  phone: userStore.userInfo?.phone,
  signature: userStore.userInfo?.signature,
  profile: userStore.userInfo?.profile
}))

// 用户统计数据
const userStats = reactive({
  postCount: 0,
  commentCount: 0,
  favoriteCount: 0
})

// 列表数据
const posts = ref([])
const comments = ref([])
const favorites = ref([])
const favoritePagination = reactive({
  currentPage: 1,
  pageSize: 10,
  total: 0
})

// 个人资料表单
const profileForm = reactive({
  username: '',
  realName: '',
  email: '',
  phone: '',
  signature: '',
  profile: ''
})

// 个人资料验证规则
const profileRules = {
  realName: [
    { required: true, message: '请输入真实姓名', trigger: 'blur' },
    { min: 2, max: 20, message: '长度在 2 到 20 个字符', trigger: 'blur' }
  ],
  email: [
    { required: true, message: '请输入邮箱地址', trigger: 'blur' },
    { type: 'email', message: '请输入正确的邮箱地址', trigger: 'blur' }
  ],
  phone: [
    { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号码', trigger: 'blur' }
  ],
  signature: [
    { max: 200, message: '签名不能超过200个字符', trigger: 'blur' }
  ],
  profile: [
    { max: 500, message: '个人简介不能超过500个字符', trigger: 'blur' }
  ]
}

// 修改密码表单
const passwordForm = reactive({
  currentPassword: '',
  newPassword: '',
  confirmPassword: ''
})

// 密码表单验证规则
const passwordRules = {
  currentPassword: [
    { required: true, message: '请输入当前密码', trigger: 'blur' },
    { min: 6, message: '密码长度不能小于6位', trigger: 'blur' }
  ],
  newPassword: [
    { required: true, message: '请输入新密码', trigger: 'blur' },
    { min: 6, message: '密码长度不能小于6位', trigger: 'blur' }
  ],
  confirmPassword: [
    { required: true, message: '请确认新密码', trigger: 'blur' },
    {
      validator: (rule, value, callback) => {
        if (value !== passwordForm.newPassword) {
          callback(new Error('两次输入的密码不一致'))
        } else {
          callback()
        }
      },
      trigger: 'blur'
    }
  ]
}
 
 const getUserInfo = async () => {
  try {
    const res = await request.get(`/user/${userStore.userId}`, null, {
      showDefaultMsg: false,
      onSuccess: (res) => {
        userInfo.value = res
      },
      onError: (error) => {
        console.error('获取用户信息失败:', error)
      }
    })

  } catch (error) {
    console.error('获取用户信息失败:', error)
  }
}
// 获取用户角色名称
const getRoleName = (role) => {
  const roles = {
    1: '管理员',
    2: '教师',
    3: '学生'
  }
  return roles[role] || '未知角色'
}

// 处理头像变更
const handleAvatarChange = async (file) => {
  const isImage = file.type === 'image/jpeg' || file.type === 'image/png'||file.type === 'image/jpg'
  const isLt2M = file.size / 1024 / 1024 < 2

  if (!isLt2M) {
    ElMessage.error('上传头像图片大小不超过2MB!')
    return
  }

  // 创建表单数据
  const formData = new FormData()
  formData.append('file', file.raw)

  try {
    await request.post('/file/upload/img', formData, {
      headers: {
        'Content-Type': 'multipart/form-data'
      },
      onSuccess: (res) => {
        // 存储原始URL
        const originalUrl = res
        // 显示时添加API前缀
        avatarUrl.value = `/api${originalUrl}`
        
        // 更新个人资料时使用原始URL
        const updateData = {
          realName: profileForm.realName,
          email: profileForm.email,
          phone: profileForm.phone,
          signature: profileForm.signature,
          profile: profileForm.profile,
          avatar: originalUrl // 使用原始URL存储
        }
        
        // 更新个人资料
        submitProfile(updateData)
      },
      onError: (error) => {
        console.error('头像上传失败:', error)
        ElMessage.error('头像上传失败')
      },
      showDefaultMsg: false
    })
  } catch (error) {
    console.error('头像上传失败:', error)
    ElMessage.error('头像上传失败')
  }
}

// 获取用户统计数据
const fetchUserStats = async () => {
  try {
    await request.get(`/user/${userStore.userId}/stats`, null, {
      showDefaultMsg: false,
      onSuccess: (res) => {
        Object.assign(userStats, res)
      }
    })
  } catch (error) {
    console.error('获取用户统计数据失败:', error)
  }
}

// 获取用户帖子列表
const fetchUserPosts = async () => {
  try {
    await request.get(`/post/user/${userStore.userId}`, null, {
      showDefaultMsg: false,
      onSuccess: (res) => {
        posts.value = res
      }
    })
  } catch (error) {
    console.error('获取用户帖子失败:', error)
  }
}

// 获取用户评论列表
const fetchUserComments = async () => {
  try {
    await request.get(`/comment/user/${userStore.userId}`, null, {
      showDefaultMsg: false,
      onSuccess: (res) => {
        comments.value = res
      }
    })
  } catch (error) {
    console.error('获取用户评论失败:', error)
  }
}

// 获取用户收藏列表
const fetchUserFavorites = async () => {
  try {
    const params = {
      currentPage: favoritePagination.currentPage,
      size: favoritePagination.pageSize
    }
    await request.get('/post/favorite/user', params, {
      showDefaultMsg: false,
      onSuccess: (res) => {
        favorites.value = res.records
        favoritePagination.total = res.total
      }
    })
  } catch (error) {
    console.error('获取用户收藏失败:', error)
  }
}

// 处理收藏分页变化
const handleFavoritePageChange = (page) => {
  favoritePagination.currentPage = page
  fetchUserFavorites()
}

// 初始化个人资料表单
const initProfileForm = () => {
  Object.assign(profileForm, {
    username: userInfo.value.username,
    realName: userInfo.value.realName,
    email: userInfo.value.email,
    phone: userInfo.value.phone,
    signature: userInfo.value.signature,
    profile: userInfo.value.profile
  })
  // 显示时添加API前缀
  avatarUrl.value = userInfo.value.avatar ? `/api${userInfo.value.avatar}` : ''
}

// 提交个人资料
const submitProfile = async (updateData = null) => {
  if (!profileFormRef.value) return
  
  await profileFormRef.value.validate(async (valid) => {
    if (!valid) return
    
    submitting.value = true
    try {
      // 如果没有传入updateData，则使用表单数据
      const data = updateData || {
        realName: profileForm.realName,
        email: profileForm.email,
        phone: profileForm.phone,
        signature: profileForm.signature,
        profile: profileForm.profile
      }
      
      await request.put(`/user/${userStore.userId}`, data, {
        successMsg: '个人资料修改成功',
        onSuccess: (res) => {
          // 更新store中的用户信息
          userStore.updateUserInfo(data)
          if (!updateData) {
            initProfileForm()
          }
        }
      })
    } catch (error) {
      console.error('修改个人资料失败:', error)
    } finally {
      submitting.value = false
    }
  })
}

// 重置个人资料
const resetProfile = () => {
  if (profileFormRef.value) {
    profileFormRef.value.resetFields()
  }
  initProfileForm()
}

// 提交密码修改
const submitPassword = async () => {
  if (!passwordFormRef.value) return
  
  await passwordFormRef.value.validate(async (valid) => {
    if (!valid) return
    
    submitting.value = true
    try {
      await request.put(`/user/password/${userStore.userId}`, {
        oldPassword: passwordForm.currentPassword,
        newPassword: passwordForm.newPassword
      }, {
        successMsg: '密码修改成功',
        onSuccess: () => {
          resetPassword()
        }
      })
    } catch (error) {
      console.error('修改密码失败:', error)
    } finally {
      submitting.value = false
    }
  })
}

// 重置密码表单
const resetPassword = () => {
  if (passwordFormRef.value) {
    passwordFormRef.value.resetFields()
  }
}

// 取消收藏
const cancelFavorite = async (favoriteId) => {
  try {
    await request.delete(`/post/favorite/${favoriteId}`,{
           successMsg: '取消收藏成功',
      onSuccess: () => {
        fetchUserFavorites()
        fetchUserStats()
      }
    })
  } catch (error) {
    console.error('取消收藏失败:', error)
  }
}

// 监听标签页切换
const handleTabChange = (tab) => {
  switch (tab) {
    case 'posts':
      fetchUserPosts()
      break
    case 'comments':
      fetchUserComments()
      break
    case 'favorites':
      fetchUserFavorites()
      break
  }
}

// 组件挂载时获取数据
onMounted(async () => {
  // 初始化表单数据
  initProfileForm()
  console.log(userInfo.value)
  await getUserInfo()
  // 获取统计数据
  await fetchUserStats()
  
  // 初始加载当前标签页数据
  handleTabChange(activeTab.value)
})

// 监听标签页变化
watch(activeTab, (newTab) => {
  handleTabChange(newTab)
})
</script>

<style lang="scss" scoped>
.user-profile {
  padding: 20px;
  
  .user-card {
    display: flex;
    flex-direction: column;
    align-items: center;
    padding: 20px;
    
    .user-avatar {
      margin-bottom: 20px;
    }
    
    .user-info {
      width: 100%;
      text-align: center;
      margin-bottom: 20px;
      
      .user-name {
        margin: 0 0 5px;
        font-size: 18px;
        font-weight: 600;
      }
      
      .user-role {
        margin: 0 0 10px;
        color: #909399;
        font-size: 14px;
      }
      
      .user-signature {
        color: #606266;
        font-size: 14px;
        line-height: 1.4;
        font-style: italic;
        padding: 0 10px;
      }
    }
    
    .user-stats {
      width: 100%;
      display: flex;
      justify-content: space-around;
      margin-top: 10px;
      padding-top: 15px;
      border-top: 1px solid #ebeef5;
      
      .stat-item {
        text-align: center;
        
        .stat-value {
          font-size: 20px;
          font-weight: 600;
          color: #409EFF;
        }
        
        .stat-label {
          font-size: 12px;
          color: #909399;
        }
      }
    }
  }
  
  .avatar-uploader {
    .avatar-wrapper {
      width: 100px;
      height: 100px;
      border: 1px dashed #d9d9d9;
      border-radius: 6px;
      cursor: pointer;
      position: relative;
      overflow: hidden;
      transition: all 0.3s;
      
      &:hover {
        border-color: #409EFF;
        
        .avatar-hover-mask {
          opacity: 1;
        }
      }
      
      .avatar-preview {
        width: 100%;
        height: 100%;
        object-fit: cover;
      }
      
      .avatar-uploader-icon {
        width: 28px;
        height: 28px;
        font-size: 28px;
        color: #8c939d;
        position: absolute;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
      }
      
      .avatar-hover-mask {
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: rgba(0, 0, 0, 0.5);
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
  
  .empty-tip {
    text-align: center;
    color: #909399;
    padding: 40px 0;
  }
  
  .post-list,
  .comment-list,
  .favorite-list {
    .post-item,
    .comment-item,
    .favorite-item {
      padding: 15px 0;
      border-bottom: 1px solid #ebeef5;
      
      &:last-child {
        border-bottom: none;
      }
      
      .post-title,
      .favorite-title {
        font-size: 16px;
        margin-bottom: 10px;
      }
      
      .comment-content {
        color: #606266;
        margin-bottom: 10px;
      }
      
      .post-meta,
      .comment-meta,
      .favorite-meta {
        color: #909399;
        font-size: 13px;
        display: flex;
        justify-content: space-between;
        align-items: center;
        
        > span {
          margin-right: 15px;
          
          &:last-child {
            margin-right: 0;
          }
        }
      }
    }
  }

  .pagination-container {
    margin-top: 20px;
    display: flex;
    justify-content: center;
  }
}
</style> 