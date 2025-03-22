export function createRectangularWindow(fftSize: number) {
  return new Float32Array(fftSize).fill(1)
}

export function createHannWindow(fftSize: number) {
  const window = new Float32Array(fftSize)
  for (let n = 0; n < fftSize; n++) {
    window[n] = 0.5 * (1 - Math.cos((2 * Math.PI * n) / (fftSize - 1)))
  }
  return window
}

export function createHammingWindow(fftSize: number) {
  const window = new Float32Array(fftSize)
  for (let n = 0; n < fftSize; n++) {
    window[n] = 0.54 - 0.46 * Math.cos((2 * Math.PI * n) / (fftSize - 1))
  }
  return window
}

export function createBlackmanWindow(fftSize: number) {
  const window = new Float32Array(fftSize)

  const alpha = 0.16
  const a0 = 0.5 * (1 - alpha)
  const a1 = 0.5
  const a2 = 0.5 * alpha

  for (let i = 0; i < fftSize; i++) {
    const x = i / fftSize
    window[i] = a0 - a1 * Math.cos(2 * Math.PI * x) + a2 * Math.cos(4 * Math.PI * x)
  }

  return window
}

export function createFlatTopWindow(fftSize: number) {
  const a0 = 1.0
  const a1 = 1.93
  const a2 = 1.29
  const a3 = 0.388
  const a4 = 0.028
  const window = new Float32Array(fftSize)
  for (let n = 0; n < fftSize; n++) {
    window[n] = a0 - a1 * Math.cos((2 * Math.PI * n) / (fftSize - 1)) + a2 * Math.cos((4 * Math.PI * n) / (fftSize - 1)) - a3 * Math.cos((6 * Math.PI * n) / (fftSize - 1)) + a4 * Math.cos((8 * Math.PI * n) / (fftSize - 1))
  }
  return window
}
