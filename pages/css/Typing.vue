<script lang="ts" setup>
import sound1 from '/sound/typing/typing_1.mp3'
import sound2 from '/sound/typing/typing_2.mp3'
import sound3 from '/sound/typing/typing_3.mp3'
import sound4 from '/sound/typing/typing_4.mp3'
import sound5 from '/sound/typing/typing_5.mp3'
import soundWrap from '/sound/typing/typing_wrap.mp3'

interface Sound {
  path: string
  ms: number
}

const typingSounds: Sound[] = [
  { path: sound1, ms: 171 },
  { path: sound2, ms: 216 },
  { path: sound3, ms: 210 },
  { path: sound4, ms: 167 },
]

const typingSoundSpace: Sound = { path: sound5, ms: 216 + 180 }
const typingSoundWrap: Sound = { path: soundWrap, ms: 2052 }

function getTypingSound(char: string) {
  const ind = char.toString().charCodeAt(0)
  const len = typingSounds.length
  return typingSounds[ind % len]
}

function playSound(sound: Sound) {
  return new Promise((resolve) => {
    const audio = new Audio(sound.path)
    audio.play()
    setTimeout(() => {
      resolve('')
    }, sound.ms - 40)
  })
}

const text = `Ruin has come to our family.
You remember our venerable house, opulent and imperial.
Gazing proudly from its stoic perch above the moor.
I lived all my years in that ancient, rumor-shadowed manor.
Fattened by decadence and luxury.
And yet, I began to tire of conventional extravagance.
Singular, unsettling tales suggested the mansion itself was a gateway to some fabulous and unnamable power.
With relic and ritual, I bent every effort towards the excavation and recovery of those long-buried secrets, exhausting what remained of our family fortune on swarthy workmen and sturdy shovels.
At last, in the saltsoaked crags beneath the lowest foundations we unearthed that damnable portal of antediluvian evil.
Our every step unsettled the ancient earth but we were in a realm of death and madness!
In the end, I alone fled laughing and wailing through those blackened arcades of antiquity.
Until consciousness failed me.
You remember our venerable house, opulent and imperial.
It is a festering abomination!
I beg you, return home, claim your birthright, and deliver our family from the ravenous clutching shadows of the Darkest Dungeon.
`

class CharWrap {
  index: number
  char: string

  constructor(index: number, char: string) {
    this.index = index
    this.char = char
  }
}

const chars = ref<CharWrap[]>([])
const charWrap = ref<HTMLElement>()

let ind = 0

onMounted(async () => {
  while (ind < text.length) {
    const char = text[ind]
    const charWrap = new CharWrap(ind, char)
    ind += 1

    if (char === '\n') {
      await playSound(typingSoundWrap)
      chars.value.push(charWrap)
    }
    else {
      const sound = char === ' ' ? typingSoundSpace : getTypingSound(char)
      chars.value.push(charWrap)
      await playSound(sound)
    }
  }
})
onUnmounted(() => {
  ind = Infinity
})
</script>

<template>
  <div class="bg-black min-h-100vh p-x-60px p-y-40px">
    <div ref="charWrap" class="char-wrap">
      <template v-for="(char, i) in chars" :key="i">
        <br v-if="char.char === `\n`">
        <span v-else class="char">{{ char.char }}</span>
      </template>
      <div class="cursor shine" />
    </div>
  </div>
</template>

<style lang="less" scoped>
@font-face {
  font-family: 'DwarvenAxe';
  src: url('/fonts/DwarvenAxe BB W00 Regular.ttf') format('woff');
}

.char-wrap {
  --font-size: 40px;
  font-size: var(--font-size);
  font-family: DwarvenAxe;
  color: hsl(36, 73%, 46%);
  letter-spacing: 2px;
}

.char {
  transition: all .4s;
}

@keyframes shine {
  0% {
    background: rgba(177, 228, 227, 1);
  }

  50% {
    background: rgba(177, 228, 227, 0);
  }

  100% {
    background: rgba(177, 228, 227, 1);
  }
}

.shine {
  animation: shine .6s ease-in-out infinite;

  &::before {
    animation: shine .6s ease-in-out infinite;
  }

  &::after {
    animation: shine .6s ease-in-out infinite;

  }
}

.cursor {
  --color: rgba(177, 228, 227, 1);
  display: inline-block;
  height: var(--font-size);
  width: 2px;
  background: var(--color);
  margin-left: 4px;
  transform: translate(6px, 10px);
  transition-timing-function: ease-out;
  transition: all 0.4s;

  &::before {
    border-radius: 4px;
    position: absolute;
    content: "";
    top: 0;
    left: 50%;
    transform: translateX(-50%);
    width: 6px;
    height: 2px;
    background: var(--color);
  }

  &::after {
    border-radius: 4px;
    position: absolute;
    content: "";
    bottom: 0;
    left: 50%;
    transform: translateX(-50%);
    width: 6px;
    height: 2px;
    background: var(--color);
  }
}
</style>
