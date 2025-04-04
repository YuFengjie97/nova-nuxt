import type { Application } from 'pixi.js'
import { Stats } from 'pixi-stats'

export class PixiStatsWrap {
  stats: Stats
  app: Application
  constructor(app: Application) {
    this.app = app
    this.stats = new Stats(app.renderer)
  }

  destory() {
    if (!this.stats) {
      return
    }
    const dom = this.stats.domElement
    const parent = dom.parentNode
    if (parent) {
      parent.removeChild(dom)
    }

    this.app?.ticker?.remove(this.stats.update)
  }
}
