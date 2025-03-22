export class AudioParse {
  targetSize = 100
  audio: HTMLAudioElement
  audioCtx: AudioContext
  source: MediaElementAudioSourceNode
  analyser: AnalyserNode
  sampleRate: number
  bin: number
  bufferLength: number
  dataArrayFrequency: Uint8Array
  dataArrayTimeDomain: Uint8Array
  floatArrayFrequency: Float32Array
  floatArrayTimeDomain: Float32Array
  constructor(url: string, public fftSize = 1024) {
    this.audio = new Audio(url)
    this.audioCtx = new AudioContext()
    this.source = this.audioCtx.createMediaElementSource(this.audio)
    this.analyser = this.audioCtx.createAnalyser()

    this.source.connect(this.analyser)
    this.analyser.connect(this.audioCtx.destination)

    this.sampleRate = this.audioCtx.sampleRate
    this.bin = this.sampleRate / this.fftSize
    this.bufferLength = this.analyser.frequencyBinCount
    this.dataArrayFrequency = new Uint8Array(this.bufferLength)
    this.dataArrayTimeDomain = new Uint8Array(this.bufferLength)
    this.floatArrayFrequency = new Float32Array(this.bufferLength)
    this.floatArrayTimeDomain = new Float32Array(this.bufferLength)
  }

  play() {
    if (this.audio.paused) {
      this.audio.play()
    }
  }

  pause() {
    if (!this.audio.paused) {
      this.audio.pause()
    }
  }

  reset() {
    this.pause()
    this.audio.currentTime = 0
  }

  destroy() {
    try {
      this.audio.pause()
      this.audio.src = ''
      this.audio.load()

      this.source.disconnect()
      this.analyser.disconnect()

      if (this.audioCtx && this.audioCtx.state !== 'closed') {
        this.audioCtx.close()
      }

      ; (this.audio as any) = null
      ; (this.audioCtx as any) = null
      ; (this.source as any) = null
      ; (this.analyser as any) = null
    }
    catch (e) {
      console.warn('AudioParse 销毁错误:', e)
    }
  }

  setSmoothingTimeConstant(val: number) {
    this.analyser.smoothingTimeConstant = val
  }

  getByteFrequencyData() {
    this.analyser.getByteFrequencyData(this.dataArrayFrequency)
    return this.dataArrayFrequency
  }

  getByteTimeDomainData() {
    this.analyser.getByteTimeDomainData(this.dataArrayTimeDomain)
    return this.dataArrayTimeDomain
  }

  getFloatFrequencyData() {
    this.analyser.getFloatFrequencyData(this.floatArrayFrequency)
    return this.floatArrayFrequency
  }

  getFloatTimeDomainData() {
    this.analyser.getFloatTimeDomainData(this.floatArrayTimeDomain)
    return this.floatArrayTimeDomain
  }

  getFrequencyRange(range: [number, number]) {
    const res = []
    for (let i = 0; i < this.bufferLength; i++) {
      const binMid = (i + 0.5) * this.bin
      if (binMid >= range[0] && binMid <= range[1]) {
        res.push(this.dataArrayFrequency[i])
      }
    }
    return res
  }

  getSubBass() {
    return this.getFrequencyRange([20, 60])
  }

  getBass() {
    return this.getFrequencyRange([61, 250])
  }

  getLowMid() {
    return this.getFrequencyRange([251, 500])
  }

  getMid() {
    return this.getFrequencyRange([501, 2000])
  }

  getHighMid() {
    return this.getFrequencyRange([2001, 4000])
  }

  getPresence() {
    return this.getFrequencyRange([4001, 6000])
  }

  Brilliance() {
    return this.getFrequencyRange([6001, 20000])
  }
}
