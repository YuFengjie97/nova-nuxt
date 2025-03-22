import FFT from 'fft.js'

export async function getArrayBufferByFile(file: File): Promise<ArrayBuffer> {
  return await file.arrayBuffer()
  // return new Promise((resolve, reject) => {
  //   const reader = new FileReader()
  //   reader.onload = () => resolve(reader.result as ArrayBuffer)
  //   reader.onerror = reject
  //   reader.readAsArrayBuffer(file)
  // })
}

export async function getArrayBufferByUrl(url: string) {
  const res = await fetch(url)
  return await res.arrayBuffer()
}

// 音频文件的二进制数据-->波形数据(多声道的)
export async function getAudioBufferByArrayBuffer(arrayBuffer: ArrayBuffer) {
  const audioCtx = new AudioContext()
  return await audioCtx.decodeAudioData(arrayBuffer)
}

// 混合声道, 得到单声道的波形数据
export function mixedTimeDomain(audioBuffer: AudioBuffer) {
  const mixedTimeDomainData = new Float32Array(audioBuffer.length)
  for (let i = 0; i < audioBuffer.numberOfChannels; i++) {
    const channelSamples = audioBuffer.getChannelData(i)
    for (let j = 0; j < channelSamples.length; j++) {
      mixedTimeDomainData[j] += channelSamples[j] / audioBuffer.numberOfChannels
    }
  }

  return mixedTimeDomainData
}

// 波形数据-->audioBuffer
export function timeDomainDataToAudioBuffer(data: Float32Array, sampleRate: number) {
  const audioBuffer = new AudioBuffer({
    length: data.length,
    numberOfChannels: 1,
    sampleRate,
  })
  audioBuffer.copyToChannel(data, 0)

  return audioBuffer
}
export function getFrequency(timeDomainData: Float32Array, fftSize: number) {
  const fft = new FFT(fftSize)
  const magnitudesLength = fftSize / 2
  const magnitudes = new Float32Array(magnitudesLength)

  const input = timeDomainData
  const output = fft.createComplexArray()
  fft.realTransform(output, input)

  for (let i = 0; i < magnitudesLength; i++) {
    const realValue = output[2 * i]
    const imaginaryValue = output[2 * i + 1]
    magnitudes[i] = Math.sqrt(realValue ** 2 + imaginaryValue ** 2)
  }

  return magnitudes
}

export function getFrequencyFrames(timeDomainData: Float32Array, fftSize: number) {
  const length = timeDomainData.length

  const frames = []
  for (let i = 0; i < length; i += fftSize) {
    const start = i
    const end = Math.min(start + fftSize, length)
    const slice = timeDomainData.slice(start, end)
    const frequencyFrame = getFrequency(slice, fftSize)
    frames.push(frequencyFrame)
  }

  return frames
}

export function getMaxBassAndWideMagnitude(frequencyFrames: Float32Array[], sampleRate: number, fftSize: number) {
  const bin = sampleRate / fftSize
  const ind = (frequency: number) => {
    return Math.floor(frequency / bin)
  }

  const bassRange = [ind(0), ind(250)]
  const wideRange = [ind(251), ind(2000)]

  const [bassStart, bassEnd] = bassRange
  const [wideStart, wideEnd] = wideRange

  const bassMaxMaginatudes: number[] = []
  const wideMaxMaginatudes: number[] = []

  for (let i = 0; i < frequencyFrames.length; i++) {
    const frame = frequencyFrames[i]
    for (let j = 0; j < frame.length; j++) {
      const magnitude = frame[j]

      if (bassStart <= j && j <= bassEnd) {
        bassMaxMaginatudes.push(magnitude)
      }
      if (wideStart <= j && j <= wideEnd) {
        wideMaxMaginatudes.push(magnitude)
      }
    }
  }

  function getMax(data: number[], percentile: number) {
    data.sort((a, b) => b - a)
    const maxCount = Math.floor(data.length * percentile)
    const maxData = data.slice(0, maxCount)

    const avg = maxData.reduce((acc, cur) => acc + cur, 0) / maxCount
    return avg
  }

  return {
    bassMaxMaginatude: getMax(bassMaxMaginatudes, 0.3),
    wideMaxMaginatude: getMax(wideMaxMaginatudes, 0.3),
  }
}
