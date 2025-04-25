<script lang="ts" setup>
</script>

<template>
  <div class="flex gap-10px flex-wrap p-10px">
    <div class="border">
      css
    </div>
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
    <NuxtLink to="music/dancedoge">
      狗子
    </NuxtLink>
    <div class="border">
      pixi
    </div>
    <NuxtLink to="pixi/begin">
      pixi
    </NuxtLink>
    <NuxtLink to="pixi/music">
      music
    </NuxtLink>
    <NuxtLink to="pixi/graphics">
      graphics
    </NuxtLink>
    <NuxtLink to="pixi/fire">
      fire
    </NuxtLink>
    <NuxtLink to="pixi/fire2">
      fire2
    </NuxtLink>
    <NuxtLink to="pixi/catmullRom">
      catmull-rom
    </NuxtLink>
    <NuxtLink to="pixi/lightning">
      lightning
    </NuxtLink>
    <NuxtLink to="pixi/noise">
      noise
    </NuxtLink>
    <NuxtLink to="pixi/bezierMove">
      bezierMove
    </NuxtLink>
    <NuxtLink to="pixi/wave">
      wave
    </NuxtLink>
    <NuxtLink to="canvas/wave">
      canvas  wave
    </NuxtLink>
    <NuxtLink to="pixi/bubble">
      bubble
    </NuxtLink>
    <NuxtLink to="pixi/smoke">
      smoke
    </NuxtLink>
    <div class="border">
      shader
    </div>
    <NuxtLink to="shader/fire">
      fire
    </NuxtLink>
    <NuxtLink to="shader/noiseMixed">
      noiseMixed
    </NuxtLink>
    <NuxtLink to="shader/hole">
      devil butt hole
    </NuxtLink>
    <NuxtLink to="shader/xielunyan">
      写轮眼
    </NuxtLink>
    <NuxtLink to="shader/xielunyan2">
      写轮眼-三勾玉
    </NuxtLink>
  </div>
</template>

<style lang="less" scoped>
a{
  display: block;
  background-color: rgb(52, 52, 52);
  padding: 10px 20px;
  color: #fff;
  border-radius: 4px;
  text-decoration: none;
}
.border{
  width: 100%;
  display: flex;
  justify-content: center;
  align-items: center;
  &::before, &::after{
    content: '';
    display: block;
    flex: 1;
    height: 0px;
    border: 2px solid black;
    border-radius: 2px;
    margin: 0px 20px;
  }
}
</style>
