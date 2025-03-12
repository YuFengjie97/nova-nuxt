<script lang="ts" setup>
import type { MeydaAnalyzer } from 'meyda/dist/esm/meyda-wa'
import Meyda from 'meyda'
import spriteDoge from '/img/sprite_dance_doge.png'
import music from '/sound/savageLove.aac'

const spriteIndex = ref(0)
let _audio: HTMLAudioElement

let context: AudioContext
let source: MediaElementAudioSourceNode
let analyzer: MeydaAnalyzer

const zcrMap = new Map()
const zcrLine: number[] = []

const { updateFPS, updateSpriteFrame } = handleSpriteFrame()

function throttle(cb: (...args: any[]) => void, ms: number) {
  let lastTime = 0
  return function (this: any, ...args: any[]) {
    const now = performance.now()
    if (now - lastTime > ms) {
      cb.apply(this, args)
      lastTime = now
    }
  }
}

const slowUpdateFPS = throttle(updateFPS, 300)
const fastUpdateFPS = throttle(updateFPS, 100)

function initMeyda(audioEl: HTMLAudioElement) {
  context = new AudioContext()
  source = context.createMediaElementSource(audioEl)
  source.connect(context.destination)

  analyzer = Meyda.createMeydaAnalyzer({
    audioContext: context,
    source,
    bufferSize: 512, // or 1024/2048
    featureExtractors: ['zcr'],
    callback: (features: any) => {
      const zcr = features.zcr
      if (zcr !== 0) {
        if (zcrMap.has(zcr)) {
          zcrMap.set(zcr, zcrMap.get(zcr) + 1)
        }
        else {
          zcrMap.set(zcr, 1)
        }
      }

      zcrLine.push(zcr)
      const nor = 1.6 - constrain(0, 1.5, zcr / 20)

      if (nor < 1) {
        slowUpdateFPS(nor)
      }
      else {
        fastUpdateFPS(nor)
      }
    },
  })

  analyzer.start()
}

function handleSpriteFrame() {
  const fpsBase = 18
  let fps = fpsBase
  let frameInterval = 1000 / fps
  let lastFrameUpdateTime = performance.now()

  function updateFPS(normal: number) {
    fps = Math.ceil(fpsBase * normal)
    frameInterval = 1000 / fps
  }

  function updateSpriteFrame(frameIndex?: number) {
    const now = performance.now()
    if (frameIndex) {
      spriteIndex.value = frameIndex
    }
    if (now - lastFrameUpdateTime > frameInterval) {
      spriteIndex.value += 1
      lastFrameUpdateTime = now
    }
  }

  return {
    updateFPS,
    updateSpriteFrame,
  }
}

function play() {
  if (!_audio) {
    const audio = new Audio(music)
    _audio = audio
    initMeyda(audio)
  }
  if (_audio.paused) {
    _audio.play()
  }
  else {
    _audio.pause()
  }
}

function reset() {
  _audio.currentTime = 0
  _audio.play()
}

function animate() {
  if (analyzer && !_audio.paused) {
    updateSpriteFrame()
  }
  requestAnimationFrame(animate)
}

onMounted(() => {
  animate()
})

onUnmounted(() => {
  analyzer?.stop()
  source?.disconnect()
  context?.close()
  _audio?.pause()
})

function logzcrmap() {
  // const sortByKey = [...zcrMap.entries()].sort((a, b) => a[0] - b[0])
  // const keyMap = new Map(sortByKey)
  // const sortByVal = [...zcrMap.entries()].sort((a, b) => a[1] - b[1])
  // const total = sortByKey.reduce((acc, cur) => {
  //   return acc += cur[1]
  // }, 0)
  // console.log(sortByVal)
  // console.log('total', total)
  // console.log('出现最多次', sortByVal[sortByVal.length - 1][0], '次数', sortByVal[sortByVal.length - 1][1])

  // const avg = sortByKey.reduce((acc, cur) => {
  //   acc += cur[0] * cur[1]
  //   return acc
  // }, 0) / total

  // console.log('平均值', avg)

  // let count = 0
  // for (const [k, v] of keyMap) {
  //   count += v
  //   if (count >= Math.floor(total / 2)) {
  //     console.log('中位数', k, '次数', v)
  //     break
  //   }
  // }
  // console.log(zcrLine)
}
</script>

<template>
  <div class="h-100vh bg-#000 relative">
    <button @click="logzcrmap">
      log zcr
    </button>
    <button @click="() => { spriteIndex += 1 }">
      sprite + 1
    </button>
    <button @click="play">
      paly
    </button>
    <button @click="reset">
      reset
    </button>
    <Sprite class="sprite sprite-center" :num="12" :index="spriteIndex" :w="200" :h="200" :url="spriteDoge" />
    <Sprite class="sprite sprite-left" :num="12" :index="spriteIndex" :w="200" :h="200" :url="spriteDoge" />
    <Sprite class="sprite sprite-right" :num="12" :index="spriteIndex" :w="200" :h="200" :url="spriteDoge" />
  </div>
</template>

<style lang='less' scoped>
.sprite {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  -webkit-box-reflect: below 5px
    linear-gradient(to bottom, rgba(255, 255, 255, 0.266), transparent);
}
.sprite-left{
  top: 40%;
  left: 20%;
}

.sprite-right{
  top: 40%;
  left: 80%;
}
</style>
