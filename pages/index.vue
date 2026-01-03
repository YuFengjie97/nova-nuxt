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
    <NuxtLink to="shader/sdfGouyu">
      sdf 勾玉
    </NuxtLink>
    <a :href="runtimePath('/html/raymarching3D2.html')">
      rayMarching 3D
    </a>
    <div class="border">
      three.js
    </div>
    <nuxt-link to="three/test">
      test
    </nuxt-link>
    <nuxt-link to="three/plane">
      plane 自定义顶点,三角形索引算错了
    </nuxt-link>
    <nuxt-link to="three/plane2">
      plane2 使用planeGeometry来修改顶点,无需设置索引
    </nuxt-link>
    <nuxt-link to="three/plane3">
      plane3 直接使用顶点着色器来顶点偏移
    </nuxt-link>
    <nuxt-link to="three/sample">
      sample 几何体表面取样
    </nuxt-link>
    <nuxt-link to="three/texture">
      texture
    </nuxt-link>
    <nuxt-link to="three/points">
      points点云+纹理
    </nuxt-link>
    <nuxt-link to="three/solarSystem">
      太阳系
    </nuxt-link>
    <nuxt-link to="three/tank">
      坦克
    </nuxt-link>
    <nuxt-link to="three/light">
      光源
    </nuxt-link>
    <nuxt-link to="three/lightRectArea">
      区域光
    </nuxt-link>
    <nuxt-link to="three/earthBar">
      地球柱子
    </nuxt-link>
    <nuxt-link to="three/earthBar2">
      地球柱子2 使用Object3D组合生成世界矩阵来获取geo位置
    </nuxt-link>
    <nuxt-link to="three/geoJson">
      地图geo几何体
    </nuxt-link>
    <nuxt-link to="three/texture2">
      texture2 多种属性材质 loaderManager
    </nuxt-link>
    <nuxt-link to="three/textGeo">
      文字Geo
    </nuxt-link>
    <nuxt-link to="three/lightCamera">
      光源camera -> shadowMap
    </nuxt-link>
    <nuxt-link to="three/ghostHouse">
      鬼屋
    </nuxt-link>
    <nuxt-link to="three/particle">
      粒子
    </nuxt-link>
    <nuxt-link to="three/galaxy">
      粒子银河
    </nuxt-link>
    <nuxt-link to="three/profile">
      html 结合 three 视差滚动
    </nuxt-link>
    <nuxt-link to="three/rawShaderMatTest">
      rawShaderMat test
    </nuxt-link>
    <nuxt-link to="three/sea">
      海洋 shaderMat
    </nuxt-link>
    <nuxt-link to="three/textTransform">
      字体点云变换
    </nuxt-link>
    <nuxt-link to="three/smoke">
      smoke 噪音材质
    </nuxt-link>
    <nuxt-link to="three/hologram">
      全息效果模型
    </nuxt-link>
    <nuxt-link to="three/flowParticle">
      flow 粒子
    </nuxt-link>
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
