export function audioParse(url: string, fftSize = 1024) {
  const audio = new Audio(url)
  const audioCtx = new window.AudioContext()
  const source = audioCtx.createMediaElementSource(audio)
  const analyser = audioCtx.createAnalyser()
  source.connect(analyser)
  analyser.connect(audioCtx.destination)

  // const sampleRate = audioCtx.sampleRate
  // const bin = sampleRate / fftSize

  analyser.fftSize = fftSize
  const bufferLength = analyser.frequencyBinCount
  const dataArrayFrequency = new Uint8Array(bufferLength)
  const dataArrayTimeDomain = new Uint8Array(bufferLength)
  const floatDataArray = new Float32Array(bufferLength)

  function getByteTimeDomainData(size: number) {
    analyser.getByteTimeDomainData(dataArrayTimeDomain)

    const res = []
    const step = Math.floor(bufferLength / size)
    for (let i = 0; i < bufferLength; i += step) {
      const avg = dataArrayTimeDomain.slice(i, i + step).reduce((acc, cur) => acc + cur / 255, 0) / step
      res.push(avg)
    }

    return res
  }
  function getFloatTimeDomainData() {
    analyser.getFloatTimeDomainData(floatDataArray)
    return floatDataArray
  }

  function getByteFrequencyData(size: number) {
    analyser.getByteFrequencyData(dataArrayFrequency)

    const res = []
    const step = Math.floor(bufferLength / size)
    for (let i = 0; i < bufferLength; i += step) {
      const avg = dataArrayFrequency.slice(i, i + step).reduce((acc, cur) => acc + cur / 255, 0) / step
      res.push(avg)
    }

    return res
  }

  function getFloatFrequencyData() {
    analyser.getFloatFrequencyData(floatDataArray)
    return floatDataArray
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
  }
}
