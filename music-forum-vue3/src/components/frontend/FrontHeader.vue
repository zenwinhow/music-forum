<template>
  <header class="front-header">
    <div class="header-container">
      <!-- Logo和站点名称 -->
      <div class="logo-container">
        <router-link to="/home" class="logo">
          <div class="logo-icon">
            <img src="@/assets/学校.png" alt="校园交流论坛" class="logo-image" />
          </div>
          <span class="site-name">校园论坛交流网站</span>
        </router-link>
      </div>

      <!-- 导航菜单 -->
      <nav class="main-nav">
        <ul class="nav-list">
          <li class="nav-item">
            <router-link to="/" class="nav-link" active-class="active">
              <el-icon><HomeFilled /></el-icon>
              <span>首页</span>
            </router-link>
          </li>
          <li class="nav-item">
            <router-link to="/sections" class="nav-link" active-class="active">
              <el-icon><Grid /></el-icon>
              <span>论坛板块</span>
            </router-link>
          </li>
          <li class="nav-item">
            <router-link to="/resources" class="nav-link" active-class="active">
              <el-icon><Files /></el-icon>
              <span>教学资源</span>
            </router-link>
          </li>
          <li class="nav-item">
            <router-link to="/notification" class="nav-link" active-class="active">
              <el-icon><Bell /></el-icon>
              <span>通知公告</span>
            </router-link>
          </li>
          <li class="nav-item">
            <router-link to="/about" class="nav-link" active-class="active">
              <el-icon><School /></el-icon>
              <span>关于我们</span>
            </router-link>
          </li>
        </ul>
      </nav>

      <!-- 用户信息/登录按钮 -->
      <div class="user-info">
        <template v-if="isLoggedIn">
          <!-- 消息通知 -->
          <el-badge :value="unreadCount" :max="99" class="notification-badge" v-if="unreadCount > 0">
            <el-button circle class="message-btn" @click="goToMessage">
              <el-icon><Bell /></el-icon>
            </el-button>
          </el-badge>

          <el-dropdown trigger="click" @command="handleCommand">
            <div class="user-avatar">
              <el-avatar :src="'/api' + avatar" :size="40">{{ username?.charAt(0).toUpperCase() }}</el-avatar>
              <div class="user-meta">
              <span class="username">{{ username }}</span>
                <span class="user-role">{{ userRole }}</span>
              </div>
            </div>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="profile">
                  <el-icon><User /></el-icon>个人中心
                </el-dropdown-item>
  
                <el-dropdown-item divided command="logout">
                  <el-icon><SwitchButton /></el-icon>退出登录
                </el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </template>
        <template v-else>
          <router-link to="/login" class="login-btn">
            <el-button type="primary" round>登录</el-button>
          </router-link>
          <router-link to="/register" class="register-btn">
            <el-button round>注册</el-button>
          </router-link>
        </template>
      </div>
    </div>
  </header>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '@/store/user'
import { 
  Search, HomeFilled, Grid, Files, Bell, School,
  User, ChatDotRound, Document, Star, Setting, SwitchButton 
} from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'

const router = useRouter()
const userStore = useUserStore()

// 用户登录状态和信息
const isLoggedIn = computed(() => userStore.isLoggedIn)
const isAdmin = computed(() => userStore.isAdmin)
const username = computed(() => userStore.username)
const avatar = computed(() => userStore.avatar)
const unreadCount = ref(0) // 未读消息数量

// 用户角色显示
const userRole = computed(() => {
  const role = userStore.userInfo?.role
  switch (role) {
    case 1: return '管理员'
    case 2: return '教师'
    case 3: return '学生'
    default: return '用户'
  }
})

// 跳转到消息页面
const goToMessage = () => {
  router.push('/forum/message')
}

// 用户菜单命令处理
const handleCommand = (command) => {
  switch (command) {
    case 'profile':
      router.push('/user/profile')
      break
    case 'message':
      router.push('/forum/message')
      break
    case 'post':
      router.push('/forum/my-posts')
      break
    case 'favorite':
      router.push('/user/favorites')
      break
    case 'admin':
      router.push('/admin/dashboard')
      break
    case 'logout':
      userStore.logout()
      router.push('/login')
      ElMessage.success('已成功退出登录')
      break
  }
}
</script>

<style lang="scss" scoped>
.front-header {
  background-color: #fff;
  box-shadow: 0 1px 6px rgba(0, 0, 0, 0.05);
  position: sticky;
  top: 0;
  z-index: 100;
}

.header-container {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 20px;
  height: 64px;
  max-width: 1200px;
  margin: 0 auto;
}

.logo-container {
  display: flex;
  align-items: center;
  margin-right: 20px;
}

.logo {
  display: flex;
  align-items: center;
  text-decoration: none;
  gap: 12px;
}

.logo-icon {
  width: 40px;
  height: 40px;
  border-radius: 12px;
  background-color: #ffffff;
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
}

.logo-image {
  width: 100%;
  height: 100%;
  object-fit: contain;
}

.site-name {
  font-size: 1.4rem;
  font-weight: bold;
  background: linear-gradient(120deg, #41b883, #1982c3);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  white-space: nowrap;
}

.main-nav {
  flex: 1;
  margin: 0 30px;
}

.nav-list {
  display: flex;
  list-style: none;
  margin: 0;
  padding: 0;
}

.nav-item {
  margin: 0 15px;
}

.nav-link {
  color: #606266;
  text-decoration: none;
  font-size: 15px;
  padding: 8px 12px;
  border-radius: 6px;
  display: flex;
  align-items: center;
  gap: 4px;
  transition: all 0.3s;
}

.nav-link:hover {
  color: #41b883;
  background-color: rgba(65, 184, 131, 0.1);
}

.nav-link.active {
  color: #41b883;
  background-color: rgba(65, 184, 131, 0.1);
  font-weight: 500;
}

.nav-link .el-icon {
  font-size: 16px;
}

.search-box {
  display: none;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 16px;
}

.notification-badge {
  margin-right: 8px;
}

.message-btn {
  color: #606266;
}

.user-avatar {
  display: flex;
  align-items: center;
  cursor: pointer;
  padding: 2px;
  border-radius: 24px;
  transition: all 0.3s;
}

.user-avatar:hover {
  background-color: #f5f7fa;
}

.user-meta {
  margin-left: 8px;
  line-height: 1.2;
}

.username {
  font-size: 14px;
  color: #303133;
  font-weight: 500;
}

.user-role {
  font-size: 12px;
  color: #909399;
  display: block;
}

.login-btn,
.register-btn {
  margin-left: 10px;
}

:deep(.el-dropdown-menu__item) {
  display: flex;
  align-items: center;
  gap: 8px;
}

:deep(.el-dropdown-menu__item .el-icon) {
  margin-right: 4px;
}

@media (max-width: 1024px) {
  .nav-item {
    margin: 0 10px;
  }
  
  .user-meta {
    display: none;
  }
}

@media (max-width: 768px) {
  .logo-icon {
    width: 36px;
    height: 36px;
    border-radius: 10px;
  }
  
  .site-name {
    display: none;
  }
  
  .nav-link {
    font-size: 14px;
    padding: 6px 8px;
  }
  
  .nav-link span {
    display: none;
  }
  
  .nav-link .el-icon {
    font-size: 18px;
    margin: 0;
  }
}
</style> 