<template>
  <footer class="front-footer">

    
    <div class="footer-content">
      <div class="footer-container">
        <div class="footer-bottom">
          <div class="copyright">
            <p>&copy; {{ currentYear }} 校园交流论坛 版权所有</p>
          </div>
          
          <div class="friend-links">
            <span>友情链接：</span>
            <a href="https://www.edu.cn" target="_blank">中国教育和科研计算机网</a>
            <a href="https://www.moe.gov.cn" target="_blank">中华人民共和国教育部</a>
            <a href="https://github.com" target="_blank">GitHub</a>
          </div>
        </div>
      </div>
    </div>
  </footer>
</template>

<script setup>
import { computed } from 'vue'

// 获取当前年份
const currentYear = computed(() => new Date().getFullYear())
</script>

<style lang="scss" scoped>
.front-footer {
  position: relative;
  width: 100%;
  
  .footer-wave {
    display: block;
    width: 100%;
    height: 140px;
    margin-bottom: -10px;
    
    svg {
      display: block;
      width: 100%;
      height: 100%;
    }
  }
  
  .footer-content {
    background: linear-gradient(135deg, #41b883, #1982c3);
    color: #fff;
    padding: 20px 0;
  }
  
  .footer-container {
    max-width: 1200px;
    margin: 0 auto;
    padding: 0 20px;
  }
  
  .footer-bottom {
    display: flex;
    flex-wrap: wrap;
    justify-content: space-between;
    align-items: center;
    
    .copyright {
      p {
        margin: 0;
        font-size: 14px;
        opacity: 0.8;
      }
    }
    
    .friend-links {
      display: flex;
      flex-wrap: wrap;
      align-items: center;
      gap: 15px;
      font-size: 14px;
      
      span {
        opacity: 0.8;
      }
      
      a {
        color: rgba(255, 255, 255, 0.8);
        text-decoration: none;
        transition: color 0.3s;
        position: relative;
        
        &::after {
          content: "";
          position: absolute;
          bottom: -2px;
          left: 0;
          width: 0;
          height: 1px;
          background-color: #fff;
          transition: width 0.3s;
        }
        
        &:hover {
          color: #fff;
          
          &::after {
            width: 100%;
          }
        }
      }
    }
  }
  
  @media (max-width: 768px) {
    .footer-bottom {
      flex-direction: column;
      text-align: center;
      
      .copyright {
        margin-bottom: 15px;
      }
      
      .friend-links {
        justify-content: center;
      }
    }
  }
}
</style> 