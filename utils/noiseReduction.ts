export function dataProcessor(_data: number[]) {
  let data = _data

  return {
    avgNormalChian(size: number) {
      data = avgNormal(data, size)
      return this
    },
    smoothChian(windowSize = 3) {
      data = smooth(data, windowSize)
      return this
    },
    powerChian(expont = 1.7) {
      data = power(data, expont)
      return this
    },
    normalizeChain(max?: number) {
      data = normalize(data, max)
      return this
    },
    get data() {
      return data
    },
  }
}

// 将一组数据转换为指定size的平均数据
export function avgNormal(data: number[], targetSize: number) {
  const res = []
  const step = Math.floor(data.length / targetSize)
  for (let i = 0; i < data.length; i += step) {
    const end = Math.min(i + step, data.length)
    const slice = data.slice(i, end)
    const avg = slice.reduce((acc, cur) => acc + cur, 0) / slice.length
    res.push(avg)
  }
  return res
}

// 滑动平均
export function smooth(data: number[], windowSize = 3): number[] {
  const result: number[] = []
  const half = Math.floor(windowSize / 2)

  for (let i = 0; i < data.length; i++) {
    let sum = 0
    let count = 0
    for (let j = -half; j <= half; j++) {
      const idx = i + j
      if (idx >= 0 && idx < data.length) {
        sum += data[idx]
        count++
      }
    }
    result.push(sum / count)
  }
  return result
}

// 滑动平均的基础上加了权重
export function weightedSmooth(data: number[]): number[] {
  const weights = [0.25, 0.5, 0.25]
  const result: number[] = []

  for (let i = 0; i < data.length; i++) {
    const left = data[i - 1] ?? data[i]
    const center = data[i]
    const right = data[i + 1] ?? data[i]
    const avg = left * weights[0] + center * weights[1] + right * weights[2]
    result.push(avg)
  }

  return result
}

// 中值过滤,滑动窗口取中值
export function medianFilter(data: number[], windowSize = 3): number[] {
  const half = Math.floor(windowSize / 2)
  const result: number[] = []

  for (let i = 0; i < data.length; i++) {
    const window: number[] = []
    for (let j = -half; j <= half; j++) {
      const idx = i + j
      if (idx >= 0 && idx < data.length) {
        window.push(data[idx])
      }
    }
    window.sort((a, b) => a - b)
    result.push(window[Math.floor(window.length / 2)])
  }
  return result
}

// 使用指数来加强特征
export function power(data: number[], expont: number) {
  return data.map(item => item ** expont)
}

// 使用最大值来归一化
export function normalize(data: number[], max?: number) {
  max = max || Math.max(...data)
  return max === 0 ? data : data.map(v => v / max)
}
