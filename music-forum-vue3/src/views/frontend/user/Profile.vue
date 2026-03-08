<template>
  <div class="profile-page">
    <el-card>
      <h2>个人中心</h2>
      <el-form :model="form" label-width="110px">
        <el-form-item label="用户名"><el-input v-model="form.username" disabled /></el-form-item>
        <el-form-item label="真实姓名"><el-input v-model="form.realName" /></el-form-item>
        <el-form-item label="邮箱"><el-input v-model="form.email" /></el-form-item>
        <el-form-item label="个性签名"><el-input v-model="form.signature" /></el-form-item>
        <el-form-item label="个人简介"><el-input v-model="form.profile" type="textarea" :rows="3" /></el-form-item>
        <el-form-item label="音乐偏好"><el-input v-model="form.musicPreferences" type="textarea" :rows="3" placeholder="喜欢的风格/歌手/类型"/></el-form-item>
        <el-form-item>
          <el-button type="primary" @click="save">保存</el-button>
          <el-button @click="load">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <el-card style="margin-top:12px">
      <h3>我的收藏</h3>
      <div v-for="f in favorites" :key="f.id" class="fav-item" @click="$router.push(`/forum/post/${f.postId}`)">{{ f.postTitle }}</div>
      <el-empty v-if="favorites.length===0" description="暂无收藏" />
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useUserStore } from '@/store/user'
import request from '@/utils/request'

const store = useUserStore()
const form = ref({ username: '', realName: '', email: '', signature: '', profile: '', musicPreferences: '' })
const favorites = ref([])

const load = async () => {
  await request.get(`/user/${store.userId}`, null, {
    showDefaultMsg: false,
    onSuccess: (u) => {
      form.value = {
        username: u.username || '', realName: u.realName || '', email: u.email || '',
        signature: u.signature || '', profile: u.profile || '', musicPreferences: u.musicPreferences || ''
      }
    }
  })
  await request.get('/post/favorite/user', { currentPage: 1, size: 20 }, { showDefaultMsg: false, onSuccess: (r) => favorites.value = r.records || [] })
}

const save = async () => {
  await request.put(`/user/${store.userId}`, form.value, { successMsg: '保存成功' })
}

onMounted(load)
</script>

<style scoped>
.profile-page{max-width:980px;margin:0 auto;padding:20px}.fav-item{padding:8px 0;border-bottom:1px solid #eee;cursor:pointer}
</style>
