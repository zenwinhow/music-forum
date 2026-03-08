<template>
  <div class="register-container">
    <div class="register-bg-wrapper">
      <div class="register-overlay"></div>
    </div>
    <div class="register-content">
      <div class="register-box">
        <div class="register-header">
          <div class="back-to-login">
            <el-button link type="primary" @click="$router.push('/login')">
              <el-icon><ArrowLeft /></el-icon> 返回登录
            </el-button>
          </div>
          <h1>加入师生交流论坛</h1>
          <p class="register-slogan">注册成为我们社区的一员</p>
        </div>
        
        <div class="register-form-wrapper">
          <h2>创建账号</h2>
          <p class="register-subtitle">请填写以下信息完成注册</p>
          
          <el-form ref="registerFormRef" :model="registerForm" :rules="registerRules" class="register-form">
            <el-row :gutter="20">
              <el-col :span="12">
                <el-form-item prop="username">
                  <el-input 
                    v-model="registerForm.username" 
                    placeholder="用户名" 
                    prefix-icon="User"
                  ></el-input>
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item prop="realName">
                  <el-input 
                    v-model="registerForm.realName" 
                    placeholder="真实姓名" 
                    prefix-icon="UserFilled"
                  ></el-input>
                </el-form-item>
              </el-col>
            </el-row>
            
            <el-form-item prop="email">
              <el-input 
                v-model="registerForm.email" 
                placeholder="电子邮箱" 
                prefix-icon="Message"
              ></el-input>
            </el-form-item>
            
            <el-form-item prop="phone">
              <el-input 
                v-model="registerForm.phone" 
                placeholder="手机号码" 
                prefix-icon="Phone"
              ></el-input>
            </el-form-item>
            
            <el-row :gutter="20">
              <el-col :span="12">
                <el-form-item prop="password">
                  <el-input 
                    type="password" 
                    v-model="registerForm.password" 
                    placeholder="密码" 
                    prefix-icon="Lock"
                    show-password
                  ></el-input>
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item prop="confirmPassword">
                  <el-input 
                    type="password" 
                    v-model="registerForm.confirmPassword" 
                    placeholder="确认密码" 
                    prefix-icon="Lock"
                    show-password
                  ></el-input>
                </el-form-item>
              </el-col>
            </el-row>
            
            <el-form-item prop="role" class="role-select">
              <p>您的身份：</p>
              <el-radio-group v-model="registerForm.role">
                <el-radio :label="2">教师</el-radio>
                <el-radio :label="3">学生</el-radio>
              </el-radio-group>
            </el-form-item>
            
            <el-form-item>
              <el-button 
                type="primary" 
                @click="handleSubmit" 
                :loading="loading" 
                class="register-button"
                round
              >注册账号</el-button>
            </el-form-item>
          </el-form>
          
          <div class="agreement">
            <p>点击"注册账号"按钮，即表示您同意我们的<el-button link type="primary">服务条款</el-button>和<el-button link type="primary">隐私政策</el-button></p>
          </div>
        </div>
        
        <div class="register-footer">
          <div class="features">
            <div class="feature-item">
              <el-icon><ChatDotSquare /></el-icon>
              <span>学术讨论</span>
            </div>
            <div class="feature-item">
              <el-icon><Reading /></el-icon>
              <span>知识分享</span>
            </div>
            <div class="feature-item">
              <el-icon><Connection /></el-icon>
              <span>师生互联</span>
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
  User, UserFilled, Message, Phone, Lock, 
  ArrowLeft, ChatDotSquare, Reading, Connection
} from '@element-plus/icons-vue'
import request from '@/utils/request'

const router = useRouter()
const loading = ref(false)
const registerFormRef = ref(null)

const registerForm = reactive({
  username: '',
  password: '',
  confirmPassword: '',
  realName: '',
  email: '',
  phone: '',
  role: 3 // 默认学生
})

const validatePass2 = (rule, value, callback) => {
  if (value === '') {
    callback(new Error('请再次输入密码'))
  } else if (value !== registerForm.password) {
    callback(new Error('两次输入密码不一致!'))
  } else {
    callback()
  }
}

const registerRules = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' },
    { min: 3, max: 50, message: '长度在 3 到 50 个字符', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, max: 100, message: '长度在 6 到 100 个字符', trigger: 'blur' }
  ],
  confirmPassword: [
    { required: true, validator: validatePass2, trigger: 'blur' }
  ],
  realName: [
    { required: true, message: '请输入真实姓名', trigger: 'blur' }
  ],
  email: [
    { required: true, message: '请输入邮箱', trigger: 'blur' },
    { type: 'email', message: '请输入正确的邮箱格式', trigger: 'blur' }
  ],
  phone: [
    { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号', trigger: 'blur' }
  ],
  role: [
    { required: true, message: '请选择角色', trigger: 'change' }
  ]
}

