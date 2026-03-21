<template>
  <div class="user-profile">
    <el-row :gutter="20">
      <el-col :xs="24" :sm="24" :md="8" :lg="6" :xl="5">
        <el-card class="user-card">
          <div class="user-avatar">
            <el-avatar :size="100" :src="avatarUrl">
              {{ userInfo.name?.charAt(0)?.toUpperCase() || userInfo.username?.charAt(0)?.toUpperCase() }}
            </el-avatar>
          </div>
          <div class="user-info">
            <h2 class="user-name">{{ userInfo.name || userInfo.username }}</h2>
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
              <div class="stat-value">{{ userStats.resourceCount }}</div>
              <div class="stat-label">资源</div>
            </div>
          </div>
        </el-card>
      </el-col>
      
      <el-col :xs="24" :sm="24" :md="16" :lg="18" :xl="19">
        <el-card>
          <template #header>
            <div class="card-header">
              <el-tabs v-model="activeTab">
                <el-tab-pane label="基本资料" name="basic"></el-tab-pane>
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
import { ref, reactive, computed, onMounted } from 'vue'
import { useUserStore } from '@/store/user'
import { ElMessage } from 'element-plus'
import { Plus } from '@element-plus/icons-vue'
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
  name: userStore.userInfo?.realName,
  avatar: userStore.avatar,
  role: userStore.userInfo?.role,
  email: userStore.userInfo?.email,
  phone: userStore.userInfo?.phone,
  signature: userStore.userInfo?.signature,
  profile: userStore.userInfo?.profile
}))

// 用户统计数据
const userStats = reactive({
  postCount: 0,
  commentCount: 0,
  resourceCount: 0
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

// 获取用户详细信息
const getUserInfo = async () => {
  try {
    await request.get(`/user/${userStore.userId}`, null, {
      showDefaultMsg: false,
      onSuccess: (res) => {
        // 更新用户信息
        userStore.updateUserInfo(res)
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
    2: '用户'
  }
  return roles[role] || '未知角色'
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

// 处理头像变更
const handleAvatarChange = async (file) => {
  const isImage = file.type === 'image/jpeg' || file.type === 'image/png' || file.type === 'image/jpg'
  const isLt2M = file.size / 1024 / 1024 < 2

  // if (!isImage) {
  //   ElMessage.error('上传头像图片只能是JPG、PNG或JPEG格式!')
  //   return
  // }
  if (!isLt2M) {
    ElMessage.error('上传头像图片大小不能超过2MB!')
    return
  }

  // 创建表单数据
  const formData = new FormData()
  formData.append('file', file.raw)

  try {
    submitting.value = true
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
  } finally {
    submitting.value = false
  }
}

// 初始化个人资料表单
const initProfileForm = () => {
  Object.assign(profileForm, {
    username: userInfo.value.username,
    realName: userInfo.value.name,
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
        onSuccess: () => {
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

onMounted(async () => {
  // 获取用户信息
  await getUserInfo()
  
  // 初始化表单数据
  initProfileForm()
  
  // 获取统计数据
  await fetchUserStats()
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
  
  .card-header {
    padding: 0;
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
}
</style> 
