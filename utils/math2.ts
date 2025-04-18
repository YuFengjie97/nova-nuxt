import { createNoise2D } from 'simplex-noise'

const noise2d = createNoise2D()

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

export function lerpArrBySize(arr: number[], targetSize: number, byMax?: boolean) {
  const multiplier = arr.length / targetSize
  const res: number[] = []
  for (let i = 0; i < targetSize; i++) {
    const point = i * multiplier
    const valueLeft = arr[Math.max(0, Math.floor(point))]
    const valueRight = arr[Math.min(arr.length - 1, Math.ceil(point))]

    let value
    if (byMax) {
      value = Math.max(valueLeft, valueRight)
    }
    else {
      const t = point % 1
      value = valueLeft * (1 - t) + valueRight * t
    }
    res.push(value)
  }
  return res
}

// https://thebookofshaders.com/13/?lan=ch
export function fbm2D(x: number, y: number, fbmOptions: { octaves: number, lacunarity: number, gain: number, amplitude: number, frequency: number }) {
  const { octaves, lacunarity, gain, amplitude, frequency } = fbmOptions

  let fre = frequency
  let amp = amplitude

  let res = 0

  for (let i = 0; i < octaves; i++) {
    res += amp * noise2d(fre * x, fre * y)
    fre *= lacunarity
    amp *= gain
  }

  return res
}

export function catmullRom(p0: number, p1: number, p2: number, p3: number, t: number) {
  const v0 = (p2 - p0) * 0.5
  const v1 = (p3 - p1) * 0.5
  return (2 * p1 - 2 * p2 + v0 + v1) * t * t * t
    + (-3 * p1 + 3 * p2 - 2 * v0 - v1) * t * t + v0 * t + p1
}

export function catmullRomPoint(p0: Vector2, p1: Vector2, p2: Vector2, p3: Vector2, segementNum: number) {
  const points: Vector2[] = []
  for (let i = 0; i < segementNum; i++) {
    const t = (i + 1) / segementNum
    const x = catmullRom(p0.x, p1.x, p2.x, p3.x, t)
    const y = catmullRom(p0.y, p1.y, p2.y, p3.y, t)
    points.push(new Vector2(x, y))
  }
  return points
}

export function randomRange(min: number, max: number) {
  const { random } = Math
  return random() * (max - min) + min
}

export function times(count: number, fn: (n?: number) => void) {
  for (let i = 0; i < count; i++) {
    fn(i)
  }
}
