/**
 * 格式化日期为可读字符串
 * @param {Date|string|number} date - 要格式化的日期
 * @returns {string} 格式化后的日期字符串，格式为 YYYY-MM-DD HH:MM:SS
 */
export const formatDate = (date) => {
  if (!date) return ''
  const d = new Date(date)
  const year = d.getFullYear()
  const month = String(d.getMonth() + 1).padStart(2, '0')
  const day = String(d.getDate()).padStart(2, '0')
  const hour = String(d.getHours()).padStart(2, '0')
  const minute = String(d.getMinutes()).padStart(2, '0')
  const second = String(d.getSeconds()).padStart(2, '0')
  return `${year}-${month}-${day} ${hour}:${minute}:${second}`
}

/**
 * 格式化日期，只显示年月日
 * @param {Date|string|number} date - 要格式化的日期
 * @returns {string} 格式化后的日期字符串，格式为 YYYY-MM-DD
 */
export const formatDateOnly = (date) => {
  if (!date) return ''
  const d = new Date(date)
  const year = d.getFullYear()
  const month = String(d.getMonth() + 1).padStart(2, '0')
  const day = String(d.getDate()).padStart(2, '0')
  return `${year}-${month}-${day}`
}

/**
 * 格式化时间为相对时间（如：几分钟前，几小时前，几天前等）
 * @param {Date|string|number} datetime - 要格式化的日期时间
 * @returns {string} 相对时间字符串
 */
export const formatRelativeTime = (datetime) => {
  if (!datetime) return ''
  
  const date = new Date(datetime)
  const now = new Date()
  const diff = Math.floor((now - date) / 1000) // 时间差（秒）
  
  if (diff < 60) {
    return '刚刚'
  } else if (diff < 3600) {
    return Math.floor(diff / 60) + '分钟前'
  } else if (diff < 86400) {
    return Math.floor(diff / 3600) + '小时前'
  } else if (diff < 2592000) {
    return Math.floor(diff / 86400) + '天前'
  } else if (diff < 31536000) {
    return Math.floor(diff / 2592000) + '个月前'
  } else {
    return Math.floor(diff / 31536000) + '年前'
  }
} 