<template>
  <div class="login-container">
    <div class="left-panel">
      <img src="@/assets/04.jpg" class="cover-image" />
      <div class="cover-mask">
        <h2>音乐分享社区</h2>
        <p>发现好歌，分享感受，交流讨论</p>
      </div>
    </div>
    <div class="right-panel">
      <div class="login-box">
        <div class="login-header">
          <h1>音乐资源分享论坛</h1>
          <p>登录后继续使用</p>
        </div>

        <el-form ref="loginFormRef" :model="loginForm" :rules="loginRules" class="login-form">
          <el-form-item prop="username">
            <el-input v-model="loginForm.username" placeholder="请输入用户名" prefix-icon="User" size="large" />
          </el-form-item>

          <el-form-item prop="password">
            <el-input
              type="password"
              v-model="loginForm.password"
              placeholder="请输入密码"
              prefix-icon="Lock"
              size="large"
              show-password
            />
          </el-form-item>

          <div class="role-select">
            <p>登录身份</p>
            <el-radio-group v-model="loginForm.role" size="large">
              <el-radio :label="1">管理员</el-radio>
              <el-radio :label="2">用户</el-radio>
            </el-radio-group>
          </div>

          <el-form-item>
            <el-button type="primary" @click="handleLogin" :loading="loading" class="login-button" size="large" round>
              登录
            </el-button>
          </el-form-item>
          <el-form-item>
            <el-button plain @click="handleGuestEnter" class="guest-button" size="large" round>
              游客直接进入首页
            </el-button>
          </el-form-item>
        </el-form>

        <div class="register-link">
          <span>还没有账号？</span>
          <el-button link type="primary" @click="$router.push('/register')">立即注册</el-button>
        </div>

        <div class="login-footer">
          <div class="feature-item">
            <el-icon><ChatDotRound /></el-icon>
            <span>音乐讨论</span>
          </div>
          <div class="feature-item">
            <el-icon><Document /></el-icon>
            <span>资源分享</span>
          </div>
          <div class="feature-item">
            <el-icon><User /></el-icon>
            <span>乐迷交流</span>
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
import { User, Lock, ChatDotRound, Document } from '@element-plus/icons-vue'
import request from '@/utils/request'
import { useUserStore } from '@/store/user'

const router = useRouter()
const userStore = useUserStore()
const loading = ref(false)
const loginFormRef = ref(null)

const loginForm = reactive({
  username: '',
  password: '',
  role: 2
})

const loginRules = {
  username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }]
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
        if (!res || !res.id) {
          ElMessage.error('用户信息异常，请联系管理员')
          return
        }

        userStore.setUserInfo(res)
        userStore.setToken(res.token)

        try {
          userStore.generateMenusFromRoutes()
        } catch (error) {
          console.error('Menu generation failed:', error)
        }

        const userRole = Number(res.role)
        try {
          if (userRole === 1) {
            setTimeout(() => {
              window.location.href = '/back/dashboard'
            }, 500)
          } else {
            router.push('/sections').catch((err) => {
              console.error('Router navigation failed:', err)
              router.push('/').catch((e) => console.error('Fallback route failed:', e))
            })
          }
        } catch (error) {
          console.error('Router jump failed:', error)
          router.push('/').catch((e) => console.error('Unable to route to home:', e))
        }
      },
      onError: (error) => {
        console.error('Login failed:', error)
      }
    })
  } catch (error) {
    console.error('Form validation failed:', error)
  } finally {
    loading.value = false
  }
}

const handleGuestEnter = () => {
  router.push('/home').catch((error) => {
    console.error('Guest entry failed:', error)
  })
}
</script>

<style lang="scss" scoped>
.login-container {
  display: flex;
  height: 100vh;
  background: linear-gradient(135deg, #0f172a, #1e1b4b);
}

.left-panel {
  width: 46%;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 24px;

  .cover-image {
    width: 100%;
    max-width: 540px;
    height: 76vh;
    object-fit: cover;
    border-radius: 16px;
    box-shadow: 0 20px 40px rgba(0, 0, 0, 0.3);
  }

  .cover-mask {
    position: absolute;
    color: #fff;
    text-align: center;
  }
}

.right-panel {
  width: 54%;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 20px;

  .login-box {
    width: 430px;
    background: #fff;
    border-radius: 14px;
    padding: 28px;
    box-shadow: 0 16px 36px rgba(0, 0, 0, 0.2);
  }

  .login-header {
    text-align: center;
    margin-bottom: 20px;

    h1 {
      font-size: 30px;
      color: #312e81;
      margin-bottom: 8px;
    }

    p {
      color: #6b7280;
    }
  }

  .role-select {
    margin-bottom: 18px;

    p {
      margin-bottom: 8px;
      color: #6b7280;
    }
  }

  .login-button {
    width: 100%;
    background: linear-gradient(90deg, #4338ca, #2563eb);
    border: none;
  }

  .guest-button {
    width: 100%;
  }

  .register-link {
    text-align: center;
    color: #6b7280;
    margin: 8px 0 16px;
  }

  .login-footer {
    display: flex;
    justify-content: space-between;
    gap: 8px;

    .feature-item {
      display: flex;
      flex-direction: column;
      align-items: center;
      font-size: 12px;
      color: #6b7280;

      .el-icon {
        font-size: 18px;
        color: #2563eb;
        margin-bottom: 4px;
      }
    }
  }
}

@media (max-width: 900px) {
  .left-panel {
    display: none;
  }

  .right-panel {
    width: 100%;
  }
}
</style>
