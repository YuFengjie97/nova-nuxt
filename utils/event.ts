export class EventEmitter {
  events: {
    [k in string]: ((...args: any[]) => void)[]
  }

  constructor() {
    this.events = {}
  }

  on(event: string, listener: (...args: any[]) => void) {
    if (!this.events[event]) {
      this.events[event] = []
    }
    this.events[event].push(listener)
  }

  emit(event: string, ...args: any[]) {
    if (this.events[event]) {
      this.events[event].forEach((fn) => {
        // fn.call(this, ...args)
        fn(...args)
      })
    }
  }

  off(event: string, listener: (...args: any[]) => void) {
    this.events[event] = this.events[event].filter(fn => fn !== listener)
  }
}
