import { defineStore } from 'pinia'
import request from '@/utils/request'
import { generateMenus } from '@/utils/menu'
import router from '@/router'

export const useUserStore = defineStore('user', {
  state: () => ({
    userInfo: JSON.parse(localStorage.getItem('userInfo')) || null,
    token: localStorage.getItem('token') || '',
    role: localStorage.getItem('role') || null,
    menus: JSON.parse(localStorage.getItem('menus')) || []
  }),

  getters: {
    // 判断是否登录
    isLoggedIn: (state) => !!state.token,
    // 判断是否是管理员
    isAdmin: (state) => state.role === 1,
    // 判断是否是教师
    isTeacher: (state) => state.role === 2,
    // 判断是否是学生
    isStudent: (state) => state.role === 3,
    // 获取用户ID
    userId: (state) => state.userInfo?.id,
    // 获取用户名
    username: (state) => state.userInfo?.username,
    // 获取用户头像
    avatar: (state) => state.userInfo?.avatar || '/avatars/default.png',
  },

  actions: {
    // 根据ID获取用户信息
    fetchUserById(id, options = {}) {
      return request.get(`/user/${id}`, null, {
        showDefaultMsg: false,
        ...options
      })
    },
    
    // 更新用户信息
    updateUserInfo(userInfo) {
      if (!userInfo) return
      this.userInfo = { ...this.userInfo, ...userInfo }
      localStorage.setItem('userInfo', JSON.stringify(this.userInfo))
    },
    
    // 设置用户信息并存储到本地
    setUserInfo(user) {
      if (!user) return
      
      this.userInfo = user
      this.role = user.role
      
      // 存储到 LocalStorage
      localStorage.setItem('userInfo', JSON.stringify(this.userInfo))
      localStorage.setItem('role', this.role || '')
    },
    
    // 清除用户信息
    clearUserInfo() {
      this.userInfo = null
      this.token = ''
      this.role = null
      this.menus = []
      // 清除 LocalStorage
      localStorage.removeItem('userInfo')
      localStorage.removeItem('token')
      localStorage.removeItem('role')
      localStorage.removeItem('menus')
    },
    
    // 设置菜单信息
    setMenus(menus) {
      if (!menus) return
      this.menus = menus
      localStorage.setItem('menus', JSON.stringify(menus))
    },
    
    // 从localStorage恢复用户信息和菜单
    async getUserInfo() {
      try {
        // 尝试从本地存储获取
      const userInfo = JSON.parse(localStorage.getItem('userInfo'))
      const menus = JSON.parse(localStorage.getItem('menus'))
      
        if (userInfo) {
        this.userInfo = userInfo
          this.role = userInfo.role
          
          // 恢复本地存储的菜单
          if (menus && menus.length > 0) {
        this.menus = menus
          } 
          // 如果没有本地菜单，但不主动生成菜单
          
          return { userInfo, menus: this.menus }
      }
      
        // 如果没有用户信息但有token，可能是数据不一致的情况
        if (this.token) {
          console.warn('有token但没有用户信息，数据不一致')
        }
        
        // 如果没有用户信息，清除状态
      this.clearUserInfo()
        throw new Error('找不到用户信息，请重新登录')
      } catch (error) {
        console.error('获取用户信息失败:', error)
        this.clearUserInfo()
        throw error
      }
    },
    
    // 使用menu.js中的工具函数生成菜单
    generateMenusFromRoutes() {
      if (!this.role) {
        console.error('无法生成菜单：用户角色未设置')
        return []
      }
      
      try {
        // 获取路由配置
        const routes = router.options.routes
        
        // 尝试使用menu.js生成菜单
        let menus = generateMenus(routes, this.role)
        
        // 如果生成的菜单为空（可能因为找不到/back路径），则使用备用方法
        if (!menus || menus.length === 0) {
          console.warn('使用menu.js生成菜单失败，尝试使用备用方法')
          
          // 查找后台路由 - 可能是/admin或/back
          const adminRoute = routes.find(route => 
            route.path === '/admin' || route.path === '/back'
          )
          
          if (adminRoute && adminRoute.children) {
            // 过滤可访问的路由
            menus = adminRoute.children
              .filter(route => {
                // 跳过重定向和隐藏路由
                if (route.path === '' || route.meta?.hideInMenu) return false
                
                // 检查角色权限
                const roles = route.meta?.roles
                return !roles || roles.includes(this.role)
              })
              .map(route => ({
                path: route.path,
                name: route.meta?.title || route.name,
                icon: route.meta?.icon || '',
                meta: route.meta || {}
              }))
          }
          
          // 如果仍然没有菜单，生成一个默认菜单
          if (!menus || menus.length === 0) {
            console.warn('备用方法生成菜单失败，使用硬编码基础菜单')
            menus = [
              {
                path: 'dashboard',
                name: '首页',
                icon: 'HomeFilled',
                meta: { title: '首页' }
              }
            ]
          }
        }
        
        console.log('生成的菜单:', menus)
        this.setMenus(menus)
        return menus
      } catch (error) {
        console.error('生成菜单时出错:', error)
        // 返回空菜单，而不是抛出错误中断流程
        return []
      }
    },
    
    // 登录操作
    login(loginForm, options = {}) {
      const store = this
      
      request.post('/user/login', loginForm, {
        showDefaultMsg: true,
        successMsg: '登录成功',
        errorMsg: '登录失败，请检查用户名和密码',
        onSuccess: (res) => {
          // 存储用户信息和token
          store.setUserInfo(res)
          store.setToken(res.token)
          
          // 如果提供了成功回调，则调用
          if (options.onSuccess) {
            options.onSuccess(res)
          }
        },
        onError: (error) => {
          // 登录失败，清除数据
          store.clearUserInfo()
          
          // 如果提供了错误回调，则调用
          if (options.onError) {
            options.onError(error)
          }
        },
        ...options
      })
    },
    
    // 退出登录
    logout() {
      this.clearUserInfo()
    },
    
    // 检查登录状态
    checkLoginStatus() {
      return !!this.token
    },
    
    // 设置token
    setToken(token) {
      this.token = token
      localStorage.setItem('token', token)
    },
  }
})