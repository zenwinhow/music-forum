<template>
  <footer class="front-footer">
    <div class="footer-content">
      <div class="footer-container">
        <div class="footer-bottom">
          <div class="copyright">
            <p>&copy; {{ currentYear }} 音乐资源分享论坛 版权所有</p>
          </div>

          <div class="friend-links">
            <span>友情链接：</span>
            <a href="https://music.163.com" target="_blank">网易云音乐</a>
            <a href="https://y.qq.com" target="_blank">QQ音乐</a>
            <a href="https://github.com" target="_blank">GitHub</a>
          </div>
        </div>
      </div>
    </div>
  </footer>
</template>

<script setup>
import { computed } from 'vue'

const currentYear = computed(() => new Date().getFullYear())
</script>

<style lang="scss" scoped>
.front-footer {
  position: relative;
  width: 100%;

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

    .copyright p {
      margin: 0;
      font-size: 14px;
      opacity: 0.9;
    }

    .friend-links {
      display: flex;
      flex-wrap: wrap;
      align-items: center;
      gap: 15px;
      font-size: 14px;

      span {
        opacity: 0.9;
      }

      a {
        color: rgba(255, 255, 255, 0.9);
        text-decoration: none;
        transition: color 0.3s;
      }

      a:hover {
        color: #fff;
      }
    }
  }

  @media (max-width: 768px) {
    .footer-bottom {
      flex-direction: column;
      text-align: center;

      .copyright {
        margin-bottom: 12px;
      }

      .friend-links {
        justify-content: center;
      }
    }
  }
}
</style>
