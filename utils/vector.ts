export class Vector2 {
  x: number
  y: number

  constructor(x: number, y: number)
  constructor(vec2: Vector2)
  constructor(...args: [number, number] | [Vector2]) {
    if (args.length === 2) {
      const [x, y] = args
      this.x = x
      this.y = y
    }
    else {
      const vec2 = args[0] as Vector2
      this.x = vec2.x
      this.y = vec2.y
    }
  }

  set(x: number, y: number): Vector2
  set(vec2: Vector2): Vector2
  set(...args: [number, number] | [Vector2]) {
    if (args.length === 2) {
      const [x, y] = args
      this.x = x
      this.y = y
    }
    else {
      const vec2 = args[0]
      this.x = vec2.x
      this.y = vec2.y
    }
    return this
  }

  add(vec2: Vector2) {
    this.x += vec2.x
    this.y += vec2.y
    return this
  }

  multiply(arg: number): Vector2
  multiply(arg: Vector2): Vector2
  multiply(arg: number | Vector2): Vector2 {
    if (arg instanceof Vector2) {
      this.x *= arg.x
      this.y *= arg.y
    }
    else {
      this.x *= arg
      this.y *= arg
    }

    return this
  }

  clone() {
    return new Vector2(this.x, this.y)
  }

  normalize() {
    const len = this.length
    if (len === 0) {
      return this
    }
    this.x /= len
    this.y /= len
    return this
  }

  set length(val: number) {
    if (val < 0) {
      throw new Error('长度设置需要大于0')
    }
    if (val === 0) {
      this.x = 0
      this.y = 0
    }
    else {
      this.normalize().multiply(val)
    }
  }

  get length() {
    return Math.sqrt(this.x ** 2 + this.y ** 2)
  }

  toArray(): [number, number] {
    return [this.x, this.y]
  }

  toString(): string {
    return `Vector2(${this.x}, ${this.y})`
  }
}
