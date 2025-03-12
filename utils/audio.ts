export function audioParse(url: string, fftSize = 512) {
  const audio = new Audio(url)
  const audioCtx = new window.AudioContext()
  const source = audioCtx.createMediaElementSource(audio)
  const analyser = audioCtx.createAnalyser()
  source.connect(analyser)
  analyser.connect(audioCtx.destination)

  analyser.fftSize = fftSize
  const bufferLength = analyser.fftSize
  const dataArray = new Uint8Array(bufferLength)

  function getByteTimeDomainData() {
    analyser.getByteTimeDomainData(dataArray)
  }

  function getByteFrequencyData() {
    analyser.getByteFrequencyData(dataArray)
  }

  return {
    audio,
    dataArray,
    getByteFrequencyData,
    getByteTimeDomainData,
  }
}
