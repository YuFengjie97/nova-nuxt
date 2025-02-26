<script lang="ts" setup>
import animate from 'animejs'

const colors = ref(['#f368e0', '#ff9f43', '#ee5253', '#0abde3', '#10ac84'])
const progress = ref(0)

onMounted(() => {
  const timer = setInterval(() => {
    if (progress.value === 100) {
      clearInterval(timer)
    }
    let targetVal = progress.value + Math.floor(Math.random() * 40)
    targetVal = targetVal > 100 ? 100 : targetVal
    animate({
      targets: progress,
      value: targetVal,
      round: 1,
      easing: 'linear',
    })
  }, 1000)
})
</script>

<template>
  <div class="death-loading">
    <div class="petal-con">
      <div
        v-for="n in 5"
        :key="n"
        class="petal"
        :class="{
          petalFade: progress !== 100,
        }"
        :style="{
          '--color': colors[n - 1],
          'transform': `rotate(${(360 / 5) * n}deg)`,
          'background': colors[n - 1],
        }"
      />
    </div>
    <div class="progressCon">
      <div
        class="progress"
        :style="{
          '--progress': `${progress}%`,
        }"
      />
      <div class="val">
        {{ progress }}%
      </div>
    </div>
  </div>
</template>

<style lang="less" scoped>
.death-loading {
  position: relative;
  --size: 16rem;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  // transform-style: preserve-3d;
  // perspective: 400px;
  .petal-con {
    position: relative;
    width: var(--size);
    height: var(--size);
    display: flex;
    justify-content: center;
    transform-origin: center;
    transform: rotateX(30deg) skewX(-40deg);
  }
  .petal {
    --h: 68%;
    position: absolute;
    width: 20%;
    height: 45%;
    transform-origin: 50% 104%;
    clip-path: polygon(50% 0, 100% var(--h), 50% 100%, 0% var(--h));
    transition: 0.3s;
  }
  .petalFade {
    animation: fade 2.5s infinite;
  }
  .progressCon {
    width: 150%;
    display: flex;
    flex-wrap: nowrap;
    align-items: center;
  }
  .progress {
    display: inline-block;
    width: 100%;
    height: 12px;
    padding: 2px 4px;
    border: 2px solid #48dbfb;
    border-width: 2px 4px;
    position: relative;
    padding: 1px 2px;
    &::before {
      position: absolute;
      top: 50%;
      left: 0;
      transform: translateY(-50%);
      display: inline-block;
      content: '';
      background: #0abde3;
      height: 50%;
      width: var(--progress);
      transition: 0.3s;
    }
  }
  .val {
    margin-left: 0.5rem;
    width: 16%;
    display: inline-block;
    color: #48dbfb;
  }
  .petal:nth-child(1) {
    animation-delay: 0s;
  }
  .petal:nth-child(2) {
    animation-delay: 0.5s;
  }
  .petal:nth-child(3) {
    animation-delay: 1s;
  }
  .petal:nth-child(4) {
    animation-delay: 1.5s;
  }
  .petal:nth-child(5) {
    animation-delay: 2s;
  }
  @keyframes fade {
    0% {
      opacity: 0;
    }

    2% {
      opacity: 0.6;
    }

    4% {
      opacity: 0.4;
    }

    6% {
      opacity: 0.8;
    }

    8% {
      opacity: 0.4;
    }

    10% {
      opacity: 1;
    }

    80% {
      opacity: 0;
    }

    100% {
      opacity: 0;
    }
  }
}
</style>
