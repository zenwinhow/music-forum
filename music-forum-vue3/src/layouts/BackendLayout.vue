<template>
  <div class="backend-layout">
    <div class="sidebar-wrapper">
      <Sidebar />
    </div>
    <div class="main-content">
      <div class="navbar-container">
        <Navbar @logout="handleLogout" />
      </div>
      <div class="content-container">
        <router-view />
      </div>
    </div>
  </div>
</template>

<script setup>
import { onMounted } from 'vue'
import { useUserStore } from '@/store/user'
import { useRouter } from 'vue-router'
import Sidebar from '@/components/backend/Sidebar.vue'
import Navbar from '@/components/backend/Navbar.vue'
import { ElMessage } from 'element-plus'

const userStore = useUserStore()
const router = useRouter()

const handleLogout = () => {
  userStore.clearUserInfo()
  router.push('/login')
}

onMounted(async () => {
  if (!userStore.isLoggedIn) {
    router.push('/login')
    return
  }

  if (!userStore.menus || userStore.menus.length === 0 || !userStore.userInfo) {
    try {
      await userStore.getUserInfo()
      if (!userStore.menus || userStore.menus.length === 0) {
        userStore.generateMenusFromRoutes()
      }
    } catch (error) {
      console.error('恢复用户状态失败:', error)
      ElMessage.error('登录状态已过期，请重新登录')
      router.push('/login')
    }
  }
})
</script>

<style lang="scss" scoped>
.backend-layout {
  display: flex;
  width: 100%;
  height: 100vh;
  overflow: hidden;
}

.sidebar-wrapper {
  flex-shrink: 0;
  height: 100%;
}

.main-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  height: 100%;
  overflow: hidden;
}

.navbar-container {
  height: 60px;
  flex-shrink: 0;
  background: linear-gradient(90deg, #111827, #1f2937);
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.2);
  z-index: 10;
}

.content-container {
  flex: 1;
  padding: 20px;
  overflow-y: auto;
  background: #f3f4f6;
}
</style>
