<script lang="ts" setup>
import pic from '/img/disco_communism.jpg'

const str = `一个幽灵，共产主义的幽灵，在欧洲游荡。为了对这个幽灵进行神圣的围剿，旧欧洲的一切势力，教皇和沙皇、梅特涅和基佐、法国的激进派和德国的警察，都联合起来了。
有哪一个反对党不被它的当政的敌人骂为共产党呢？又有哪一个反对党不拿共产主义这个罪名去回敬更进步的反对党人和自己的反动敌人呢？
从这一事实中可以得出两个结论：
共产主义已经被欧洲的一切势力公认为一种势力；
现在，我们眼前又进行着类似的运动。
资产阶级的生产关系和交换关系，资产阶级的所有制关系，
这个曾经仿佛用法术创造了如此庞大的生产资料和交换手段的现代资产阶级社会，
现在像一个魔法师一样不能再支配自己用法术呼唤出来的魔鬼了。几十年来的工业和商业的历史，
只不过是现代生产力反抗现代生产关系、反抗作为资产阶级及其统治的存在条件的所有制关系的历史。
只要指出在周期性的重复中越来越危及整个资产阶级社会生存的商业危机就够了。在商业危机期间，
总是不仅有很大一部分制成的产品被毁灭掉，而且有很大一部分已经造成的生产力被毁灭掉。在危机期间，
发生一种在过去一切时代看来都好像是荒唐现象的社会瘟疫，即生产过剩的瘟疫。
社会突然发现自己回到了一时的野蛮状态；仿佛是一次饥荒、一场普遍的毁灭性战争，
使社会失去了全部生活资料；仿佛是工业和商业全被毁灭了。这是什么缘故呢？
因为社会上文明过度，生活资料太多，工业和商业太发达。社会所拥有的生产力已
经不能再促进资产阶级文明和资产阶级所有制关系的发展；相反，生产力已经强大
到这种关系所不能适应的地步，它已经受到这种关系的阻碍；而它一着手克服这种
障碍，就使整个资产阶级社会陷入混乱，就使资产阶级所有制的存在受到威胁。资产
阶级的关系已经太狭窄了，再容纳不了它本身所造成的财富了。资产阶级用什么办法
来克服这种危机呢？一方面不得不消灭大量生产力，另一方面夺取新的市场，更加彻
底地利用旧的市场。这究竟是怎样的一种办法呢？这不过是资产阶级准备更全面更猛
烈的危机的办法，不过是使防止危机的手段越来越少的办法。`

const con = ref<HTMLElement>()
const conRect = ref<DOMRect>()
const list = ref<Array<{ name: string, bg: string, flip: boolean }>>([])

function resolve() {
  let i = 0
  while (i < str.length) {
    const length = 3 + Math.floor(Math.random() * 6)
    const s = str.slice(i, i + length)
    i += length
    const item = {
      name: s,
      bg: pic,
      flip: false,
    }
    list.value.push(item)
  }
}

function initConDomRect() {
  conRect.value = con.value!.getBoundingClientRect()
}
async function animateReverseCard() {
  for (let i = 0; i < list.value.length; i += 1) {
    list.value[i].flip = true
    if (i === 0)
      continue
    list.value[i - 1].flip = false

    await sleep(750)
  }
}

onMounted(async () => {
  resolve()
  initConDomRect()
  await animateReverseCard()
})
</script>

<template>
  <div ref="con" class="w-full h-full min-h-100vh flex flex-wrap p-y-40px p-x-70px bg-red justify-center items-center">
    <FlipCard v-for="(item, i) in list" :key="i" v-bind="item" :con-dom-rect="conRect" />
  </div>
</template>
