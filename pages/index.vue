<script lang="ts" setup>
const runtimeConfig = useRuntimeConfig()

// eslint-disable-next-line no-console
console.log(runtimeConfig)
</script>

<template>
  <div class="flex gap-10px">
    <NuxtLink to="css/flipcardwall">
      css flip wall
    </NuxtLink>
    <NuxtLink to="css/sun">
      css animate sun
    </NuxtLink>
    <NuxtLink to="css/deathloading">
      css deathloading
    </NuxtLink>
    <NuxtLink to="css/hscard">
      css 炉石卡片
    </NuxtLink>
    <NuxtLink to="css/crushpic">
      css 破碎图片
    </NuxtLink>
    <NuxtLink to="css/jigsaw">
      css grid 拼图
    </NuxtLink>
    <NuxtLink to="canvas/imgpoint">
      canvas 图片点阵
    </NuxtLink>
    <NuxtLink to="css/typing">
      css 暗黑地牢打字
    </NuxtLink>
  </div>
</template>

<style>

</style>
