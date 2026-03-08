<template>
  <div class="about-page">
    <div class="about-container">
      <!-- 标题部分 -->
      <div class="page-header">
        <div class="header-icon">
          <el-icon><InfoFilled /></el-icon>
        </div>
        <h1 class="title">关于我们</h1>
        <div class="subtitle">师生交流论坛 - 连接教学与学习的桥梁</div>
      </div>

      <!-- 介绍部分 -->
      <el-card class="section-card intro-section" shadow="hover">
        <template #header>
          <div class="card-header">
            <el-icon><School /></el-icon>
            <span>平台介绍</span>
          </div>
        </template>
        <div class="card-content">
          <p>师生交流论坛是一个专为教育机构打造的综合性交流平台，旨在促进师生之间的高效沟通与资源共享。我们致力于打破传统课堂的时空限制，为教师和学生提供一个开放、互动、便捷的在线交流环境。</p>
          <p>通过本平台，师生可以进行学术讨论、资源分享、问题解答，共同建设一个充满活力的学习社区。</p>
        </div>
      </el-card>

      <!-- 功能特色 -->
      <el-card class="section-card features-section" shadow="hover">
        <template #header>
          <div class="card-header">
            <el-icon><Star /></el-icon>
            <span>功能特色</span>
          </div>
        </template>
        <div class="features-grid">
          <div class="feature-item">
            <el-icon class="feature-icon"><ChatDotRound /></el-icon>
            <h3>交流讨论</h3>
            <p>提供多个专业板块，支持师生进行学术交流与问题讨论</p>
          </div>
          <div class="feature-item">
            <el-icon class="feature-icon"><Files /></el-icon>
            <h3>资源共享</h3>
            <p>丰富的教学资源库，支持各类资料的上传与下载</p>
          </div>
          <div class="feature-item">
            <el-icon class="feature-icon"><Bell /></el-icon>
            <h3>通知公告</h3>
            <p>及时发布重要通知，确保信息高效传达</p>
          </div>
          <div class="feature-item">
            <el-icon class="feature-icon"><User /></el-icon>
            <h3>个人中心</h3>
            <p>完善的个人档案管理，记录学习与交流足迹</p>
          </div>
        </div>
      </el-card>

      <!-- 团队介绍 -->
      <el-card class="section-card team-section" shadow="hover">
        <template #header>
          <div class="card-header">
            <el-icon><UserFilled /></el-icon>
            <span>团队介绍</span>
          </div>
        </template>
        <div class="card-content">
          <p>我们是一支由教育工作者、技术专家和设计师组成的专业团队，拥有丰富的教育领域经验和技术开发能力。团队成员秉持"以用户为中心"的理念，不断优化平台功能，提升用户体验。</p>
          <div class="team-members">
            <div class="member">
              <div class="member-avatar">
                <el-avatar :size="80" src="https://cube.elemecdn.com/0/88/03b0d39583f48206768a7534e55bcpng.png"></el-avatar>
              </div>
              <div class="member-info">
                <h3>张教授</h3>
                <p>教育顾问</p>
              </div>
            </div>
            <div class="member">
              <div class="member-avatar">
                <el-avatar :size="80" src="https://cube.elemecdn.com/0/88/03b0d39583f48206768a7534e55bcpng.png"></el-avatar>
              </div>
              <div class="member-info">
                <h3>李工</h3>
                <p>技术负责人</p>
              </div>
            </div>
            <div class="member">
              <div class="member-avatar">
                <el-avatar :size="80" src="https://cube.elemecdn.com/0/88/03b0d39583f48206768a7534e55bcpng.png"></el-avatar>
              </div>
              <div class="member-info">
                <h3>王设计</h3>
                <p>UI/UX设计师</p>
              </div>
            </div>
          </div>
        </div>
      </el-card>

      <!-- 联系我们 -->
      <el-card class="section-card contact-section" shadow="hover">
        <template #header>
          <div class="card-header">
            <el-icon><Message /></el-icon>
            <span>联系我们</span>
          </div>
        </template>
        <div class="contact-info">
          <div class="contact-item">
            <el-icon><Location /></el-icon>
            <span>地址：中国北京市海淀区学院路100号</span>
          </div>
          <div class="contact-item">
            <el-icon><Message /></el-icon>
            <span>邮箱：contact@teacherstudent.edu.cn</span>
          </div>
          <div class="contact-item">
            <el-icon><Phone /></el-icon>
            <span>电话：010-12345678</span>
          </div>
        </div>
      </el-card>
    </div>
  </div>
</template>

