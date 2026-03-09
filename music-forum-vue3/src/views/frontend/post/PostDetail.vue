<template>
  <div class="post-detail-container">
    <el-card class="post-card">
      <h1>{{ post.songName || post.title }}</h1>
      <p class="sub">{{ post.artist }} · {{ post.album || '单曲' }} · {{ post.genre || '未分类' }}</p>
      <img v-if="post.coverUrl" :src="post.coverUrl" class="cover" />
      <p v-if="post.tags" class="tags">标签：{{ post.tags }}</p>
      <el-button v-if="post.musicUrl" type="primary" @click="openMusic">试听/跳转链接</el-button>
      <div class="content" v-html="post.content"></div>
      <div class="actions">
        <el-button :icon="post.isFavorited ? StarFilled : Star" @click="handleFavorite">{{ post.isFavorited ? '已收藏' : '收藏这首歌/这篇分享' }}</el-button>
        <el-button type="danger" plain @click="handleReport">举报</el-button>
      </div>
    </el-card>

    <el-card>
      <h3>发表评论</h3>
      <el-input v-model="commentContent" type="textarea" :rows="3" />
      <el-button type="primary" @click="submitComment" :loading="submitting" style="margin-top:10px">发表评论</el-button>
      <div v-for="c in comments" :key="c.id" class="comment-item">{{ c.userName || c.username }}：{{ c.content }}</div>
    </el-card>

    <report-dialog
      v-model:visible="reportDialogVisible"
      :type="1"
      :target-id="Number(route.params.id)"
      :title="post.songName || post.title || '该帖子'"
      @success="onReportSuccess"
    />
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { Star, StarFilled } from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'
import request from '@/utils/request'
import ReportDialog from '@/components/common/ReportDialog.vue'

const route = useRoute()
const post = ref({})
const comments = ref([])
const commentContent = ref('')
const submitting = ref(false)
const reportDialogVisible = ref(false)

const fetchPost = async () => {
  await request.get(`/post/${route.params.id}`, null, {
    showDefaultMsg: false,
    onSuccess: (res) => { post.value = res || {} }
  })
  await request.put(`/post/${route.params.id}/view`, null, { showDefaultMsg: false })
}

const fetchComments = async () => {
  await request.get(`/comment/tree/${route.params.id}`, null, {
    showDefaultMsg: false,
    onSuccess: (res) => { comments.value = res || [] }
  })
}

const submitComment = async () => {
  if (!commentContent.value.trim()) return
  submitting.value = true
  await request.post('/comment/add', { postId: Number(route.params.id), content: commentContent.value, parentId: null }, {
    successMsg: '评论成功',
    onSuccess: () => { commentContent.value = ''; fetchComments() }
  })
  submitting.value = false
}

const handleFavorite = async () => {
  await request.post(`/post/favorite/${route.params.id}`, null, {
    showDefaultMsg: false,
    onSuccess: (res) => { post.value.isFavorited = res }
  })
}

const openMusic = () => {
  if (post.value.musicUrl) window.open(post.value.musicUrl, '_blank')
  else ElMessage.warning('暂无音乐链接')
}

const handleReport = () => {
  reportDialogVisible.value = true
}

const onReportSuccess = () => {
  ElMessage.success('举报提交成功')
}

onMounted(() => {
  fetchPost()
  fetchComments()
})
</script>

<style scoped>
.post-detail-container{max-width:1000px;margin:0 auto;padding:20px}
.sub{color:#64748b}.cover{width:180px;height:180px;object-fit:cover;border-radius:10px}.tags{color:#2563eb}.content{margin-top:16px}
.comment-item{padding:10px 0;border-bottom:1px solid #e5e7eb}
</style>
