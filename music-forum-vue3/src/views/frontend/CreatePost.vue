<template>
  <div class="create-post-container">
    <div class="page-header">
      <h1>发表帖子</h1>
      <p>当前版块: {{ sectionName }}</p>
    </div>
    
    <el-card class="post-form-card">
      <el-form 
        :model="postForm" 
        :rules="postRules" 
        ref="postFormRef" 
        label-width="80px"
        @submit.prevent
      >
        <el-form-item label="标题" prop="title">
          <el-input 
            v-model="postForm.title" 
            placeholder="请输入帖子标题" 
            maxlength="50" 
            show-word-limit
          ></el-input>
        </el-form-item>
        
        <el-form-item label="内容" prop="content">
          <div class="editor-container">
            <div style="border: 1px solid #ccc">
              <div ref="toolbarRef" class="toolbar-container"></div>
              <div ref="editorRef" class="editor-content"></div>
            </div>
          </div>
        </el-form-item>
        
        <el-form-item>
          <el-button type="primary" @click="submitPost" :loading="submitting">发表帖子</el-button>
          <el-button @click="cancelPost">取消</el-button>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script setup>
import { ref, shallowRef, onBeforeUnmount, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import request from '@/utils/request'
import { useUserStore } from '@/store/user'

// 引入 wangEditor
import '@wangeditor/editor/dist/css/style.css'
import { createEditor, createToolbar } from '@wangeditor/editor'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()

// 编辑器相关的 ref
const toolbarRef = ref(null)
const editorRef = ref(null)
const editor = shallowRef(null)

// 内容 HTML
const postForm = ref({
  title: '',
  content: '',
  sectionId: Number(route.query.sectionId) || 0
})

// 获取版块ID和名称
const sectionId = ref(Number(route.query.sectionId) || 0)
const sectionName = ref(route.query.sectionName || '未知版块')

const postFormRef = ref(null)
const submitting = ref(false)

// 表单验证规则
const postRules = {
  title: [
    { required: true, message: '请输入帖子标题', trigger: 'blur' },
    { min: 2, max: 50, message: '标题长度应为2-50个字符', trigger: 'blur' }
  ],
  content: [
    { required: true, message: '请输入帖子内容', trigger: 'blur' },
    { min: 10, message: '内容长度至少10个字符', trigger: 'blur' }
  ]
}

// 初始化编辑器
const initEditor = () => {
  // 编辑器配置
  const editorConfig = {
    placeholder: '请输入内容...',
    onChange(editor) {
      postForm.value.content = editor.getHtml()
    },
    MENU_CONF: {
      uploadImage: {
        // 关闭服务器上传，使用 base64 插入图片
        // 不再使用服务器上传
        server: '', // 设置为空，表示不上传到服务器
        
        // 使用 base64 格式插入图片
        base64LimitSize: 10 * 1024 * 1024, // 10MB以内的图片转为base64
        
        // 选择文件时的类型限制
        allowedFileTypes: ['image/*'],
        
        // 自定义处理图片插入，直接将图片转为base64并插入
        customInsert(res, insertFn) {
          // 对于转为base64的图片，res就是base64字符串
          console.log('插入base64图片')
          insertFn(res)
          ElMessage.success('图片已插入到文本中')
        },
        
        // 上传进度的回调函数
        onProgress(progress) {
          console.log('图片处理进度', progress)
        },
        
        // 单个文件上传失败
        onFailed(file, res) {
          console.log('图片处理失败', file, res)
          ElMessage.error('图片处理失败：' + (res ? res.msg : '未知错误'))
        },
        
        // 上传错误，或者触发限制等
        onError(file, err, res) {
          console.log('图片处理出错', file, err, res)
          ElMessage.error('图片处理错误：' + (err ? err.message : '未知错误'))
        },
      }
    }
  }

  // 工具栏配置
  const toolbarConfig = {
    toolbarKeys: [
      'bold',
      'italic',
      'underline',
      '|',
      'color',
      'bgColor',
      '|',
      'fontSize',
      'fontFamily',
      '|',
      'bulletedList',
      'numberedList',
      '|',
      'justifyLeft',
      'justifyCenter',
      'justifyRight',
      '|',
      'uploadImage',
      'insertTable',
      '|',
      'undo',
      'redo',
      '|',
      'fullScreen'
    ]
  }

  // 创建编辑器
  editor.value = createEditor({
    selector: editorRef.value,
    html: postForm.value.content,
    config: editorConfig,
    mode: 'default'
  })

  // 创建工具栏
  const toolbar = createToolbar({
    editor: editor.value,
    selector: toolbarRef.value,
    config: toolbarConfig,
    mode: 'default'
  })
  
  // 添加日志观察编辑器状态
  console.log('编辑器和工具栏已创建', editor.value)
}

// 检查登录状态
const checkLoginStatus = () => {
  if (!userStore.isLoggedIn) {
    ElMessage.warning('请先登录')
    router.push('/login')
    return false
  }
  return true
}

// 检查版块ID
const checkSectionId = () => {
  if (!sectionId.value) {
    ElMessage.warning('未指定版块，请返回选择版块')
    return false
  }
  return true
}

// 提交帖子
const submitPost = async () => {
  // 检查登录状态和版块ID
  if (!checkLoginStatus() || !checkSectionId()) return
  
  // 表单验证
  if (!postFormRef.value) return
  
  await postFormRef.value.validate(async (valid) => {
    if (!valid) return
    
    // 检查内容长度
    if (postForm.value.content.length < 10) {
      ElMessage.warning('内容太短，请至少输入10个字符')
      return
    }
    
    submitting.value = true
    try {
      const postData = {
        title: postForm.value.title,
        content: postForm.value.content,
        sectionId: sectionId.value
      }
      
      await request.post('/post/add', postData, {
        successMsg: '帖子发表成功',
        onSuccess: () => {
          // 跳转到版块详情页
          router.push(`/forum/section/${sectionId.value}`)
        },
        onError: (error) => {
          console.error('发表帖子失败:', error)
          ElMessage.error('发表帖子失败: ' + (error?.message || '未知错误'))
        }
      })
    } catch (error) {
      console.error('发表帖子失败:', error)
      ElMessage.error('发表帖子失败: ' + (error?.message || '未知错误'))
    } finally {
      submitting.value = false
    }
  })
}

// 取消发布
const cancelPost = () => {
  ElMessageBox.confirm('确定要取消发布吗？已编辑的内容将丢失！', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    router.go(-1)
  }).catch(() => {})
}

// 组件挂载时初始化编辑器
onMounted(() => {
  checkLoginStatus()
  checkSectionId()
  initEditor()
  
  // 监听编辑器上传图片的事件
  if (editor.value) {
    console.log('编辑器已初始化')
  }
})

// 组件销毁时销毁编辑器
onBeforeUnmount(() => {
  if (editor.value) {
    editor.value.destroy()
  }
})
</script>

<style scoped>
.create-post-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
}

.page-header {
  margin-bottom: 20px;
}

.page-header h1 {
  font-size: 24px;
  margin: 0 0 10px;
}

.page-header p {
  color: #606266;
  font-size: 14px;
  margin: 0;
}

.post-form-card {
  margin-bottom: 20px;
}

.editor-container {
  width: 100%;
  margin-bottom: 20px;
}

.toolbar-container {
  border-bottom: 1px solid #ccc;
}

.editor-content {
  height: 500px;
  overflow-y: auto;
}

:deep(.w-e-text-container) {
  height: 500px !important;
}
</style> 