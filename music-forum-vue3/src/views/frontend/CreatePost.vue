<template>
  <div class="create-post-container">
    <h2>发布音乐分享帖</h2>
    <el-form :model="postForm" :rules="postRules" ref="postFormRef" label-width="100px">
      <el-form-item label="音乐分类" prop="sectionId">
        <el-select v-model="postForm.sectionId" style="width: 100%">
          <el-option v-for="s in sections" :key="s.id" :label="s.sectionName" :value="s.id" />
        </el-select>
      </el-form-item>
      <el-form-item label="帖子标题" prop="title"><el-input v-model="postForm.title" /></el-form-item>
      <el-form-item label="歌曲名" prop="songName"><el-input v-model="postForm.songName" /></el-form-item>
      <el-form-item label="歌手" prop="artist"><el-input v-model="postForm.artist" /></el-form-item>
      <el-form-item label="专辑"><el-input v-model="postForm.album" /></el-form-item>
      <el-form-item label="流派"><el-input v-model="postForm.genre" placeholder="如：流行/摇滚" /></el-form-item>
      <el-form-item label="标签"><el-input v-model="postForm.tags" placeholder="逗号分隔" /></el-form-item>
      <el-form-item label="封面URL"><el-input v-model="postForm.coverUrl" /></el-form-item>
      <el-form-item label="音乐外链"><el-input v-model="postForm.musicUrl" /></el-form-item>
      <el-form-item label="推荐理由" prop="content"><el-input type="textarea" :rows="8" v-model="postForm.content" /></el-form-item>
      <el-form-item>
        <el-button type="primary" @click="submitPost" :loading="submitting">发布</el-button>
        <el-button @click="$router.back()">取消</el-button>
      </el-form-item>
    </el-form>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import request from '@/utils/request'

const router = useRouter()
const route = useRoute()
const postFormRef = ref()
const sections = ref([])
const submitting = ref(false)

const postForm = ref({
  sectionId: Number(route.query.sectionId) || null,
  title: '',
  content: '',
  songName: '',
  artist: '',
  album: '',
  genre: '',
  tags: '',
  coverUrl: '',
  musicUrl: ''
})

const postRules = {
  sectionId: [{ required: true, message: '请选择分类', trigger: 'change' }],
  title: [{ required: true, message: '请输入标题', trigger: 'blur' }],
  songName: [{ required: true, message: '请输入歌曲名', trigger: 'blur' }],
  artist: [{ required: true, message: '请输入歌手', trigger: 'blur' }],
  content: [{ required: true, message: '请输入正文', trigger: 'blur' }]
}

const loadSections = async () => {
  await request.get('/section/all', { status: 1 }, {
    showDefaultMsg: false,
    onSuccess: (res) => { sections.value = res || [] }
  })
}

const submitPost = async () => {
  await postFormRef.value.validate(async (valid) => {
    if (!valid) return
    submitting.value = true
    await request.post('/post/add', postForm.value, {
      successMsg: '发布成功',
      onSuccess: () => router.push(`/forum/section/${postForm.value.sectionId}`),
      onError: () => ElMessage.error('发布失败')
    })
    submitting.value = false
  })
}

onMounted(loadSections)
</script>

<style scoped>
.create-post-container{max-width:900px;margin:0 auto;padding:20px;background:#111827;color:#e5e7eb;border-radius:12px}
</style>
