<template>
  <div class="login-container">
    <div class="login-bg-wrapper">
      <div class="login-overlay"></div>
    </div>
    <div class="left-section">
            <div class="image-wrapper">
                <img src="@/assets/04.jpg" class="background-image" />
                <div class="image-overlay">
                    <h2>共建学习社区</h2>
                    <p>促进校园师生交流</p>
                </div>
            </div>
      </div>
    <div class="login-content">
      <div class="login-box">
        <div class="login-header">
          <h1>校园论坛交流管理系统</h1>
          <p class="login-slogan">共建学习社区，促进师生交流</p>
        </div>
        <div class="login-form-wrapper">
          <h2>欢迎回来</h2>
          <p class="login-subtitle">请登录您的账号</p>
          
          <el-form ref="loginFormRef" :model="loginForm" :rules="loginRules" class="login-form">
            <el-form-item prop="username">
              <el-input 
                v-model="loginForm.username" 
                placeholder="用户名" 
                prefix-icon="User"
                size="large"
              ></el-input>
            </el-form-item>
            
            <el-form-item prop="password">
              <el-input 
                type="password" 
                v-model="loginForm.password" 
                placeholder="密码" 
                prefix-icon="Lock"
                size="large"
                show-password
              ></el-input>
            </el-form-item>
            
            <div class="role-select">
              <p>您是：</p>
              <el-radio-group v-model="loginForm.role" size="large">
                <el-radio :label="1">管理员</el-radio>
                <el-radio :label="2">教师</el-radio>
                <el-radio :label="3">学生</el-radio>
              </el-radio-group>
            </div>
            
            <el-form-item>
              <el-button 
                type="primary" 
                @click="handleLogin" 
                :loading="loading" 
                class="login-button"
                size="large"
                round
              >登录</el-button>
            </el-form-item>
          </el-form>
          
          <div class="register-link">
            <span>还没有账号？</span>
            <el-button link type="primary" @click="$router.push('/register')">立即注册</el-button>
          </div>
        </div>
        <div class="login-footer">
          <div class="features">
            <div class="feature-item">
              <el-icon><ChatDotRound /></el-icon>
              <span>在线讨论</span>
            </div>
            <div class="feature-item">
              <el-icon><Document /></el-icon>
              <span>资源共享</span>
            </div>
            <div class="feature-item">
              <el-icon><User /></el-icon>
              <span>师生互动</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { 
  User, Lock, ChatDotRound, Document 
} from '@element-plus/icons-vue'
import request from '@/utils/request'
import { useUserStore } from '@/store/user'

const router = useRouter()
const userStore = useUserStore()
const loading = ref(false)
const loginFormRef = ref(null)

const loginForm = reactive({
  username: '',
  password: '',
  role: 3 // 默认学生
})

const loginRules = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' }
  ]
}

const handleLogin = async () => {
  if (!loginFormRef.value) return
  
  try {
    await loginFormRef.value.validate()
    loading.value = true
    
    request.post('/user/login', loginForm, {
      successMsg: '登录成功',
      errorMsg: '登录失败，请检查用户名和密码',
      onSuccess: async (res) => {
        // 确保用户信息完整性
        if (!res || !res.id) {
          ElMessage.error('用户信息不完整，请联系管理员')
          return
        }
        
        // 将用户信息和token存储到store中
        userStore.setUserInfo(res)
        userStore.setToken(res.token)
        
        // 生成菜单
        try {
          userStore.generateMenusFromRoutes()
        } catch (error) {
          console.error('菜单生成失败:', error)
        }
        
        // 根据角色跳转到不同页面
        console.log('用户角色信息:', res.role, typeof res.role)
        const userRole = Number(res.role) // 确保为数字类型
        try {
          if (userRole === 1) {
            // 管理员
            console.log('管理员登录，准备跳转到控制台')
            // 使用绝对路径，而不是命名路由或相对路径
            setTimeout(() => {
              window.location.href = '/back/dashboard'
            }, 500)
          } else {
            // 教师或学生
            console.log('教师或学生登录，准备跳转到板块页面')
            router.push('/sections').catch(err => {
              console.error('路由导航失败:', err)
              router.push('/').catch(e => console.error('备用路由也失败:', e))
            })
          }
        } catch (error) {
          console.error('路由跳转过程中发生错误:', error)
          // 在导航失败时，尝试重定向到首页
          router.push('/').catch(e => console.error('无法跳转到首页:', e))
        }
      },
      onError: (error) => {
        console.error('登录失败:', error)
      }
    })
  } catch (error) {
    console.error('表单验证失败:', error)
  } finally {
    loading.value = false
  }
}
</script>

