<template>
  <div class="about-page">
    <el-card class="section">
      <template #header><span>关于音乐论坛</span></template>
      <p>
        音乐论坛是一个轻量级音乐分享社区，聚焦歌曲分享、评论互动、收藏管理与基础后台管理能力。
      </p>
    </el-card>

    <el-card class="section">
      <template #header><span>核心功能</span></template>
      <ul>
        <li>按歌曲名、歌手、流派、标签、封面链接、外链地址发布音乐分享帖。</li>
        <li>支持按分类浏览，并按歌曲名、歌手、标签进行搜索。</li>
        <li>支持评论与收藏互动。</li>
        <li>管理员可管理用户、帖子、评论和分类。</li>
      </ul>
    </el-card>

    <el-card class="section">
      <template #header><span>联系方式</span></template>
      <p>邮箱：contact@musicforum.local</p>
    </el-card>
  </div>
</template>

<script setup>
</script>

<style scoped>
.about-page {
  display: grid;
  gap: 16px;
}
.section {
  line-height: 1.8;
}
</style>
