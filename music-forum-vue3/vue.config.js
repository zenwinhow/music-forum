const { defineConfig } = require('@vue/cli-service')
module.exports = defineConfig({
  transpileDependencies: true,
  pages: {
    index: {
      entry: 'src/main.js',
      title: 'music-forum音乐论坛'
    }
  },
  devServer: {
    proxy: {
      '/api': {
        target: 'http://localhost:10086',
        changeOrigin: true,
        // pathRewrite: {
        //   '^/api': ''
        // }
      }
    },
    client: {
      overlay: false
    }
  }
})
