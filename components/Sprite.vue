<script lang="ts" setup>
interface Sprite {
  url: string
  index?: number
  num: number
  w: number
  h: number
}

const props = withDefaults(defineProps<Sprite>(), {
  index: 0,
})

const sprite = ref<HTMLElement>()

const style = computed(() => {
  const x = -1 * (props.index % props.num) * props.w
  const y = 0
  return {
    'background-image': `url(${props.url})`,
    'background-position': `${x}px ${y}px`,
  }
})
</script>

<template>
  <div :style="{ width: `${w}px`, height: `${h}px` }">
    <div ref="sprite" class="sprite" :style="style" />
  </div>
</template>

<style lang='less' scoped>
.sprite {
  width: 100%;
  height: 100%;
  background-repeat: no-repeat;
  background-size: auto 100%;
}
</style>
