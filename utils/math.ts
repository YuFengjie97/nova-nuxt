import { Vector2, Vector3 } from 'three'

export function getTriangleCenter<T>(p1: T, p2: T, p3: T): T {
  if (p1 instanceof Vector2 && p2 instanceof Vector2 && p3 instanceof Vector2)
    return new Vector2().copy(p1).add(p2).add(p3).multiplyScalar(1 / 3) as T
  else if (p1 instanceof Vector3 && p2 instanceof Vector3 && p3 instanceof Vector3)
    return new Vector3().copy(p1).add(p2).add(p3).multiplyScalar(1 / 3) as T
  throw new Error('类型错误')
}

export type Vec3 = [number, number, number]
// http://dev.thi.ng/gradients/
export function initPalette(a: Vec3, b: Vec3, c: Vec3, d: Vec3): (t: number) => Vec3 {
  const cos = Math.cos
  const TWO_PI = Math.PI * 2
  return function (t: number) {
    const v3 = [0, 0, 0].map((item, i) => {
      const v = a[i] + b[i] * cos(TWO_PI * (c[i] * t + d[i]))
      return v
    }) as Vec3

    return v3
  }
}

export function vec3ToRgb(v: Vec3) {
  const r = map(v[0], 0, 1, 0, 255)
  const g = map(v[1], 0, 1, 0, 255)
  const b = map(v[2], 0, 1, 0, 255)
  return `rgb(${r},${g},${b})`
}

export function lerp(s: number, e: number, t: number) {
  return (e - s) * t + s
}

export function constrain(min: number, max: number, val: number) {
  if (val < min) {
    return min
  }
  if (val > max) {
    return max
  }
  return val
}

export function map(value: number, start1: number, stop1: number, start2: number, stop2: number, withinBounds = true) {
  if (withinBounds) {
    if (value < start1) {
      return start2
    }
    if (value > stop1) {
      return stop2
    }
  }
  const nor = (value - start1) / (stop1 - start1)
  return nor * (stop2 - start2)
}
