<template>
  <div class="home">
    <section class="hero">
      <h1>音乐资源分享交流论坛</h1>
      <p>发布歌曲、分享乐评、交流听歌体验</p>
      <div class="hero-actions">
        <el-button type="primary" @click="$router.push('/forum/create-post')">发布音乐分享帖</el-button>
        <el-button @click="$router.push('/forum/search')">搜索歌曲/歌手/标签</el-button>
      </div>
    </section>

    <section class="section-block">
      <h2>音乐分类</h2>
      <div class="section-grid">
        <div v-for="item in sections" :key="item.id" class="section-card" @click="$router.push(`/forum/section/${item.id}`)">
          <h3>{{ item.sectionName }}</h3>
          <p>{{ item.description }}</p>
        </div>
      </div>
    </section>

    <section class="post-block">
      <h2>最新音乐分享</h2>
      <div v-for="post in posts" :key="post.id" class="post-card" @click="$router.push(`/forum/post/${post.id}`)">
        <img v-if="post.coverUrl" :src="post.coverUrl" class="cover" />
        <div class="meta">
          <h3>{{ post.songName || post.title }}</h3>
          <p>{{ post.artist || '未知歌手' }} · {{ post.genre || '未分类' }}</p>
          <p class="tags">{{ post.tags }}</p>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import request from '@/utils/request'

const sections = ref([])
const posts = ref([])

const loadData = async () => {
  await request.get('/section/all', { status: 1 }, {
    showDefaultMsg: false,
    onSuccess: (res) => { sections.value = res || [] }
  })
  await request.get('/post/page', { status: 1, currentPage: 1, size: 10 }, {
    showDefaultMsg: false,
    onSuccess: (res) => { posts.value = res.records || [] }
  })
}

onMounted(loadData)
</script>

<style scoped>
.home { max-width: 1200px; margin: 0 auto; padding: 20px; color: #e2e8f0; }
.hero { background: linear-gradient(135deg, #1e1b4b, #0f172a); border-radius: 14px; padding: 28px; margin-bottom: 20px; }
.hero-actions { display: flex; gap: 10px; }
.section-block,.post-block { background: #111827; border-radius: 14px; padding: 20px; margin-bottom: 20px; }
.section-grid { display: grid; grid-template-columns: repeat(auto-fill,minmax(180px,1fr)); gap: 10px; }
.section-card { background: #1f2937; padding: 12px; border-radius: 10px; cursor: pointer; }
.post-card { display: flex; gap: 12px; background: #1f2937; border-radius: 10px; padding: 10px; margin-bottom: 10px; cursor: pointer; }
.cover { width: 72px; height: 72px; object-fit: cover; border-radius: 8px; }
.tags { color: #93c5fd; }
</style>
