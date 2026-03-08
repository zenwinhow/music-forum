<template>
    <div class="backend-layout">
      <!-- 侧边栏 -->
      <div class="sidebar-wrapper">
        <Sidebar />
      </div>
  
      <!-- 主要内容区域 -->
      <div class="main-content">
        <!-- 顶部导航栏 -->
        <div class="navbar-container">
          <Navbar @logout="handleLogout" />
        </div>
  
        <!-- 页面内容 -->
        <div class="content-container">
          <router-view />
        </div>
      </div>
    </div>
  </template>
  
  <script setup>
  import { computed, onMounted } from 'vue'
  import { useUserStore } from '@/store/user'
  import { useRouter } from 'vue-router'
  import Sidebar from '@/components/backend/Sidebar.vue'
  import Navbar from '@/components/backend/Navbar.vue'
  import { ElMessage } from 'element-plus'
  
  const userStore = useUserStore()
  const router = useRouter()
  
  const isAdmin = computed(() => userStore.role === 1)
  
  // 处理用户退出登录
  const handleLogout = () => {
    userStore.clearUserInfo()
    router.push('/login')
  }
  
  // 组件挂载时检查用户信息和菜单
  onMounted(async () => {
    console.log('BackendLayout组件挂载，开始检查用户状态')
    
    // 如果未登录，跳转到登录页
    if (!userStore.isLoggedIn) {
      console.log('未检测到登录状态，跳转到登录页')
      router.push('/login')
      return
    }
    
    console.log('当前用户状态:', {
      isLoggedIn: userStore.isLoggedIn,
      token: !!userStore.token,
      userInfo: userStore.userInfo,
      menus: userStore.menus
    })
    
    // 如果菜单为空或用户信息不完整，尝试重新获取
    if (!userStore.menus || userStore.menus.length === 0 || !userStore.userInfo) {
      console.log('用户信息或菜单不完整，尝试重新获取')
      try {
        // 从本地存储恢复用户信息
        const result = await userStore.getUserInfo()
        console.log('用户信息获取成功:', result)
        
        // 如果恢复后菜单仍然为空，则使用路由生成菜单
        if (!userStore.menus || userStore.menus.length === 0) {
          console.log('菜单为空，尝试使用路由生成菜单')
          userStore.generateMenusFromRoutes()
        }
      } catch (error) {
        console.error('获取用户信息失败:', error)
        // 如果获取失败是由于未登录或token无效导致的，跳转到登录页
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
    background-color: #fff;
    box-shadow: 0 1px 4px rgba(0, 0, 0, 0.1);
    z-index: 10;
  }
  
  .content-container {
    flex: 1;
    padding: 20px;
    overflow-y: auto;
    background-color: #f5f5f5;
    
    &::-webkit-scrollbar {
      width: 8px;
    }
    
    &::-webkit-scrollbar-thumb {
      background: rgba(0, 0, 0, 0.2);
      border-radius: 4px;
    }
    
    &::-webkit-scrollbar-track {
      background: transparent;
    }
  }
  </style>