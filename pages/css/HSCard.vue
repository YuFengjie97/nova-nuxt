<script lang="ts" setup>
import back from '/img/hs/back.png'
import card1 from '/img/hs/card1.png'
import card2 from '/img/hs/card2.png'
import card3 from '/img/hs/card3.png'
import card4 from '/img/hs/card4.png'
import card5 from '/img/hs/card5.png'
</script>

<template>
  <div class="w-full min-h-100vh p-y-20px flex flex-wrap justify-center items-center view-con">
    <FlipHSCard :back-img="back" :front-img="card1" />
    <FlipHSCard :back-img="back" :front-img="card2" />
    <FlipHSCard :back-img="back" :front-img="card3" />
    <FlipHSCard :back-img="back" :front-img="card4" />
    <FlipHSCard :back-img="back" :front-img="card5" />
  </div>
</template>

<style lang="less" scoped>
.view-con {
  background-image: linear-gradient(60deg, #c0392b 50%, #2980b9 80%);
}
</style>
