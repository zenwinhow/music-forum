<template>
  <div class="sidebar-container" :class="{ 'is-collapsed': isCollapsed }">
    <div class="logo"><span v-show="!isCollapsed">音乐论坛管理后台</span></div>
    <el-menu :default-active="activeMenu" :collapse="isCollapsed" router class="sidebar-menu">
      <template v-for="menu in menuItems" :key="menu.path">
        <el-menu-item v-if="!menu.children?.length" :index="getMenuPath(menu)">
          <span>{{ getMenuTitle(menu) }}</span>
        </el-menu-item>
        <el-sub-menu v-else :index="getMenuPath(menu)">
          <template #title><span>{{ getMenuTitle(menu) }}</span></template>
          <el-menu-item v-for="child in menu.children" :key="child.path" :index="getChildMenuPath(menu, child)">
            <span>{{ getMenuTitle(child) }}</span>
          </el-menu-item>
        </el-sub-menu>
      </template>
    </el-menu>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import { useUserStore } from '@/store/user'
import { useAppStore } from '@/store/app'

const route = useRoute()
const userStore = useUserStore()
const appStore = useAppStore()

const isCollapsed = computed(() => appStore.sidebarCollapsed)
const menuItems = computed(() => userStore.menus || [])
const activeMenu = computed(() => route.path)

const getMenuPath = (menu) => {
  if (!menu.path) return '/back/dashboard'
  if (menu.path.startsWith('/')) return menu.path
  if (menu.path.startsWith('back/')) return `/${menu.path}`
  return `/back/${menu.path}`
}
const getChildMenuPath = (parent, child) => `${getMenuPath(parent).replace(/\/$/, '')}/${child.path}`
const getMenuTitle = (menu) => menu.meta?.title || menu.name || '菜单'
</script>

<style scoped>
.sidebar-container{height:100%;background:#0f172a;color:#fff;width:220px}
.sidebar-container.is-collapsed{width:64px}
.logo{height:60px;display:flex;align-items:center;justify-content:center;border-bottom:1px solid #334155}
.sidebar-menu{border:none;height:calc(100% - 60px)}
</style>
