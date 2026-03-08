import request from '@/utils/request'

/**
 * 用户登录
 * @param {Object} data 登录信息
 * @returns {Promise} 返回Promise对象
 */
export function login(data) {
  return request.post('/user/login', data)
}

/**
 * 用户注册
 * @param {Object} data 注册信息
 * @returns {Promise} 返回Promise对象
 */
export function register(data) {
  return request.post('/user/register', data)
}

/**
 * 获取用户信息
 * @param {Number} id 用户ID
 * @returns {Promise} 返回Promise对象
 */
export function getUserInfo(id) {
  return request.get(`/user/${id}`)
}

/**
 * 获取用户列表
 * @param {Object} params 查询参数
 * @returns {Promise} 返回Promise对象
 */
export function getUserList(params) {
  return request.get('/user/page', params)
}

/**
 * 创建用户
 * @param {Object} data 用户信息
 * @returns {Promise} 返回Promise对象
 */
export function createUser(data) {
  return request.post('/user/add', data)
}

/**
 * 更新用户信息
 * @param {Number} id 用户ID
 * @param {Object} data 用户信息
 * @returns {Promise} 返回Promise对象
 */
export function updateUser(id, data) {
  return request.put(`/user/${id}`, data)
}

/**
 * 删除用户
 * @param {Number} id 用户ID
 * @returns {Promise} 返回Promise对象
 */
export function deleteUser(id) {
  return request.delete(`/user/${id}`)
}

/**
 * 批量删除用户
 * @param {Array} ids 用户ID数组
 * @returns {Promise} 返回Promise对象
 */
export function batchDeleteUsers(ids) {
  return request.delete('/user/batch', { data: ids })
}

/**
 * 修改用户状态
 * @param {Number} id 用户ID
 * @param {Number} status 状态（0-禁用，1-正常）
 * @returns {Promise} 返回Promise对象
 */
export function updateUserStatus(id, status) {
  return request.put(`/user/${id}/status?status=${status}`)
}

/**
 * 修改密码
 * @param {Number} id 用户ID
 * @param {Object} data 密码信息
 * @returns {Promise} 返回Promise对象
 */
export function updatePassword(id, data) {
  return request.put(`/user/password/${id}`, data)
}

/**
 * 忘记密码
 * @param {String} email 邮箱
 * @param {String} newPassword 新密码
 * @returns {Promise} 返回Promise对象
 */
export function forgetPassword(email, newPassword) {
  return request.post('/user/forget', { email, newPassword })
}

/**
 * 根据角色获取用户
 * @param {Number} role 角色（1-管理员，2-用户）
 * @returns {Promise} 返回Promise对象
 */
export function getUsersByRole(role) {
  return request.get(`/user/role/${role}`)
} 
