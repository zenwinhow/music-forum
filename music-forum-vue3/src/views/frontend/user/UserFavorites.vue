<template>
  <div class="user-favorites">
    <h1 class="page-title">我的收藏</h1>

    <el-card class="favorites-card" v-loading="loading">
      <template v-if="favorites.length > 0">
        <div class="favorite-list">
          <div v-for="favorite in favorites" :key="favorite.id" class="favorite-item">
            <router-link :to="`/forum/post/${favorite.postId}`" class="post-title">
              {{ favorite.postTitle }}
            </router-link>
            <div class="favorite-meta">
              <span class="favorite-time">收藏于：{{ formatDate(favorite.createTime) }}</span>
              <el-button 
                type="danger" 
                size="small" 
                @click="handleCancelFavorite(favorite.postId)"
              >
                取消收藏
              </el-button>
            </div>
          </div>
        </div>
        
        <!-- 分页器 -->
        <div class="pagination-container" v-if="total > 0">
          <el-pagination
            v-model:currentPage="currentPage"
            v-model:pageSize="pageSize"
            :page-sizes="[10, 20, 50]"
            :background="true"
            layout="total, sizes, prev, pager, next, jumper"
            :total="total"
            @size-change="handleSizeChange"
            @current-change="handleCurrentChange"
          />
        </div>
      </template>
      <template v-else>
        <el-empty description="暂无收藏帖子" />
      </template>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { useUserStore } from '@/store/user'
import request from '@/utils/request'
import { formatDate } from '@/utils/format'

const router = useRouter()
const userStore = useUserStore()

// 分页参数
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)

// 收藏列表数据
const favorites = ref([])
const loading = ref(false)

// 获取收藏列表
const getFavorites = async () => {
  if (!userStore.isLoggedIn) {
    ElMessage.warning('请先登录')
    router.push('/login')
    return
  }

  loading.value = true
  try {
    await request.get('/post/favorite/user', {
      currentPage: currentPage.value,
      size: pageSize.value
    }, {
      showDefaultMsg: false,
      onSuccess: (data) => {
        favorites.value = data.records || []
        total.value = data.total || 0
      }
    })
  } catch (error) {
    console.error('获取收藏列表失败:', error)
    ElMessage.error('获取收藏列表失败')
  } finally {
    loading.value = false
  }
}

// 取消收藏
const handleCancelFavorite = async (postId) => {
  try {
    await request.post(`/post/favorite/${postId}`, null, {
      successMsg: '取消收藏成功',
      onSuccess: () => {
        // 重新获取收藏列表
        getFavorites()
      }
    })
  } catch (error) {
    console.error('取消收藏失败:', error)
  }
}

// 分页大小改变
const handleSizeChange = (val) => {
  pageSize.value = val
  getFavorites()
}

// 当前页改变
const handleCurrentChange = (val) => {
  currentPage.value = val
  getFavorites()
}

onMounted(() => {
  getFavorites()
})
</script>

<style lang="scss" scoped>
.user-favorites {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;

  .page-title {
    margin-bottom: 20px;
    font-size: 1.8rem;
    color: #333;
  }

  .favorites-card {
    margin-bottom: 20px;
  }

  .favorite-list {
    .favorite-item {
      padding: 15px 0;
      border-bottom: 1px solid #ebeef5;
      
      &:last-child {
        border-bottom: none;
      }
      
      .post-title {
        display: block;
        font-size: 1.1rem;
        font-weight: bold;
        color: #333;
        margin-bottom: 10px;
        text-decoration: none;
        
        &:hover {
          color: #409EFF;
        }
      }
      
      .favorite-meta {
        display: flex;
        justify-content: space-between;
        align-items: center;
        color: #999;
        font-size: 0.9rem;
      }
    }
  }

  .pagination-container {
    margin-top: 20px;
    display: flex;
    justify-content: center;
  }
}
</style> 