const handleSubmit = async () => {
  if (!registerFormRef.value) return
  
  try {
    await registerFormRef.value.validate()
    loading.value = true
    
    // 删除确认密码字段，后端不需要
    const registerData = { ...registerForm }
    delete registerData.confirmPassword
    
    request.post('/user/register', registerData, {
      successMsg: '注册成功，请登录',
      errorMsg: '注册失败，请检查信息后重试',
      onSuccess: () => {
        router.push('/login')
      },
      onError: (error) => {
        console.error('注册失败:', error)
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
.register-container {
  width: 100%;
  height: 100vh;
  position: relative;
  display: flex;
  justify-content: center;
  align-items: center;
  overflow: hidden;
  
  .register-bg-wrapper {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background-image: url('@/assets/bg.jpg');
    background-size: cover;
    background-position: center;
    
    .register-overlay {
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      background: linear-gradient(rgba(255, 255, 255, 0.1), rgba(145, 201, 235, 0.7));
      backdrop-filter: blur(2px);
    }
  }
  
  .register-content {
    position: relative;
    z-index: 1;
    width: 100%;
    max-width: 1000px;
    display: flex;
    justify-content: center;
    padding: 0 20px;
    
    .register-box {
      width: 600px;
      max-height: 90vh;
      overflow-y: auto;
      background-color: rgba(255, 255, 255, 0.9);
      border-radius: 12px;
      padding: 30px;
      display: flex;
      flex-direction: column;
      
      &::-webkit-scrollbar {
        width: 6px;
      }
      
      &::-webkit-scrollbar-thumb {
        background-color: rgba(0, 0, 0, 0.2);
        border-radius: 3px;
      }
      
      &::-webkit-scrollbar-track {
        background-color: rgba(0, 0, 0, 0.05);
      }
      
      .register-header {
        margin-bottom: 20px;
        
        .back-to-login {
          margin-bottom: 20px;
          
          .el-button {
            display: flex;
            align-items: center;
            font-size: 14px;
            font-weight: 500;
            color: #41b883;
            
            .el-icon {
              margin-right: 4px;
            }
          }
        }
        
        h1 {
          font-size: 32px;
          font-weight: 600;
          color: #333;
          margin-bottom: 10px;
          text-align: center;
          background: linear-gradient(to right, #b8b141, #c31919);
          -webkit-background-clip: text;
          -webkit-text-fill-color: transparent;
        }
        
        .register-slogan {
          text-align: center;
          font-size: 16px;
          color: #666;
        }
      }
      
      .register-form-wrapper {
        h2 {
          font-size: 24px;
          font-weight: 600;
          color: #333;
          margin-bottom: 8px;
        }
        
        .register-subtitle {
          color: #666;
          font-size: 14px;
          margin-bottom: 25px;
        }
        
        .register-form {
          margin-bottom: 20px;
          
          :deep(.el-form-item) {
            margin-bottom: 20px;
          }
          
          :deep(.el-input__wrapper) {
            border-radius: 8px;
          }
          
          .role-select {
            margin-top: 10px;
            
            p {
              font-size: 14px;
              color: #666;
              margin-bottom: 8px;
            }
            
            :deep(.el-radio) {
              margin-right: 15px;
            }
          }
          
          .register-button {
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
        
        .agreement {
          text-align: center;
          font-size: 12px;
          color: #666;
          margin-bottom: 20px;
          
          p {
            line-height: 1.5;
          }
          
          .el-button {
            padding: 0 4px;
            font-size: 12px;
            color: #c31919;
          }
        }
      }
      
      .register-footer {
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
              color: #41b883;
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

@media (max-width: 768px) {
  .register-container {
    .register-content {
      padding: 15px;
      
      .register-box {
        width: 100%;
        padding: 20px;
        
        .register-header {
          h1 {
            font-size: 28px;
          }
        }
        
        .register-form-wrapper {
          h2 {
            font-size: 22px;
          }
          
          .register-form {
            .el-row {
              margin-left: 0 !important;
              margin-right: 0 !important;
            }
            
            .el-col {
              padding-left: 0 !important;
              padding-right: 0 !important;
            }
            
            .register-button {
              height: 40px;
            }
          }
        }
      }
    }
  }
}
</style> 