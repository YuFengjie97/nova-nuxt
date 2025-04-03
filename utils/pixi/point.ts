import { Graphics } from 'pixi.js'

export class Point {
  color: string
  radius: number
  graphics = new Graphics()
  pos: Vector2 = new Vector2(0, 0)
  acc: Vector2 = new Vector2(0, 0)
  vel: Vector2 = new Vector2(0, 0)
  velBase = new Vector2(0, 0)
  negAccLen = 0.1
  width = 0
  height = 0

  constructor(color: string, radius: number) {
    this.color = color
    this.radius = radius
  }

  setEdge(width: number, height: number) {
    this.width = width
    this.height = height
    return this
  }

  setStartPos(...args: [number, number] | [Vector2]) {
    if (args.length === 2) {
      this.pos.set(...args as [number, number])
    }
    else {
      this.pos.set(...args as [Vector2])
    }
    return this
  }

  setVelBase(...args: [number, number] | [Vector2]) {
    if (args.length === 2) {
      this.velBase.set(...args as [number, number])
    }
    else {
      this.velBase.set(...args as [Vector2])
    }
    return this
  }

  updateAcc(vec2: Vector2) {
    this.acc.set(vec2)
    return this
  }

  update() {
    const negAcc = this.vel.clone().normalize().multiply(-this.negAccLen)
    this.vel.set(this.velBase)

    if (this.acc.length > this.negAccLen && this.acc.length > 0.1) {
      this.vel.add(this.acc.add(negAcc))
    }

    this.pos.add(this.vel)

    this.edge()
    this.draw()
  }

  draw() {
    const { x, y } = this.pos
    this.graphics.clear()
      .circle(x, y, this.radius)
      .fill(this.color)
  }

  edge() {
    const { width, height } = this
    const { x, y } = this.pos
    const gap = 20
    if (x <= -gap) {
      this.pos.x = width + gap
    }
    if (x >= width + gap) {
      this.pos.x = -gap
    }
    if (y <= -gap) {
      this.pos.y = height + gap
    }
    if (y >= height + gap) {
      this.pos.y = -gap
    }
  }
}
