<script lang="ts" setup>
import { runtimePath } from '#imports'

const rtPath = runtimePath('/docs/于风洁_前端开发_1-3年.md.pdf')
const isDownloading = ref(true)

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
  finally {
    isDownloading.value = false
  }
}

onMounted(async () => {
  await downloadPDF()
})
</script>

<template>
  <div class="w-full h-100vh">
    <div class="w-full h-full bg-#111 color-#fff font-size-30px letter-space flex justify-center items-center">
      <div v-if="isDownloading" class="flex">
        <span class="m-r-10px">downloading</span>
        <span class="point">.</span>
        <span class="point">.</span>
        <span class="point">.</span>
      </div>
      <div v-else>
        download done
      </div>
    </div>
  </div>
</template>

<style lang='less' scoped>
.point{
  display: block;
  margin-right: 4px;
  animation: bounce 0.75s ease-in-out infinite;
}
.point:nth-child(2) {
  animation-delay: 100ms;
}

.point:nth-child(3) {
  animation-delay: 200ms;
}
@keyframes bounce {
  0%{
    transform: translateY(0px);
  }
  50%{
    transform: translateY(-20px);
  }
  100%{
    transform: translateY(0px);
  }
}
</style>
