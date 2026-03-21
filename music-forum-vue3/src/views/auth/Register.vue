<template>
  <div class="register-container">
    <div class="register-box">
      <div class="header">
        <h1>注册账号</h1>
        <p>音乐资源分享论坛</p>
      </div>
      <el-form ref="registerFormRef" :model="registerForm" :rules="registerRules">
        <el-form-item prop="username">
          <el-input v-model="registerForm.username" placeholder="请输入用户名" />
        </el-form-item>
        <el-form-item prop="realName">
          <el-input v-model="registerForm.realName" placeholder="请输入昵称" />
        </el-form-item>
        <el-form-item prop="email">
          <el-input v-model="registerForm.email" placeholder="请输入邮箱" />
        </el-form-item>
        <el-form-item prop="phone">
          <el-input v-model="registerForm.phone" placeholder="请输入手机号（可选）" />
        </el-form-item>
        <el-form-item prop="password">
          <el-input v-model="registerForm.password" type="password" show-password placeholder="请输入密码" />
        </el-form-item>
        <el-form-item prop="confirmPassword">
          <el-input v-model="registerForm.confirmPassword" type="password" show-password placeholder="请确认密码" />
        </el-form-item>
        <el-form-item prop="role">
          <el-radio-group v-model="registerForm.role">
            <el-radio :label="2">用户</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item>
          <el-button class="w-full" type="primary" @click="handleSubmit" :loading="loading">注册</el-button>
        </el-form-item>
        <el-form-item>
          <el-button link @click="$router.push('/login')">返回登录</el-button>
        </el-form-item>
      </el-form>
    </div>
  </div>
</template>

<script setup>
import { reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
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
  role: 2
})

const validatePass2 = (rule, value, callback) => {
  if (!value) callback(new Error('请确认密码'))
  else if (value !== registerForm.password) callback(new Error('两次输入密码不一致'))
  else callback()
}

const registerRules = {
  username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }],
  confirmPassword: [{ required: true, validator: validatePass2, trigger: 'blur' }],
  realName: [{ required: true, message: '请输入昵称', trigger: 'blur' }],
  email: [{ required: true, message: '请输入邮箱', trigger: 'blur' }],
  role: [{ required: true, message: '请选择角色', trigger: 'change' }]
}

const handleSubmit = async () => {
  if (!registerFormRef.value) return
  try {
    await registerFormRef.value.validate()
    loading.value = true
    const payload = { ...registerForm }
    delete payload.confirmPassword
    request.post('/user/register', payload, {
      successMsg: '注册成功',
      errorMsg: '注册失败',
      onSuccess: () => router.push('/login')
    })
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.register-container {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #0f172a, #1e1b4b);
}
.register-box {
  width: 420px;
  background: #fff;
  border-radius: 12px;
  padding: 24px;
}
.header {
  text-align: center;
  margin-bottom: 16px;
}
.w-full {
  width: 100%;
}
</style>
