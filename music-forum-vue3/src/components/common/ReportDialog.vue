<template>
  <el-dialog
    v-model="dialogVisible"
    :title="getDialogTitle()"
    width="500px"
  >
    <el-form
      ref="reportFormRef"
      :model="reportForm"
      :rules="reportFormRules"
      label-width="80px"
    >
      <el-form-item label="举报类型" prop="type">
        <el-select v-model="reportForm.type" placeholder="请选择举报类型" disabled>
          <el-option :value="1" label="帖子" />
          <el-option :value="2" label="评论" />
          <el-option :value="3" label="资源" />
        </el-select>
      </el-form-item>
      <el-form-item label="举报原因" prop="reason">
        <el-input
          v-model="reportForm.reason"
          type="textarea"
          :rows="4"
          placeholder="请详细描述举报原因，至少10个字符"
        ></el-input>
      </el-form-item>
    </el-form>
    <template #footer>
      <span class="dialog-footer">
        <el-button @click="handleCancel">取消</el-button>
        <el-button type="primary" @click="handleSubmit" :loading="submitLoading">提交举报</el-button>
      </span>
    </template>
  </el-dialog>
</template>

<script setup>
import { ref, reactive, defineProps, defineEmits, watch } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import request from '@/utils/request'

const props = defineProps({
  visible: {
    type: Boolean,
    required: true
  },
  type: {
    type: Number,
    required: true,
    validator: (value) => [1, 2, 3].includes(value)
  },
  targetId: {
    type: Number,
    required: true
  },
  title: {
    type: String,
    default: ''
  }
})

const emit = defineEmits(['update:visible', 'success'])

// 对话框显示状态
const dialogVisible = ref(props.visible)

// 监听 props.visible 和 dialogVisible 的变化
watch(() => props.visible, (newVal) => {
  dialogVisible.value = newVal
  if (newVal && reportFormRef.value) {
    // 每次打开对话框时重置表单
    reportForm.reason = ''
    reportFormRef.value.resetFields()
  }
})

watch(dialogVisible, (newVal) => {
  emit('update:visible', newVal)
})

// 举报表单
const reportFormRef = ref(null)
const submitLoading = ref(false)
const reportForm = reactive({
  type: props.type,
  targetId: props.targetId,
  reason: ''
})

// 监听 props 的变化，更新表单数据
watch(() => props.type, (newVal) => {
  reportForm.type = newVal
})

watch(() => props.targetId, (newVal) => {
  reportForm.targetId = newVal
})

// 表单验证规则
const reportFormRules = {
  reason: [
    { required: true, message: '请输入举报原因', trigger: 'blur' },
    { min: 10, max: 500, message: '举报原因长度应在10到500个字符之间', trigger: 'blur' }
  ]
}

// 获取对话框标题
const getDialogTitle = () => {
  if (props.title) return `举报 ${props.title}`
  
  const typeMap = {
    1: '帖子',
    2: '评论',
    3: '资源'
  }
  return `举报${typeMap[props.type]}`
}

// 取消举报
const handleCancel = () => {
  dialogVisible.value = false
  // 重置表单
  if (reportFormRef.value) {
    reportFormRef.value.resetFields()
  }
}

// 提交举报
const handleSubmit = async () => {
  if (!reportFormRef.value) return
  
  try {
    await reportFormRef.value.validate()
    
    submitLoading.value = true
    try {
      const response = await request.post('/report/add', reportForm, {
        successMsg: '举报提交成功',
        onSuccess: () => {
          dialogVisible.value = false
          emit('success')
          // 重置表单
          if (reportFormRef.value) {
            reportFormRef.value.resetFields()
          }
        }
      })
    } catch (error) {
      console.error('提交举报失败:', error)
      ElMessage.error('提交举报失败')
    } finally {
      submitLoading.value = false
    }
  } catch (error) {
    console.error('表单验证失败:', error)
  }
}
</script>

<style lang="scss" scoped>
.dialog-footer {
  display: flex;
  justify-content: flex-end;
  margin-top: 20px;
}
</style> 