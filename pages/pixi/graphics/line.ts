import type { Application } from 'pixi.js'
import { Container, Graphics } from 'pixi.js'

export interface Coord {
  x: number
  y: number
}

export class Line {
  coords: Coord[] = []
  grahp = new Graphics()
  group = new Container()
  constructor(app: Application) {
    this.group.addChild(this.grahp)
    app.stage.addChild(this.group)
  }

  update(coords: Coord[]) {
    this.coords = coords
    this.draw()
  }

  draw() {
    this.grahp.clear()
    const start = this.coords[0]
    this.grahp.moveTo(start.x, start.y)
    for (let i = 0; i < this.coords.length; i++) {
      const { x, y } = this.coords[i]
      this.grahp.lineTo(x, y)
    }
    this.grahp.stroke({ color: 'red', width: 10, join: 'round', cap: 'round' })
  }

  setPos(x: number, y: number) {
    this.group.position.set(x, y)
    return this
  }
}
