<template>
  <header class="front-header">
    <div class="header-container">
      <router-link to="/home" class="logo">
        <img src="@/assets/logo.png" alt="音乐论坛" class="logo-image" />
        <span class="site-name">Music Forum 音乐分享社区</span>
      </router-link>

      <nav class="main-nav">
        <router-link to="/home" class="nav-link">首页</router-link>
        <router-link to="/sections" class="nav-link">音乐分类</router-link>
        <router-link to="/forum/create-post" class="nav-link">发布分享</router-link>
        <router-link to="/forum/search" class="nav-link">搜索</router-link>
      </nav>

      <div class="user-info">
        <template v-if="isLoggedIn">
          <el-dropdown trigger="click" @command="handleCommand">
            <div class="user-avatar">
              <el-avatar :src="'/api' + avatar" :size="34">{{ username?.charAt(0)?.toUpperCase() }}</el-avatar>
              <span>{{ username }}</span>
            </div>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="profile">个人中心</el-dropdown-item>
                <el-dropdown-item command="favorites">我的收藏</el-dropdown-item>
                <el-dropdown-item divided command="logout">退出</el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </template>
        <template v-else>
          <router-link to="/login"><el-button type="primary" round>登录</el-button></router-link>
        </template>
      </div>
    </div>
  </header>
</template>

<script setup>
import { computed } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '@/store/user'

const router = useRouter()
const userStore = useUserStore()

const isLoggedIn = computed(() => userStore.isLoggedIn)
const username = computed(() => userStore.username)
const avatar = computed(() => userStore.avatar)

const handleCommand = (command) => {
  if (command === 'profile') router.push('/user/profile')
  if (command === 'favorites') router.push('/user/favorites')
  if (command === 'logout') {
    userStore.logout()
    router.push('/login')
  }
}
</script>

<style scoped>
.front-header { background: #0f172a; border-bottom: 1px solid #334155; position: sticky; top: 0; z-index: 100; }
.header-container { max-width: 1200px; margin: 0 auto; height: 64px; display: flex; align-items: center; justify-content: space-between; padding: 0 16px; }
.logo { display: flex; align-items: center; gap: 10px; text-decoration: none; }
.logo-image { width: 30px; height: 30px; }
.site-name { color: #e2e8f0; font-weight: 700; }
.main-nav { display: flex; gap: 16px; }
.nav-link { color: #cbd5e1; text-decoration: none; }
.nav-link.router-link-active { color: #60a5fa; }
.user-avatar { display: flex; align-items: center; gap: 8px; color: #e2e8f0; cursor: pointer; }
</style>
