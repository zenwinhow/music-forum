<template>
  <div class="front-layout">
    <!-- 页面头部 -->
    <FrontHeader />
    
    <!-- 主要内容区域 -->
    <main class="main-content">
      <router-view />
    </main>
    
    <!-- 页面底部 -->
    <FrontFooter />
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useUserStore } from '@/store/user'
import { useRouter } from 'vue-router'
import FrontHeader from '@/components/frontend/FrontHeader.vue'
import FrontFooter from '@/components/frontend/FrontFooter.vue'

const userStore = useUserStore()
const router = useRouter()

// 用户登录状态
const isLoggedIn = computed(() => userStore.isLoggedIn)

// 用户角色信息
const isAdmin = computed(() => userStore.isAdmin)
const isTeacher = computed(() => userStore.isTeacher)
const isStudent = computed(() => userStore.isStudent)

// 用户信息
const userInfo = computed(() => userStore.userInfo)
const username = computed(() => userStore.username)
const avatar = computed(() => userStore.avatar)
</script>

<style scoped>
.front-layout {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
  background-color: #f5f7fa;
}

.main-content {
  flex: 1;
  padding: 20px;
  width: 100%;
  max-width: 1200px;
  margin: 0 auto;
}

@media (max-width: 1200px) {
  .main-content {
    padding: 15px;
  }
}

@media (max-width: 768px) {
  .main-content {
    padding: 10px;
  }
}
</style> 