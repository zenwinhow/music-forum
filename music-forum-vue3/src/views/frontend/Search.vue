<template>
  <div class="search-page">
    <el-card>
      <el-form :inline="true">
        <el-form-item><el-input v-model="form.keyword" placeholder="关键词(标题/歌曲名/歌手/标签)" @keyup.enter="search" /></el-form-item>
        <el-form-item><el-input v-model="form.songName" placeholder="歌曲名" /></el-form-item>
        <el-form-item><el-input v-model="form.artist" placeholder="歌手" /></el-form-item>
        <el-form-item><el-input v-model="form.tags" placeholder="标签" /></el-form-item>
        <el-form-item>
          <el-select v-model="form.sectionId" clearable placeholder="分类" style="width:180px">
            <el-option v-for="s in sections" :key="s.id" :label="s.sectionName" :value="s.id" />
          </el-select>
        </el-form-item>
        <el-form-item><el-button type="primary" @click="search">搜索</el-button></el-form-item>
      </el-form>
    </el-card>

    <el-card style="margin-top:12px">
      <div v-for="p in posts" :key="p.id" class="item" @click="$router.push(`/forum/post/${p.id}`)">
        <img v-if="p.coverUrl" :src="p.coverUrl" class="cover" />
        <div>
          <h3>{{ p.songName || p.title }}</h3>
          <p>{{ p.artist }} · {{ p.genre }} · {{ p.tags }}</p>
        </div>
      </div>
      <el-empty v-if="posts.length===0" description="暂无结果" />
      <el-pagination :current-page="currentPage" :page-size="size" :total="total" @current-change="onPage" layout="prev, pager, next" />
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import request from '@/utils/request'

const route = useRoute()
const form = ref({ keyword: route.query.keyword || '', songName: '', artist: '', tags: '', sectionId: null })
const sections = ref([])
const posts = ref([])
const currentPage = ref(1)
const size = ref(10)
const total = ref(0)

const loadSections = async () => {
  await request.get('/section/all', { status: 1 }, { showDefaultMsg: false, onSuccess: (res) => sections.value = res || [] })
}

const search = async () => {
  await request.get('/post/page', {
    title: form.value.keyword,
    songName: form.value.songName,
    artist: form.value.artist,
    tags: form.value.tags,
    sectionId: form.value.sectionId,
    status: 1,
    currentPage: currentPage.value,
    size: size.value
  }, {
    showDefaultMsg: false,
    onSuccess: (res) => { posts.value = res.records || []; total.value = res.total || 0 }
  })
}

const onPage = (p) => { currentPage.value = p; search() }

onMounted(() => { loadSections(); search() })
</script>

<style scoped>
.search-page{max-width:1100px;margin:0 auto;padding:20px}.item{display:flex;gap:10px;padding:10px 0;border-bottom:1px solid #eee;cursor:pointer}.cover{width:60px;height:60px;border-radius:8px;object-fit:cover}
</style>
