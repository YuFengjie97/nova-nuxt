import type { Application } from 'pixi.js'
import { Container, Graphics } from 'pixi.js'

export class ProgressBar {
  app: Application
  size: { w: number, h: number }
  group = new Container()
  progressBottom = new Graphics()
  progress = new Graphics()
  constructor(app: Application, size: { w: number, h: number }) {
    this.app = app
    this.size = size
    const { w, h } = size

    app.stage.addChild(this.group)

    this.progressBottom.rect(0, 0, w, h)
      .fill({ color: '#00b894' })

    this.progressBottom.eventMode = 'static'
    this.progressBottom.cursor = 'pointer'

    this.group.addChild(this.progressBottom)
    this.group.addChild(this.progress)
  }

  draw(val: number) {
    this.progress.clear()
    this.progress
      .rect(0, 0, this.size.w * val, this.size.h)
      .fill({ color: '#81ecec' })
  }

  onClick(cb: (percentile: number) => void) {
    this.progressBottom.on('pointerdown', (event) => {
      const { x } = event.getLocalPosition(this.group)
      const percentile = x / this.size.w
      cb(percentile)
      this.draw(percentile)
    })

    return this
  }

  update(val: number) {
    this.draw(val)
  }
}
