<script lang="ts" setup>
import { runtimePath } from '#imports'

const rtPath = runtimePath('/docs/于风洁_前端开发_1-3年.md.pdf')

async function downloadPDF() {
  const fileUrl = rtPath // PDF 文件地址

  try {
    const res = await fetch(fileUrl, {
      mode: 'cors',
    })

    const blob = await res.blob()
    const url = URL.createObjectURL(blob)

    const a = document.createElement('a')
    a.href = url
    a.download = '于风洁_前端开发_1-3年.pdf' // 下载后的文件名
    a.style.display = 'none'

    document.body.appendChild(a)
    a.click()

    URL.revokeObjectURL(url)
    document.body.removeChild(a)
  }
  catch (error) {
    console.error('下载失败', error)
  }
}

onMounted(async () => {
  await downloadPDF()
})
</script>

<template>
  <div />
</template>

<style lang='less' scoped>
</style>
