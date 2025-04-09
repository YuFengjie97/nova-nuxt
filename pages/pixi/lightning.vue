<script lang="ts" setup>
import { Application, Container, Graphics, Rectangle } from 'pixi.js'
import { createNoise2D } from 'simplex-noise'
import { Pane } from 'tweakpane'

const pixiCon = ref<HTMLElement>()
const app = new Application()
const { atan2, sin, cos, PI } = Math

const noise2d = createNoise2D()

const fbmOptions = {
  octaves: 3,
  lacunarity: 2, // 间隙度,调高频率
  gain: 0.5, // 减益,降低振幅
  amplitude: 1.0,
  frequency: 1.0,
}
const useNoiseOrFbm = {
  useNoise: true,
}

function fbmPane(pane: Pane) {
  const folder = pane.addFolder({ title: 'fbm' })
  folder.addBinding(fbmOptions, 'octaves', { min: 1, max: 8, step: 1 })
  folder.addBinding(fbmOptions, 'lacunarity', { min: 0.1, max: 4, step: 0.01 })
  folder.addBinding(fbmOptions, 'gain', { min: 0.1, max: 2, step: 0.01 })
  folder.addBinding(fbmOptions, 'amplitude', { min: 0.1, max: 2, step: 0.01 })
  folder.addBinding(fbmOptions, 'frequency', { min: 0.1, max: 2, step: 0.01 })
  folder.disabled = true

  pane.addBinding(useNoiseOrFbm, 'useNoise').on('change', (event) => {
    folder.disabled = event.value
  })
}

interface ModelParam {
  segementNum: number
  noiseBase: number
  amp: number
  speed: number
}

class Lightning {
  app: Application
  group = new Container()
  controls: Map<Graphics, Vector2> = new Map()
  points: Vector2[] = []
  pathGraph = new Graphics()
  offset: number = 0
  modelParams: Array<ModelParam> = []
  offsets: Map<ModelParam, number> = new Map()

  dragControl: Graphics | null = null

  constructor(app: Application) {
    this.app = app
    app.stage.addChild(this.group)
    this.group.addChild(this.pathGraph)

    this.app.stage.on('pointermove', (event) => {
      const { dragControl } = this
      if (!dragControl) {
        return
      }
      const { x, y } = event.getLocalPosition(this.group)
      this.controls.get(dragControl)?.set(x, y)
    })

    this.app.stage.on('pointerleave', () => {
      this.dragControl = null
    })
  }

  changeModelParam(modelParam: ModelParam, key: keyof ModelParam, val: number) {
    this.modelParams.forEach((item) => {
      if (item === modelParam) {
        item[key] = val
      }
    })
  }

  addModelParam(param: ModelParam) {
    this.modelParams.push(param)
    this.offsets.set(param, 0)
  }

  addControls(pos: Vector2) {
    const graph = new Graphics()
    this.group.addChild(graph)
    this.controls.set(graph, pos)

    graph.eventMode = 'static'
    graph.on('pointerdown', () => {
      this.dragControl = graph
    })
    graph.on('pointerup', () => {
      this.dragControl = null
    })
  }

  // 通过控制点和catmullRom算法来计算光滑曲线
  catmullRomPoints(segementNum: number) {
    const { points } = this
    const first = points[0]
    const last = points[points.length - 1]
    points.unshift(first)
    points.push(last)

    const segementPoints: Vector2[] = []
    for (let i = 1; i < points.length - 2; i++) {
      const p0 = points[i - 1]
      const p1 = points[i]
      const p2 = points[i + 1]
      const p3 = points[i + 2]
      const segement = catmullRomPoint(p0, p1, p2, p3, segementNum)

      segementPoints.push(...segement)
    }

    this.points = segementPoints
  }

  // 对catmullRom光滑曲线做噪音处理
  noisePoints(noiseBase: number, amp: number, offset: number) {
    const { points } = this
    const noisePoints: Vector2[] = []
    const lightningLen = this.length

    for (let i = 0, len = points.length; i < len; i++) {
      const p = points[i]
      const next = i === len - 1 ? p : points[i + 1]
      const dy = next.y - p.y
      const dx = next.x - p.x
      const angle = atan2(dy, dx)

      const base = i / noiseBase

      let av
      if (useNoiseOrFbm.useNoise) {
        av = lightningLen * 0.1 * noise2d(base - offset, offset) * amp
      }
      else {
        av = lightningLen * 0.1 * fbm2D(base - offset, offset, fbmOptions) * amp
      }
      const ax = av * cos(angle - PI / 2)
      const ay = av * sin(angle - PI / 2)

      let bv
      if (useNoiseOrFbm.useNoise) {
        bv = lightningLen * 0.1 * noise2d(base + offset, offset) * amp
      }
      else {
        bv = lightningLen * 0.1 * fbm2D(base + offset, offset, fbmOptions) * amp
      }
      const bx = bv * cos(angle + PI / 2)
      const by = bv * sin(angle + PI / 2)

      // 减轻两端的噪音
      const m = Math.sin(i / len * Math.PI)

      const x = p.x + (ax + bx) * m
      const y = p.y + (ay + by) * m

      const np = new Vector2(x, y)
      noisePoints.push(np)
    }

    this.points = noisePoints
  }

