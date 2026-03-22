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
.home {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
  color: #303133;
}

.hero {
  background: linear-gradient(90deg, #b784d7, #c89ae4);
  border-radius: 16px;
  padding: 32px;
  margin-bottom: 24px;
  color: #fff;
  box-shadow: 0 10px 30px rgba(183, 132, 215, 0.22);
}

.hero h1 {
  margin: 0 0 12px;
  font-size: 30px;
  font-weight: 700;
}

.hero p {
  margin: 0;
  max-width: 520px;
  color: rgba(255, 255, 255, 0.92);
  line-height: 1.7;
}

.hero-actions {
  display: flex;
  gap: 12px;
  margin-top: 24px;
  flex-wrap: wrap;
}

.section-block,
.post-block {
  background: #fff;
  border-radius: 16px;
  padding: 24px;
  margin-bottom: 24px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
}

.section-block h2,
.post-block h2 {
  margin: 0 0 18px;
  font-size: 22px;
  color: #303133;
}

.section-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
  gap: 16px;
}

.section-card {
  padding: 18px 16px;
  border-radius: 14px;
  cursor: pointer;
  background: linear-gradient(135deg, #f8f4fc, #eef4ff);
  border: 1px solid #ebe5f5;
  transition: all 0.3s ease;
}

.section-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 12px 24px rgba(142, 68, 173, 0.12);
  border-color: #d8c2e8;
}

.section-card h3 {
  margin: 0 0 8px;
  color: #303133;
  font-size: 17px;
}

.section-card p {
  margin: 0;
  color: #606266;
  line-height: 1.6;
}

.post-card {
  display: flex;
  gap: 14px;
  background: #f9fafc;
  border: 1px solid #ebeef5;
  border-radius: 14px;
  padding: 14px;
  margin-bottom: 12px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.post-card:hover {
  transform: translateY(-3px);
  box-shadow: 0 12px 24px rgba(64, 75, 96, 0.1);
  border-color: #d9c7e8;
}

.cover {
  width: 72px;
  height: 72px;
  object-fit: cover;
  border-radius: 10px;
  flex-shrink: 0;
}

.meta h3 {
  margin: 2px 0 8px;
  color: #303133;
  font-size: 18px;
}

.meta p {
  margin: 0 0 6px;
  color: #606266;
}

.tags {
  color: #8e44ad;
}

@media (max-width: 768px) {
  .home {
    padding: 12px;
  }

  .hero,
  .section-block,
  .post-block {
    padding: 20px;
  }

  .hero h1 {
    font-size: 24px;
  }

  .post-card {
    align-items: flex-start;
  }
}
</style>