<style lang="scss" scoped>
.login-container {
  width: 100%;
  height: 100vh;
  position: relative;
  display: flex;
  justify-content: center;
  align-items: center;
  overflow: hidden;
  
  .login-bg-wrapper {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background-image: url('@/assets/bg.jpg');
    background-size: cover;
    background-position: center;
    
    .login-overlay {
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      background: linear-gradient(rgba(255, 255, 255, 0.1), rgba(255, 255, 255, 0.7));
      backdrop-filter: blur(2px);
    }
  }
  
  .left-section {
    flex: 1;
    display: flex;
    justify-content: center;
    align-items: center;
    background: none;
    padding: 20px;
}

  .image-wrapper {
      width: 420px;
      height: 540px;
      position: relative;
      display: flex;
      justify-content: center;
      align-items: center;
      background: #fff;
      border-radius: 15px;
      box-shadow: 0 8px 24px rgba(0,0,0,0.08);
      overflow: hidden;
      transition: all 0.3s ease;
  }

  .image-wrapper:hover {
      transform: translateY(-5px);
      box-shadow: 0 12px 28px rgba(0,0,0,0.12);
  }

  .background-image {
      width: 100%;
      height: 100%;
      object-fit: cover;
      transition: transform 0.3s ease;
  }

  .image-wrapper:hover .background-image {
      transform: scale(1.05);
  }

  .image-overlay {
      position: absolute;
      bottom: 0;
      left: 0;
      right: 0;
      padding: 20px;
      background: linear-gradient(to top, rgba(0,0,0,0.7), transparent);
      color: white;
      text-align: center;
  }

  .image-overlay h2 {
      margin: 0;
      font-size: 24px;
      font-weight: 600;
  }

  .image-overlay p {
      margin: 5px 0 0;
      font-size: 16px;
      opacity: 0.9;
  }

  .right-section {
      flex: 1;
      display: flex;
      justify-content: center;
      align-items: center;
      background: none;
      padding: 20px;
  }

  .login-content {
    position: relative;
    z-index: 1;
    width: 100%;
    max-width: 1000px;
    display: flex;
    justify-content: center;
    padding: 0 20px;
    
    .login-box {
      width: 420px;
      background-color: rgba(255, 255, 255, 0.9);
      border-radius: 12px;
      padding: 30px;
      display: flex;
      flex-direction: column;
      
      .login-header {
        text-align: center;
        margin-bottom: 30px;
        
        h1 {
          font-size: 32px;
          font-weight: 600;
          color: #333;
          margin-bottom: 10px;
          background: linear-gradient(to right, #b8b141, #c31919);
          -webkit-background-clip: text;
          -webkit-text-fill-color: transparent;
        }
        
        .login-slogan {
          font-size: 16px;
          color: #666;
        }
      }
      
      .login-form-wrapper {
        h2 {
          font-size: 24px;
          font-weight: 600;
          color: #333;
          margin-bottom: 8px;
        }
        
        .login-subtitle {
          color: #666;
          font-size: 14px;
          margin-bottom: 25px;
        }
        
        .login-form {
          margin-bottom: 20px;
          
          :deep(.el-form-item) {
            margin-bottom: 20px;
          }
          
          :deep(.el-input__wrapper) {
            border-radius: 8px;
          }
          
          .role-select {
            margin-bottom: 20px;
            
            p {
              font-size: 14px;
              color: #666;
              margin-bottom: 8px;
            }
            
            :deep(.el-radio) {
              margin-right: 15px;
            }
          }
          
          .login-button {
            width: 100%;
            height: 44px;
            font-size: 16px;
            background: linear-gradient(90deg, #b8b141, #c31919);
            border: none;
            transition: all 0.3s;
            
            &:hover {
              transform: translateY(-2px);
              opacity: 0.9;
            }
          }
        }
        
        .register-link {
          text-align: center;
          font-size: 14px;
          color: #666;
          margin-bottom: 20px;
          
          .el-button {
            font-weight: 600;
            padding: 4px;
          }
        }
      }
      
      .login-footer {
        margin-top: auto;
        
        .features {
          display: flex;
          justify-content: space-between;
          
          .feature-item {
            display: flex;
            align-items: center;
            flex-direction: column;
            padding: 10px;
            
            .el-icon {
              font-size: 22px;
              color: #c31919;
              margin-bottom: 8px;
            }
            
            span {
              font-size: 14px;
              color: #666;
            }
          }
        }
      }
    }
  }
}

@media (max-width: 576px) {
  .login-container {
    .login-content {
      padding: 15px;
      
      .login-box {
        width: 100%;
        padding: 20px;
        
        .login-header {
          margin-bottom: 20px;
          
          h1 {
            font-size: 28px;
          }
        }
        
        .login-form-wrapper {
          h2 {
            font-size: 22px;
          }
          
          .login-form {
            .login-button {
              height: 40px;
            }
          }
        }
      }
    }
  }
}
</style> 