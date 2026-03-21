import { defineStore } from 'pinia'
import request from '@/utils/request'
import { generateMenus } from '@/utils/menu'
import router from '@/router'

export const useUserStore = defineStore('user', {
  state: () => ({
    userInfo: JSON.parse(localStorage.getItem('userInfo')) || null,
    token: localStorage.getItem('token') || '',
    role: Number(localStorage.getItem('role')) || null,
    menus: JSON.parse(localStorage.getItem('menus')) || []
  }),

  getters: {
    isLoggedIn: (state) => !!state.token,
    isAdmin: (state) => state.role === 1,
    isUser: (state) => state.role === 2,
    userId: (state) => state.userInfo?.id,
    username: (state) => state.userInfo?.username,
    avatar: (state) => state.userInfo?.avatar || '/avatars/default.png'
  },

  actions: {
    fetchUserById(id, options = {}) {
      return request.get(`/user/${id}`, null, {
        showDefaultMsg: false,
        ...options
      })
    },

    updateUserInfo(userInfo) {
      if (!userInfo) return
      this.userInfo = { ...this.userInfo, ...userInfo }
      localStorage.setItem('userInfo', JSON.stringify(this.userInfo))
    },

    setUserInfo(user) {
      if (!user) return
      this.userInfo = user
      this.role = Number(user.role)
      localStorage.setItem('userInfo', JSON.stringify(this.userInfo))
      localStorage.setItem('role', String(this.role || ''))
    },

    clearUserInfo() {
      this.userInfo = null
      this.token = ''
      this.role = null
      this.menus = []
      localStorage.removeItem('userInfo')
      localStorage.removeItem('token')
      localStorage.removeItem('role')
      localStorage.removeItem('menus')
    },

    setMenus(menus) {
      if (!menus) return
      this.menus = menus
      localStorage.setItem('menus', JSON.stringify(menus))
    },

    async getUserInfo() {
      try {
        const userInfo = JSON.parse(localStorage.getItem('userInfo'))
        const menus = JSON.parse(localStorage.getItem('menus'))
        if (userInfo) {
          this.userInfo = userInfo
          this.role = Number(userInfo.role)
          if (menus && menus.length > 0) this.menus = menus
          return { userInfo, menus: this.menus }
        }
        this.clearUserInfo()
        throw new Error('No user info found')
      } catch (error) {
        this.clearUserInfo()
        throw error
      }
    },

    generateMenusFromRoutes() {
      if (!this.role) return []
      try {
        const routes = router.options.routes
        let menus = generateMenus(routes, this.role)
        if (!menus || menus.length === 0) {
          const adminRoute = routes.find((route) => route.path === '/admin' || route.path === '/back')
          if (adminRoute && adminRoute.children) {
            menus = adminRoute.children
              .filter((route) => {
                if (route.path === '' || route.meta?.hideInMenu) return false
                const roles = route.meta?.roles
                return !roles || roles.includes(this.role)
              })
              .map((route) => ({
                path: route.path,
                name: route.meta?.title || route.name,
                icon: route.meta?.icon || '',
                meta: route.meta || {}
              }))
          }
        }
        this.setMenus(menus || [])
        return menus || []
      } catch (error) {
        return []
      }
    },

    login(loginForm, options = {}) {
      const store = this
      request.post('/user/login', loginForm, {
        showDefaultMsg: true,
        successMsg: 'Login success',
        errorMsg: 'Login failed',
        onSuccess: (res) => {
          store.setUserInfo(res)
          store.setToken(res.token)
          if (options.onSuccess) options.onSuccess(res)
        },
        onError: (error) => {
          store.clearUserInfo()
          if (options.onError) options.onError(error)
        },
        ...options
      })
    },

    logout() {
      this.clearUserInfo()
    },

    checkLoginStatus() {
      return !!this.token
    },

    setToken(token) {
      this.token = token
      localStorage.setItem('token', token)
    }
  }
})