<script setup>
import { 
  ChatDotRound, Files, Bell, User, 
  Location, Message, Phone, School,
  InfoFilled, Star, UserFilled
} from '@element-plus/icons-vue'
</script>

<style lang="scss" scoped>
.about-page {
  padding: 30px 20px;
  background-color: #f9f7fa;
}

.about-container {
  max-width: 1200px;
  margin: 0 auto;
}

.page-header {
  text-align: center;
  margin-bottom: 40px;
  
  .header-icon {
    font-size: 48px;
    color: #8e44ad;
    margin-bottom: 20px;
  }
  
  .title {
    font-size: 2.5rem;
    margin-bottom: 15px;
    background: linear-gradient(120deg, #8e44ad, #9b59b6);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    font-weight: 700;
  }
  
  .subtitle {
    font-size: 1.2rem;
    color: #606266;
  }
}

.section-card {
  margin-bottom: 40px;
  border-radius: 16px;
  overflow: hidden;
  transition: transform 0.3s, box-shadow 0.3s;
  
  &:hover {
    transform: translateY(-5px);
    box-shadow: 0 15px 30px rgba(0, 0, 0, 0.1);
  }
  
  .card-header {
    display: flex;
    align-items: center;
    gap: 10px;
    font-size: 20px;
    font-weight: 600;
    
    .el-icon {
      color: #8e44ad;
      font-size: 24px;
    }
  }
  
  .card-content {
    padding: 10px;
    
    p {
      color: #606266;
      line-height: 1.8;
      margin-bottom: 15px;
      font-size: 16px;
    }
  }
}

.features-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
  gap: 30px;
  padding: 10px;
  
  .feature-item {
    text-align: center;
    padding: 30px 20px;
    border-radius: 16px;
    transition: all 0.3s;
    background-color: rgba(142, 68, 173, 0.05);
    border: 1px solid rgba(142, 68, 173, 0.1);
    
    &:hover {
      transform: translateY(-8px);
      box-shadow: 0 10px 25px rgba(142, 68, 173, 0.2);
      background-color: white;
    }
    
    .feature-icon {
      font-size: 48px;
      color: #8e44ad;
      margin-bottom: 20px;
    }
    
    h3 {
      font-size: 1.4rem;
      margin-bottom: 15px;
      color: #303133;
      font-weight: 600;
    }
    
    p {
      color: #606266;
      font-size: 1rem;
      line-height: 1.6;
    }
  }
}

.team-members {
  display: flex;
  flex-wrap: wrap;
  gap: 40px;
  justify-content: center;
  margin-top: 30px;
  
  .member {
    display: flex;
    flex-direction: column;
    align-items: center;
    text-align: center;
    width: 200px;
    padding: 25px;
    border-radius: 16px;
    background-color: rgba(142, 68, 173, 0.05);
    transition: all 0.3s;
    
    &:hover {
      transform: translateY(-8px);
      box-shadow: 0 10px 25px rgba(142, 68, 173, 0.2);
      background-color: white;
    }
    
    .member-avatar {
      margin-bottom: 20px;
      
      .el-avatar {
        border: 4px solid rgba(142, 68, 173, 0.2);
        box-shadow: 0 8px 20px rgba(142, 68, 173, 0.2);
      }
    }
    
    .member-info {
      h3 {
        margin: 0 0 10px;
        font-size: 1.2rem;
        color: #303133;
        font-weight: 600;
      }
      
      p {
        margin: 0;
        color: #8e44ad;
        font-size: 1rem;
      }
    }
  }
}

.contact-info {
  display: flex;
  flex-direction: column;
  gap: 25px;
  padding: 10px;
  
  .contact-item {
    display: flex;
    align-items: center;
    font-size: 16px;
    padding: 15px 20px;
    border-radius: 12px;
    background-color: rgba(142, 68, 173, 0.05);
    transition: all 0.3s;
    
    &:hover {
      transform: translateX(5px);
      background-color: rgba(142, 68, 173, 0.1);
    }
    
    .el-icon {
      font-size: 24px;
      color: #8e44ad;
      margin-right: 15px;
    }
    
    span {
      color: #606266;
    }
  }
}

@media (max-width: 768px) {
  .page-header {
    .title {
      font-size: 2rem;
    }
    
    .subtitle {
      font-size: 1rem;
    }
  }
  
  .features-grid {
    grid-template-columns: 1fr;
  }
  
  .team-members {
    justify-content: center;
    gap: 20px;
    
    .member {
      width: 100%;
      max-width: 250px;
    }
  }
  
  .contact-info {
    gap: 15px;
    
    .contact-item {
      font-size: 14px;
      
      .el-icon {
        font-size: 20px;
      }
    }
  }
}
</style> 