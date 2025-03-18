import { avgNormal, smooth } from '~/utils/noiseReduction'

export function audioParse(url: string, fftSize = 1024, targetSize = 100) {
  const audio = new Audio(url)
  const audioCtx = new window.AudioContext()
  const source = audioCtx.createMediaElementSource(audio)
  const analyser = audioCtx.createAnalyser()
  source.connect(analyser)
  analyser.connect(audioCtx.destination)

  // analyser.smoothingTimeConstant = 0

  const sampleRate = audioCtx.sampleRate
  const bin = sampleRate / fftSize

  analyser.fftSize = fftSize
  const bufferLength = analyser.frequencyBinCount
  const dataArrayFrequency = new Uint8Array(bufferLength)
  const dataArrayTimeDomain = new Uint8Array(bufferLength)

  const floatArrayFrequency = new Float32Array(bufferLength)
  const floatArrayTimeDomain = new Float32Array(bufferLength)

  function getByteFrequencyData() {
    analyser.getByteFrequencyData(dataArrayFrequency)
    const res = smooth(avgNormal(Array.from(dataArrayFrequency), targetSize))
    return res
  }

  function getByteTimeDomainData() {
    analyser.getByteTimeDomainData(dataArrayTimeDomain)
    const res = smooth(avgNormal(Array.from(dataArrayTimeDomain), targetSize))
    return res
  }

  function getFloatFrequencyData() {
    analyser.getFloatFrequencyData(floatArrayFrequency)
    return floatArrayFrequency
  }

  function getFloatTimeDomainData() {
    analyser.getFloatTimeDomainData(floatArrayTimeDomain)
    return floatArrayTimeDomain
  }

  function getFrequencyRange(range: [number, number]) {
    const res = []
    for (let i = 0; i < bufferLength; i++) {
      const binMid = (i + 0.5) * bin
      if (binMid >= range[0] && binMid <= range[1]) {
        res.push(dataArrayFrequency[i])
      }
    }
    return res
  }

  function getSubBass() {
    return avgNormal(getFrequencyRange([20, 60]), 1)[0]
  }
  function getBass() {
    return avgNormal(getFrequencyRange([61, 250]), 1)[0]
  }
  function getLowMid() {
    return avgNormal(getFrequencyRange([251, 500]), 1)[0]
  }
  function getMid() {
    return avgNormal(getFrequencyRange([501, 2000]), 1)[0]
  }
  function getHighMid() {
    return avgNormal(getFrequencyRange([2001, 4000]), 1)[0]
  }
  function getPresence() {
    return avgNormal(getFrequencyRange([4001, 6000]), 1)[0]
  }
  function Brilliance() {
    return avgNormal(getFrequencyRange([6001, 20000]), 1)[0]
  }

  function play() {
    if (audio.paused) {
      audio.play()
    }
  }

  function pause() {
    if (!audio.paused) {
      audio.pause()
    }
  }

  function reset() {
    pause()
    audio.currentTime = 0
  }

  return {
    audio,
    play,
    pause,
    reset,
    audioCtx,
    analyser,
    getByteFrequencyData,
    getByteTimeDomainData,
    getFloatFrequencyData,
    getFloatTimeDomainData,
    getSubBass,
    getBass,
    getLowMid,
    getMid,
    getHighMid,
    getPresence,
    Brilliance,
  }
}
