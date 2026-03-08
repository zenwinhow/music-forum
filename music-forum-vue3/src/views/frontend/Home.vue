<template>
  <div class="home">
    <!-- 轮播图 -->
    <div class="banner-section">
      <el-carousel :interval="5000" height="500px" type="card" indicator-position="none">
        <el-carousel-item v-for="(item, index) in banners" :key="index">
          <div class="banner-item" :style="{ backgroundImage: `linear-gradient(to right, ${item.color}dd, ${item.color}55)` }">
            <div class="banner-content">
              <h2>{{ item.title }}</h2>
              <p>{{ item.description }}</p>
              <!-- <el-button
                v-if="item.link"
                type="primary"
                size="large"
                round
                @click="navigate(item.link)"
              >
                了解更多
              </el-button> -->
            </div>
          </div>
        </el-carousel-item>
      </el-carousel>
    </div>

    <!-- 搜索框 -->
    <div class="search-section">
      <div class="search-container">
        <el-autocomplete
          v-model="searchKeyword"
          placeholder="搜索你感兴趣的内容..."
          :fetch-suggestions="querySearchAsync"
          clearable
          class="search-input"
          size="large"
          @select="handleSelect"
          @keyup.enter="handleSearch"
          :trigger-on-focus="false"
          :popper-class="'search-suggestions-dropdown'"
        >
          <template #prefix>
            <el-icon><Search /></el-icon>
          </template>
          <template #default="{ item }">
            <div class="suggestion-item" :class="item.type">
              <el-icon v-if="item.type === 'post'"><Document /></el-icon>
              <el-icon v-else-if="item.type === 'section'"><Menu /></el-icon>
              <el-icon v-else><Files /></el-icon>
              <div class="suggestion-content">
                <div class="suggestion-title">{{ item.title }}</div>
                <div class="suggestion-desc">{{ item.description }}</div>
              </div>
            </div>
          </template>
        </el-autocomplete>
        <div class="search-tags" v-if="hotSearchTags.length > 0">
          <span class="tag-label">热门：</span>
          <el-tag
            v-for="tag in hotSearchTags"
            :key="tag"
            size="small"
            effect="plain"
            class="hot-tag"
            @click="searchByTag(tag)"
          >
            {{ tag }}
          </el-tag>
        </div>
      </div>
    </div>

    <!-- 主要内容区 -->
    <div class="main-content">
      <!-- 板块导航 -->
      <div class="section-grid">
        <div class="section-header">
          <h2>学习板块</h2>
          <router-link to="/sections" class="view-all">
            查看全部 <el-icon><ArrowRight /></el-icon>
          </router-link>
        </div>
        <div class="grid-container">
          <router-link
            v-for="section in sections"
            :key="section.id"
            :to="`/forum/section/${section.id}`"
            class="grid-item"
          >
            <div class="grid-item-content">
              <div class="section-icon">
                <el-icon><School /></el-icon>
              </div>
              <h3>{{ section.name }}</h3>
              <p>{{ section.description }}</p>
              <div class="item-stats">
                <div class="stat-item">
                  <el-icon><ChatDotRound /></el-icon>
                  <span>{{ section.postCount }} 帖子</span>
                </div>
                <div class="stat-item">
                  <el-icon><Timer /></el-icon>
                  <span>今日 +{{ section.todayPosts }}</span>
                </div>
              </div>
            </div>
          </router-link>
        </div>
      </div>

      <!-- 热门内容 -->
      <div class="hot-content">
        <div class="content-header">
          <h2>热门内容</h2>
          <div class="header-tabs">
            <span 
              v-for="tab in ['热门帖子', '最新资源']" 
              :key="tab"
              :class="['tab-item', { active: activeTab === tab }]"
              @click="activeTab = tab"
            >
              {{ tab }}
            </span>
          </div>
        </div>
        
        <div class="content-body">
          <!-- 热门帖子列表 -->
          <div v-if="activeTab === '热门帖子'" class="posts-list">
            <div v-for="post in hotPosts" :key="post.id" class="post-card">
              <div class="post-meta">
                <el-avatar :src="'/api' + post.avatar" :size="36">
                  {{ post.author.charAt(0) }}
                </el-avatar>
                <div class="post-info">
                  <span class="author">{{ post.author }}</span>
                  <span class="time">{{ formatDate(post.createTime) }}</span>
                </div>
                <el-tag v-if="post.isEssence" size="small" type="success">精华</el-tag>
              </div>
              <router-link :to="`/forum/post/${post.id}`" class="post-content">
                <h3>{{ post.title }}</h3>
                <p>{{ post.excerpt }}</p>
              </router-link>
              <div class="post-stats">
                <span><el-icon><View /></el-icon> {{ post.viewCount }}</span>
                <span><el-icon><ChatLineRound /></el-icon> {{ post.commentCount }}</span>
              </div>
            </div>
          </div>

          <!-- 最新资源列表 -->
          <div v-else class="resources-grid">
            <div 
              v-for="resource in latestResources" 
              :key="resource.id" 
              class="resource-card"
              @click="goToResource(resource.id)"
            >
              <div class="resource-icon">
                <el-icon>
                  <component :is="getResourceIcon(resource.fileType)" />
                </el-icon>
              </div>
              <div class="resource-info">
                <h3>{{ resource.name }}</h3>
                <p>{{ resource.categoryName }}</p>
                <div class="resource-meta">
                  <span>{{ formatFileSize(resource.fileSize * 1024) }}</span>
                  <span>{{ formatDate(resource.createTime) }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from "vue";
import { useRouter } from "vue-router";
import { 
  User,
  ChatDotRound,
  Reading,
  Timer,
  View,
  ChatLineRound,
  Document,
  Tickets,
  Picture,
  VideoPlay,
  Files,
  Search,
  Menu,
  ArrowRight,
  School
} from "@element-plus/icons-vue";
import request from "@/utils/request";
import { ElMessage } from "element-plus";

const router = useRouter();

// 轮播图数据
const banners = ref([
  {
    title: "欢迎加入校园交流论坛",
    description: "促进学术交流，共享优质资源，连接师生，共建美好校园社区",
    image: "/images/banner1.jpg",
    color: "#41b883",
    link: "/forum/about",
  },
  {
    title: "期末复习资料汇总",
    description: "老师和学长学姐分享的复习经验和资料，助你轻松备考",
    image: "/images/banner2.jpg",
    color: "#1982c3",
    link: "/forum/resource?category=3",
  },
  {
    title: "教学经验分享会",
    description: "优秀教师分享教学经验与心得，提升教学质量与学习效果",
    image: "/images/banner3.jpg",
    color: "#67c23a",
    link: "/forum/section/1",
  },
]);

// 系统通知
const notifications = ref([]);

// 统计数据
const stats = ref({
  userCount: 0,
  postCount: 0,
  resourceCount: 0,
  todayActive: 0,
});

// 板块数据
const sections = ref([]);

// 热门帖子
const hotPosts = ref([]);

// 最新资源
const latestResources = ref([]);

// 搜索相关
const searchKeyword = ref('')
const hotSearchTags = ref(['期末复习', '实验报告', '考研资料', '课程作业'])

// 新增状态
const activeTab = ref('热门帖子')

// 格式化数字
const formatNumber = (num) => {
  return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
};

// 格式化日期
const formatDate = (dateString) => {
  const date = new Date(dateString);
  const now = new Date();
  const diff = Math.floor((now - date) / 1000); // 秒数差
  
  if (diff < 60) {
    return "刚刚";
  } else if (diff < 3600) {
    return Math.floor(diff / 60) + "分钟前";
  } else if (diff < 86400) {
    return Math.floor(diff / 3600) + "小时前";
  } else if (diff < 2592000) {
    return Math.floor(diff / 86400) + "天前";
  } else {
    return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(
      2,
      "0"
    )}-${String(date.getDate()).padStart(2, "0")}`;
  }
};

// 格式化文件大小
const formatFileSize = (bytes) => {
  if (bytes === 0) return "0 B";
  const k = 1024;
  const sizes = ["B", "KB", "MB", "GB", "TB"];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + " " + sizes[i];
};

// 导航到特定链接
const navigate = (link) => {
  router.push(link);
};

// 处理资源查看
const handleResourceView = (resource) => {
  router.push(`/forum/resource/${resource.id}`);
};

// 在 script setup 部分添加跳转方法
const goToResource = (id) => {
  router.push(`/forum/resource/${id}`)
};

// 获取数据
const fetchHomeData = async () => {
  try {
    // 获取版区列表
    await request.get("/section/all?status=1", null, {
      showDefaultMsg: false,
      onSuccess: async (data) => {
        const sectionsData = data || [];
        sections.value = [];

        // 获取每个板块的详细信息和统计数据
        for (const section of sectionsData) {
          try {
            const response = await request.get(
              `/post/section/stats/${section.id}`,
              null,
              {
                showDefaultMsg: false,
                onSuccess: (res) => {
                  // 直接处理响应数据
                  const stats = res;
                  sections.value.push({
                    id: section.id,
                    name: section.sectionName,
                    description: section.description,
                    icon: getSectionIcon(section.id),
                    color: getSectionColor(section.id),
                    postCount: stats?.totalPosts || 0,
                    todayPosts: stats?.todayPosts || 0,
                  });
                },
              }
            );
          } catch (err) {
            console.error("获取板块统计信息失败：", section.id, err);
            // 即使获取统计失败，也添加板块基本信息
            sections.value.push({
              id: section.id,
              name: section.sectionName,
              description: section.description,
              icon: getSectionIcon(section.id),
              color: getSectionColor(section.id),
              postCount: 0,
              todayPosts: 0,
            });
          }
        }
      },
    });
    
    // 获取热门帖子
    await request.get(
      "/post/page",
      {
        status: 1, 
        currentPage: 1, 
        size: 5,
        isEssence: 1, // 优先获取精华帖
      },
      {
        showDefaultMsg: false,
        onSuccess: (data) => {
          const posts = data.records || [];
          hotPosts.value = posts.map((post) => ({
            id: post.id || post.post_id,
            title: post.title,
            excerpt: post.content.substring(0, 100) + (post.content.length > 100 ? "..." : ""),
            author: post.user.username || post.user.realName || "未知用户",
            avatar: post.user.avatar || "/images/default-avatar.png",
            createTime: post.createTime || "未知时间",
            viewCount: post.viewCount || 0,
            commentCount: post.commentCount || 0,
            isEssence: post.isEssence === 1 || false,
          }));
        },
      }
    );
    
    // 获取最新资源
    await request.get(
      "/resource/page",
      {
        status: 1, 
        currentPage: 1, 
        size: 6,
      },
      {
        showDefaultMsg: false,
        onSuccess: (data) => {
          const resources = data.records || [];
          latestResources.value = resources.map((resource) => ({
            id: resource.id || resource.resource_id,
            name: resource.resourceName || resource.resource_name,
            fileType: resource.fileType || resource.file_type,
            uploaderName: resource.username || resource.uploader_name,
            categoryName: resource.categoryName || resource.category_name,
            createTime: resource.createTime || resource.create_time,
            fileSize: resource.fileSize || resource.file_size,
          }));
        },
      }
    );
    
    // 获取系统通知
    await request.get(
      "/notification/page",
      {
        status: 1, 
        currentPage: 1, 
        size: 3,
      },
      {
        showDefaultMsg: false,
        onSuccess: (data) => {
          const notices = data.records || [];
          notifications.value = notices.map((notice) => ({
            id: notice.id || notice.notification_id,
            title: notice.title,
            content: notice.content,
            createTime: notice.createTime || notice.create_time,
          }));
        },
      }
    );
  } catch (error) {
    console.error("获取首页数据失败:", error);
  }
};

// 获取版块图标
const getSectionIcon = (sectionId) => {
  const icons = {
    1: "el-icon-s-management", // 学术交流
    2: "el-icon-s-cooperation", // 教学资源
    3: "el-icon-s-opportunity", // 课外活动
    4: "el-icon-s-platform", // 技术交流
    5: "el-icon-s-home", // 校园生活
  };
  return icons[sectionId] || "el-icon-s-grid";
};

// 获取版块颜色
const getSectionColor = (sectionId) => {
  const colors = {
    1: "#409eff", // 学术交流
    2: "#67c23a", // 教学资源
    3: "#e6a23c", // 课外活动
    4: "#f56c6c", // 技术交流
    5: "#9254de", // 校园生活
  };
  return colors[sectionId] || "#909399";
};

// 获取资源图标
const getResourceIcon = (fileType) => {
  if (!fileType) return 'Files';
  if (fileType.includes('doc')) return 'Document';
  if (fileType.includes('pdf')) return 'Tickets';
  if (fileType.includes('jpg') || fileType.includes('png')) return 'Picture';
  if (fileType.includes('mp4') || fileType.includes('avi')) return 'VideoPlay';
  return 'Files';
};

// 随机标签类型
const getRandomTagType = () => {
  const types = ['', 'success', 'info', 'warning'];
  return types[Math.floor(Math.random() * types.length)];
};

// 处理搜索
const handleSearch = () => {
  if (!searchKeyword.value.trim()) {
    ElMessage.warning('请输入搜索关键词');
    return;
  }
  
  router.push({
    path: '/forum/search',
    query: { keyword: searchKeyword.value }
  });
};

const searchByTag = (tag) => {
  searchKeyword.value = tag;
  handleSearch();
};

// 搜索防抖定时器
let searchTimeout = null;

// 处理搜索建议
const querySearchAsync = (queryString, cb) => {
  // 清除之前的定时器
  if (searchTimeout) {
    clearTimeout(searchTimeout);
  }

  // 空字符串直接返回空结果
  if (!queryString || queryString.trim() === '') {
    cb([]);
    return;
  }

  // 设置300ms的防抖
  searchTimeout = setTimeout(async () => {
    try {
      const params = {
        keyword: queryString.trim()
      };
      await request.get('/search/suggestions', params, {
        showDefaultMsg: false,
        onSuccess: (data) => {
          const suggestions = [];
          
          // 处理帖子建议
          if (data.posts && Array.isArray(data.posts)) {
            data.posts.forEach(post => {
              if (post && post.title) {
                suggestions.push({
                  value: post.title,
                  title: post.title,
                  description: `帖子 · ${post.user?.username || '未知用户'} · ${formatDate(post.createTime)}`,
                  type: 'post',
                  link: `/forum/post/${post.id}`
                });
              }
            });
          }
          
          // 处理版块建议
          if (data.sections && Array.isArray(data.sections)) {
            data.sections.forEach(section => {
              if (section && section.sectionName) {
                suggestions.push({
                  value: section.sectionName,
                  title: section.sectionName,
                  description: section.description || '暂无描述',
                  type: 'section',
                  link: `/forum/section/${section.id}`
                });
              }
            });
          }
          
          // 处理资源建议
          if (data.resources && Array.isArray(data.resources)) {
            data.resources.forEach(resource => {
              if (resource && resource.resourceName) {
                suggestions.push({
                  value: resource.resourceName,
                  title: resource.resourceName,
                  description: `资源 · ${formatFileSize(resource.fileSize * 1024)}`,
                  type: 'resource',
                  link: `/forum/resource/${resource.id}`
                });
              }
            });
          }
          
          cb(suggestions);
        },
        onError: () => {
          cb([]); // 错误时返回空数组
        }
      });
    } catch (error) {
      console.error('获取搜索建议失败:', error);
      cb([]); // 错误时返回空数组
    }
  }, 300);
};

// 处理建议选择
const handleSelect = (item) => {
  if (item && item.link) {
    router.push(item.link);
  }
};

onMounted(() => {
  fetchHomeData();
});
</script>

<style lang="scss" scoped>
.home {
  min-height: 100vh;
  background-color: #f9f9f9;
}

/* 轮播图样式 */
.banner-section {
  padding: 20px 0 60px;
  background: linear-gradient(180deg, #fff 0%, #f9f9f9 100%);
}

.banner-item {
  height: 100%;
  background-size: cover;
  background-position: center;
  border-radius: 20px;
  overflow: hidden;
  box-shadow: 0 8px 30px rgba(0, 0, 0, 0.1);
  display: flex;
  align-items: center;
  padding: 0 60px;
}

.banner-content {
  max-width: 600px;
  color: #fff;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.banner-content h2 {
  font-size: 2.5rem;
  font-weight: 700;
  margin-bottom: 1rem;
  line-height: 1.2;
}

.banner-content p {
  font-size: 1.25rem;
  margin-bottom: 2rem;
  opacity: 0.9;
  line-height: 1.6;
}

/* 搜索框样式 */
.search-section {
  position: relative;
  margin: -10px auto 50px;
  padding: 0 20px;
  max-width: 800px;
  z-index: 10;
}

.search-container {
  background-color: transparent;
  padding: 25px 0;
}

.search-input {
  margin-bottom: 25px;
}

.search-input :deep(.el-input__wrapper) {
  border-radius: 50px;
  padding: 8px 20px;
  background-color: #fff;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
  transition: all 0.3s;
}

.search-input :deep(.el-input__wrapper.is-focus) {
  box-shadow: 0 8px 20px rgba(65, 184, 131, 0.15);
  transform: translateY(-2px);
}

.search-input :deep(.el-input__inner) {
  font-size: 16px;
  height: 26px;
}

.search-input :deep(.el-input__prefix) {
  margin-right: 10px;
}

.search-input :deep(.el-icon) {
  color: #41b883;
  font-size: 18px;
}

.search-tags {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  margin-top: 10px;
  gap: 12px;
  padding: 0 15px;
}

.tag-label {
  color: #666;
  font-size: 14px;
  font-weight: 500;
}

.hot-tag {
  cursor: pointer;
  transition: all 0.3s;
  border-radius: 50px;
  padding: 0 15px;
  height: 28px;
  line-height: 26px;
  border-color: #41b883;
  color: #41b883;
  
  &:hover {
    transform: translateY(-2px);
    background-color: rgba(65, 184, 131, 0.1);
    color: #41b883;
  }
}

:deep(.search-suggestions-dropdown) {
  margin-top: 10px !important;
  border-radius: 15px !important;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1) !important;
  border: none !important;
  padding: 8px !important;
}

.suggestion-item {
  display: flex;
  align-items: center;
  padding: 12px 15px;
  gap: 14px;
  cursor: pointer;
  transition: all 0.2s;
  border-radius: 10px;
  margin-bottom: 4px;
}

.suggestion-item:hover {
  background-color: #f5fffa;
  transform: translateX(3px);
}

.suggestion-item .el-icon {
  font-size: 20px;
  flex-shrink: 0;
  color: #41b883;
  background-color: rgba(65, 184, 131, 0.1);
  width: 36px;
  height: 36px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 10px;
}

.suggestion-content {
  flex: 1;
  min-width: 0;
  overflow: hidden;
}

.suggestion-title {
  font-size: 15px;
  font-weight: 600;
  color: #333;
  margin-bottom: 5px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.suggestion-desc {
  font-size: 13px;
  color: #777;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

/* 主要内容区 */
.main-content {
  max-width: 1200px;
  margin: 0 auto 60px;
  padding: 0 20px;
}

/* 板块网格 */
.section-grid {
  margin-bottom: 50px;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
}

.section-header h2 {
  font-size: 28px;
  font-weight: 700;
  color: #333;
  margin: 0;
  position: relative;
  padding-left: 15px;
  
  &::before {
    content: "";
    position: absolute;
    left: 0;
    top: 5px;
    height: 28px;
    width: 5px;
    background: linear-gradient(to bottom, #41b883, #1982c3);
    border-radius: 3px;
  }
}

.view-all {
  color: #41b883;
  text-decoration: none;
  font-size: 16px;
  font-weight: 500;
  transition: all 0.2s;
  display: flex;
  align-items: center;
  gap: 5px;
  
  &:hover {
    color: #1982c3;
    transform: translateX(5px);
  }
}

.grid-container {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 25px;
}

.grid-item {
  text-decoration: none;
  color: inherit;
}

.grid-item-content {
  background: #fff;
  padding: 30px;
  border-radius: 20px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.03);
  transition: all 0.3s;
  height: 100%;
  display: flex;
  flex-direction: column;
}

.grid-item-content:hover {
  transform: translateY(-5px);
  box-shadow: 0 15px 35px rgba(0, 0, 0, 0.08);
}

.section-icon {
  width: 50px;
  height: 50px;
  border-radius: 15px;
  background: linear-gradient(135deg, #41b883, #1982c3);
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 20px;
  
  .el-icon {
    font-size: 24px;
    color: #fff;
  }
}

.grid-item-content h3 {
  font-size: 20px;
  font-weight: 600;
  margin: 0 0 10px;
  color: #333;
}

.grid-item-content p {
  font-size: 14px;
  color: #666;
  margin: 0 0 20px;
  line-height: 1.6;
  flex-grow: 1;
}

.item-stats {
  display: flex;
  justify-content: space-between;
  font-size: 14px;
  color: #666;
  
  .stat-item {
    display: flex;
    align-items: center;
    gap: 5px;
    
    .el-icon {
      font-size: 16px;
      color: #41b883;
    }
  }
}

/* 热门内容区域 */
.hot-content {
  background: #fff;
  border-radius: 20px;
  padding: 30px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.03);
}

.content-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
}

.content-header h2 {
  font-size: 28px;
  font-weight: 700;
  color: #333;
  margin: 0;
  position: relative;
  padding-left: 15px;
  
  &::before {
    content: "";
    position: absolute;
    left: 0;
    top: 5px;
    height: 28px;
    width: 5px;
    background: linear-gradient(to bottom, #41b883, #1982c3);
    border-radius: 3px;
  }
}

.header-tabs {
  display: flex;
  gap: 20px;
}

.tab-item {
  font-size: 16px;
  color: #666;
  cursor: pointer;
  padding: 5px 0;
  position: relative;
  font-weight: 500;
  transition: all 0.2s;
  
  &:hover {
    color: #41b883;
  }
}

.tab-item.active {
  color: #41b883;
}

.tab-item.active::after {
  content: '';
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  height: 3px;
  background: #41b883;
  border-radius: 3px;
}

/* 帖子列表 */
.posts-list {
  display: grid;
  gap: 25px;
}

.post-card {
  padding: 25px;
  border-radius: 15px;
  background: #f9f9f9;
  transition: all 0.3s;
  
  &:hover {
    transform: translateY(-5px);
    box-shadow: 0 10px 20px rgba(0, 0, 0, 0.05);
  }
}

.post-meta {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 16px;
}

.post-info {
  display: flex;
  flex-direction: column;
  flex: 1;
}

.author {
  font-size: 14px;
  font-weight: 600;
  color: #333;
}

.time {
  font-size: 12px;
  color: #999;
}

.post-content {
  text-decoration: none;
  color: inherit;
  display: block;
  margin-bottom: 16px;
}

.post-content h3 {
  font-size: 18px;
  font-weight: 600;
  color: #333;
  margin: 0 0 10px;
}

.post-content p {
  font-size: 14px;
  color: #666;
  margin: 0;
  line-height: 1.6;
}

.post-stats {
  display: flex;
  gap: 16px;
  font-size: 13px;
  color: #999;
}

.post-stats span {
  display: flex;
  align-items: center;
  gap: 4px;
}

/* 资源网格 */
.resources-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 25px;
}

.resource-card {
  padding: 20px;
  border-radius: 15px;
  background: #f9f9f9;
  display: flex;
  gap: 16px;
  cursor: pointer;
  transition: all 0.3s;
  
  &:hover {
    transform: translateY(-5px);
    box-shadow: 0 10px 20px rgba(0, 0, 0, 0.05);
  }
}

.resource-icon {
  width: 45px;
  height: 45px;
  border-radius: 12px;
  background: linear-gradient(135deg, #41b883, #1982c3);
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  
  .el-icon {
    font-size: 20px;
  }
}

.resource-info {
  flex: 1;
}

.resource-info h3 {
  font-size: 16px;
  font-weight: 600;
  color: #333;
  margin: 0 0 5px;
}

.resource-info p {
  font-size: 14px;
  color: #666;
  margin: 0 0 10px;
}

.resource-meta {
  display: flex;
  justify-content: space-between;
  font-size: 12px;
  color: #999;
}

@media (max-width: 768px) {
  .banner-content h2 {
    font-size: 2rem;
  }
  
  .banner-section {
    padding: 10px 0 40px;
  }
  
  .banner-item {
    padding: 0 30px;
  }
  
  .search-section {
    margin: -20px auto 30px;
    padding: 0 15px;
  }

  .search-container {
    padding: 20px;
  }

  .main-content {
    padding: 0 15px;
  }
  
  .section-header h2,
  .content-header h2 {
    font-size: 22px;
  }
  
  .grid-container {
    grid-template-columns: 1fr;
  }
  
  .hot-content {
    padding: 20px;
  }
  
  .resources-grid {
    grid-template-columns: 1fr;
  }
  
  .content-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 15px;
  }
  
  .header-tabs {
    width: 100%;
    justify-content: space-around;
  }
}

.el-autocomplete {
  width: 100%;
}
</style>


