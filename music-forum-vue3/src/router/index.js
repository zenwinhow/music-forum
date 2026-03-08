// 路由配置
import { createRouter, createWebHistory } from 'vue-router'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/login',
      component: () => import('@/views/auth/Login.vue')
    },
    {
      path: '/register',
      component: () => import('@/views/auth/Register.vue')
    },
    {
      path: '/',
      component: () => import('@/layouts/FrontLayout.vue'),
      children: [
        {
          path: '',
          redirect: '/home'
        },
        {
          path: 'home',
          name: 'Home',
          component: () => import('@/views/frontend/Home.vue'),
          meta: {
            title: '首页',
            icon: 'HomeFilled'
          }
        },
        {
          path: '/forum/section/:id',
          name: 'SectionDetail',
          component: () => import('@/views/frontend/SectionDetail.vue'),
          meta: { title: '板块详情', requireAuth: false }
        },
        {
          path: '/forum/create-post',
          name: 'CreatePost',
          component: () => import('@/views/frontend/CreatePost.vue'),
          meta: { title: '发表帖子', requireAuth: true }
        },
        {
          path: '/forum/post/:id',
          name: 'PostDetail',
          component: () => import('@/views/frontend/post/PostDetail.vue'),
          meta: { title: '帖子详情', requireAuth: false }
        },
        {
          path: '/resource/:id',
          name: 'ResourceDetail',
          component: () => import('@/views/frontend/ResourceDetail.vue'),
          meta: {
            title: '资源详情',
            requireAuth: false
          }
        },
        {
          path: '/resources',
          name: 'Resources',
          component: () => import('@/views/frontend/Resources.vue'),
          meta: {
            title: '资源中心',
            requireAuth: false
          }
        },
        {
          path: '/sections',
          name: 'Sections',
          component: () => import('@/views/frontend/Sections.vue'),
          meta: {
            title: '论坛板块',
            requireAuth: false
          }
        },
        {
          path: '/user/profile',
          name: 'UserProfile',
          component: () => import('@/views/frontend/user/Profile.vue'),
          meta: {
            title: '用户中心',
            requireAuth: true
          }
        },
        {
          path: '/user/favorites',
          name: 'UserFavorites',
          component: () => import('@/views/frontend/user/UserFavorites.vue'),
          meta: {
            title: '我的收藏',
            requireAuth: true
          }
        },
        {
          path:'notification',
          name:"Notification",
          component:()=>import('@/views/frontend/Notification.vue'),
          meta:{
            title:'通知公告',
            requireAuth: false
          }
        },
        {
          path: '/about',
          name: 'About',
          component: () => import('@/views/frontend/About.vue'),
          meta: {
            title: '关于我们',
            requireAuth: false
          }
        },
        {
          path: '/forum/search',
          name: 'Search',
          component: () => import('@/views/frontend/Search.vue')
        }
      ]
    },
    {
      path: '/back',
      component: () => import('@/layouts/BackendLayout.vue'),
      children: [
        // 仪表盘
        {
          path: '',
          redirect: '/back/dashboard'
        },
        {
          path: 'dashboard',
          name: 'Dashboard',
          component: () => import('@/views/backend/Dashboard.vue'),
          meta: {
            title: '控制台',
            icon: 'Odometer'
          }
        },
        // 个人中心
        {
          path: 'profile',
          name: 'Profile',
          component: () => import('@/views/backend/user/UserProfile.vue'),
          meta: {
            title: '个人中心',
            icon: 'User'
          }
        },
        // 用户管理模块
        {
          path: 'user',
          name: 'UserManagement',
          component: () => import('@/layouts/RouterView.vue'),
          meta: {
            title: '用户管理',
            icon: 'UserFilled',
            roles: [1] // 仅管理员可访问
          },
          children: [
            {
              path: '',
              redirect: '/back/user/list'
            },
            {
              path: 'list',
              name: 'UserList',
              component: () => import('@/views/backend/user/UserManagement.vue'),
              meta: {
                title: '用户列表'
              }
            },
            {
              path: 'info',
              name: 'PersonInfo',
              component: () => import('@/views/backend/user/PersonInfo.vue'),
              meta: {
                title: '个人信息'
              }
            }
          ]
        },
        // 帖子管理模块
        {
          path: 'post',
          name: 'PostManagement',
          component: () => import('@/layouts/RouterView.vue'),
          meta: {
            title: '帖子管理',
            icon: 'Document'
          },
          children: [
            {
              path: '',
              redirect: '/back/post/list'
            },
            {
              path: 'list',
              name: 'PostList',
              component: () => import('@/views/backend/post/PostManagement.vue'),
              meta: {
                title: '帖子列表'
              }
            }
          ]
        },
        // 评论管理模块
        {
          path: 'comment',
          name: 'CommentManagement',
          component: () => import('@/layouts/RouterView.vue'),
          meta: {
            title: '评论管理',
            icon: 'ChatDotRound'
          },
          children: [
            {
              path: '',
              redirect: '/back/comment/list'
            },
            {
              path: 'list',
              name: 'CommentList',
              component: () => import('@/views/backend/comment/CommentManagement.vue'),
              meta: {
                title: '评论列表'
              }
            }
          ]
        },
        // 版块管理模块
        {
          path: 'section',
          name: 'SectionManagement',
          component: () => import('@/layouts/RouterView.vue'),
          meta: {
            title: '版块管理',
            icon: 'Grid',
            roles: [1] // 仅管理员可访问
          },
          children: [
            {
              path: '',
              redirect: '/back/section/list'
            },
            {
              path: 'list',
              name: 'SectionList',
              component: () => import('@/views/backend/section/SectionManagement.vue'),
              meta: {
                title: '版块列表'
              }
            },
            {
              path: 'moderator',
              name: 'ModeratorManagement',
              component: () => import('@/views/backend/section/ModeratorManagement.vue'),
              meta: {
                title: '版主管理'
              }
            }
          ]
        },
        // 资源管理模块
        {
          path: 'resource',
          name: 'ResourceManagement',
          component: () => import('@/layouts/RouterView.vue'),
          meta: { 
            title: '资源管理',
            icon: 'Files'
          },
          children: [
            {
              path: '',
              redirect: '/back/resource/list'
            },
            {
              path: 'list',
              name: 'ResourceList',
              component: () => import('@/views/backend/resource/ResourceManagement.vue'),
              meta: { 
                title: '资源列表'
              }
            },
            {
              path: 'category',
              name: 'ResourceCategoryManagement',
              component: () => import('@/views/backend/resource/ResourceCategoryManagement.vue'),
              meta: { 
                title: '资源分类管理'
              }
            }
          ]
        },
        // 系统管理模块（管理员权限）
        {
          path: 'system',
          name: 'SystemManagement',
          component: () => import('@/layouts/RouterView.vue'),
          meta: { 
            title: '系统管理',
            icon: 'Setting',
            roles: [1] // 仅管理员可访问
          },
          children: [
            {
              path: '',
              redirect: '/back/system/notification'
            },
            {
              path: 'notification',
              name: 'NotificationManagement',
              component: () => import('@/views/backend/system/NotificationManagement.vue'),
              meta: {
                title: '通知管理'
              }
            },
            {
              path: 'report',
              name: 'ReportManagement',
              component: () => import('@/views/backend/system/ReportManagement.vue'),
              meta: {
                title: '举报管理'
              }
            }
          ]
        }
      ]
    }
  ]
})

export default router