  // 点距筛选,避免绕环打结
  shortestPoints() {
    const { points } = this
    const shortest: Vector2[] = [points[0]]
    for (let i = 0; i < points.length; i++) {
      const p = points[i]
      let minDist = Infinity

      let k = -1
      for (let j = i + 1; j < points.length; j++) {
        const next = points[j]
        const dist = next.dist(p)

        if (next !== p && dist < minDist) {
          minDist = dist
          k = j
        }
      }

      if (k !== -1) {
        shortest.push(points[k])
        i = k - 1 // k-1而不是k,是为了尽量保证连续性
      }
    }

    this.points = shortest
  }

  get length() {
    const { points } = this
    let len = 0
    for (let i = 1; i < points.length; i++) {
      const dist = points[i].dist(points[i - 1])
      len += dist
    }
    return len
  }

  update() {
    const points = Array.from(this.controls.values())
    this.points = points

    for (let i = 0; i < this.modelParams.length; i++) {
      const modelParam = this.modelParams[i]
      const { segementNum, noiseBase, amp, speed } = modelParam
      const offset = (this.offsets.get(modelParam) as number) + Math.random() * speed
      this.offsets.set(modelParam, offset)

      this.catmullRomPoints(segementNum)
      this.noisePoints(noiseBase, amp, offset)
      this.shortestPoints()
    }
  }

  draw() {
    const { points, controls } = this
    for (const [graph, pos] of controls.entries()) {
      const { x, y } = pos
      graph.clear()
        .circle(x, y, 20)
        .fill({ color: 'red' })
    }

    const fir = points[0]
    if (fir) {
      this.pathGraph.clear()
        .moveTo(fir.x, fir.y)
      for (let i = 1; i < this.points.length; i++) {
        const { x, y } = points[i]
        this.pathGraph.lineTo(x, y)
      }
      this.pathGraph.stroke({ color: 'rgb(74, 231, 255)', width: 4, join: 'round' })
    }
  }
}

const modelParam1 = { segementNum: 8, noiseBase: 10, amp: 0.7, speed: 0.01 }
const modelParam2 = { segementNum: 16, noiseBase: 60, amp: 0.5, speed: 0.03 }

function modelParamPane(pane: Pane, title: string, lightning: Lightning, modelParam: ModelParam) {
  const folder = pane.addFolder({ title })
  folder.addBinding(modelParam, 'amp', { min: 0.1, max: 2, step: 0.1 }).on('change', (event) => {
    lightning.changeModelParam(modelParam, 'amp', event.value)
  })
  folder.addBinding(modelParam, 'speed', { min: 0.01, max: 0.2, step: 0.01 }).on('change', (event) => {
    lightning.changeModelParam(modelParam, 'amp', event.value)
  })
}

onMounted(async () => {
  await app.init({ background: '#111', resizeTo: pixiCon.value, antialias: true })
  app.stage.eventMode = 'static'
  app.stage.hitArea = new Rectangle(0, 0, app.screen.width, app.screen.height)
  pixiCon.value?.appendChild(app.canvas)

  const lightning = new Lightning(app)

  const pane = new Pane()
  fbmPane(pane)
  modelParamPane(pane, 'modelParam_1', lightning, modelParam1)
  modelParamPane(pane, 'modelParam_2', lightning, modelParam2)

  lightning.addModelParam(modelParam1)
  lightning.addModelParam(modelParam2)
  lightning.addControls(new Vector2(100, 100))
  lightning.addControls(new Vector2(300, 300))
  lightning.addControls(new Vector2(600, 300))
  lightning.addControls(new Vector2(800, 500))

  lightning.draw()

  app.ticker.add(() => {
    lightning.update()
    lightning.draw()
  })
})

onUnmounted(() => {
  app.destroy(true, { children: true, texture: true })
})
</script>

<template>
  <div ref="pixiCon" class="w-full h-100vh" />
</template>

<style lang='less' scoped>
.d{
  color: rgb(74, 231, 255);
}
</style>
