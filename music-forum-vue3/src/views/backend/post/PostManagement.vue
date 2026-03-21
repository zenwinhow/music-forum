<template>
  <div class="post-management">
    <el-card>
      <el-form :inline="true" :model="searchForm">
        <el-form-item label="关键词"><el-input v-model="searchForm.title" placeholder="标题/歌曲名/歌手/标签" /></el-form-item>
        <el-form-item label="分类">
          <el-select v-model="searchForm.sectionId" clearable style="width:160px">
            <el-option v-for="s in sections" :key="s.id" :label="s.sectionName" :value="s.id" />
          </el-select>
        </el-form-item>
        <el-form-item><el-button type="primary" @click="load">搜索</el-button></el-form-item>
      </el-form>
    </el-card>

    <el-card style="margin-top:12px">
      <el-table :data="tableData" v-loading="loading" border>
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="songName" label="歌曲名" min-width="140" />
        <el-table-column prop="artist" label="歌手" width="120" />
        <el-table-column prop="genre" label="流派" width="100" />
        <el-table-column prop="tags" label="标签" min-width="140" />
        <el-table-column prop="title" label="帖子标题" min-width="200" />
        <el-table-column label="状态" width="100">
          <template #default="{row}"><el-switch v-model="row.status" :active-value="1" :inactive-value="0" @change="v=>changeStatus(row.id,v)"/></template>
        </el-table-column>
      </el-table>
      <el-pagination :current-page="currentPage" :page-size="size" :total="total" @current-change="p=>{currentPage=p;load()}" layout="total, prev, pager, next" />
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import request from '@/utils/request'

const searchForm = reactive({ title: '', sectionId: null })
const sections = ref([])
const tableData = ref([])
const loading = ref(false)
const currentPage = ref(1)
const size = ref(10)
const total = ref(0)

const loadSections = async () => {
  await request.get('/section/all', { status: -1 }, { showDefaultMsg: false, onSuccess: r => sections.value = r || [] })
}

const load = async () => {
  loading.value = true
  await request.get('/post/page', { ...searchForm, currentPage: currentPage.value, size: size.value }, {
    showDefaultMsg: false,
    onSuccess: (r) => { tableData.value = r.records || []; total.value = r.total || 0 }
  })
  loading.value = false
}

const changeStatus = async (id, status) => {
  await request.put(`/post/${id}/status?status=${status}`, null, { showDefaultMsg: false })
}

onMounted(() => { loadSections(); load() })
</script>

<style scoped>.post-management{padding:20px}</style>
