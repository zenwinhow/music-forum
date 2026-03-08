/**
 * 菜单工具函数
 * 用于生成侧边栏菜单数据
 */

/**
 * 根据路由和用户角色生成侧边栏菜单
 * @param {Array} routes 路由配置
 * @param {Number} userRole 用户角色ID
 * @returns {Array} 菜单数据
 */
export function generateMenus(routes, userRole) {
  const menus = []
  
  // 找到后台管理路由
  const backendRoute = routes.find(route => route.path === '/back')
  
  if (!backendRoute || !backendRoute.children) {
    console.error('未找到后台管理路由或其子路由为空')
    return menus
  }
  
  // 过滤出当前用户角色可访问的路由
  backendRoute.children.forEach(route => {
    // 跳过重定向路由
    if (route.path === '') return
    
    // 检查路由是否应该在菜单中隐藏
    if (route.meta?.hideInMenu) return
    
    // 检查用户是否有权限访问此路由
    const roles = route.meta?.roles
    if (roles && !roles.includes(userRole)) return
    
    const menu = {
      path: route.path,
      name: route.name,
      icon: route.meta?.icon || '',
      meta: route.meta || {},
      children: []
    }
    
    // 处理子菜单
    if (route.children && route.children.length > 0) {
      route.children.forEach(childRoute => {
        // 跳过重定向路由
        if (childRoute.path === '') return
        
        // 检查子路由是否应该在菜单中隐藏
        if (childRoute.meta?.hideInMenu) return
        
        // 检查用户是否有权限访问此子路由
        const childRoles = childRoute.meta?.roles
        if (childRoles && !childRoles.includes(userRole)) return
        
        menu.children.push({
          path: childRoute.path,
          name: childRoute.name,
          icon: childRoute.meta?.icon || '',
          meta: childRoute.meta || {}
        })
      })
    }
    
    // 当子菜单为空但菜单本身有效时，仍然添加该菜单
    if (menu.children.length === 0) {
      delete menu.children
    }
    
    // 只添加有权限访问的菜单
    menus.push(menu)
  })
  
  return menus
}

/**
 * 将路由元数据转换为菜单项
 * @param {Object} route 路由对象
 * @returns {Object} 菜单项
 */
function routeToMenuItem(route) {
  return {
    path: route.path,
    name: route.meta?.title || route.name,
    icon: route.meta?.icon || '',
    meta: route.meta || {},
    children: route.children ? route.children.map(routeToMenuItem) : []
  }
} 