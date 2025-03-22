import FFT from 'fft.js'
import { createBlackmanWindow } from './windowingFunctions'

function getByteValue(value: number, minDec = -100, maxDec = -10) {
  // Info is here:
  // https://github.com/WebKit/webkit/blob/master/Source/WebCore/Modules/webaudio/RealtimeAnalyser.cpp

  const UCHAR_MAX = 255
  const rangeScaleFactor = (minDec === maxDec) ? 1 : 1 / (maxDec - minDec)

  const dbMag = !value ? minDec : linearToDecibel(value)
  let scaledValue = UCHAR_MAX * (dbMag - minDec) * rangeScaleFactor

  if (scaledValue < 0)
    scaledValue = 0

  if (scaledValue > UCHAR_MAX)
    scaledValue = UCHAR_MAX

  return scaledValue
}

function linearToDecibel(linear: number) {
  // Info is here:
  // https://github.com/WebKit/webkit/blob/89c28d471fae35f1788a0f857067896a10af8974/Source/WebCore/platform/audio/AudioUtilities.cpp

  if (!linear)
    return -1000

  return 20 * Math.log10(linear)
}

export function createFFTAnalyzer(fftSize: number, minDecibels: number, maxDecibels: number, smoothingTimeConstant: number) {
  // Create FFT instance once.
  const fftInstance = new FFT(fftSize)
  console.log('The fft instance has been created!')

  // Create the windowing function to normalize the data before FFT processing.
  const window = createBlackmanWindow(fftSize)

  // Pre-allocate arrays for FFT.
  // Input is a real values (fft size)
  // Output is complex array (fft size * 2) (real1, img1, real2, img2).
  const inputValues = new Float64Array(fftSize)
  const outputValues = fftInstance.createComplexArray()

  // Previous magnitudes for smoothing.
  const magnitudesLength = fftSize / 2
  const magnitudes = new Float32Array(magnitudesLength)

  // Normalize so than an input sine wave at 0dBfs registers as 0dBfs.
  // Without normalization, increasing the FFT size results in higher magnitude values because more bins divide the same energy.
  const magnitudeScale = 1.0 / fftSize

  function getByteFrequencyData(timeDomainData: Float32Array, frequencyBinCount: number) {
    // Apply window (Need to do it before fft processing).
    for (let i = 0; i < fftSize; i++) {
      inputValues[i] = timeDomainData[i] * window[i]
    }

    // Perform FFT in-place.
    fftInstance.realTransform(outputValues, inputValues)

    for (let i = 0; i < magnitudesLength; i++) {
      // Get the real and imaginary values from fft result.
      const realValue = outputValues[2 * i]
      const imaginaryValue = outputValues[2 * i + 1]

      // Convert the values to magnitude.
      const scalarMagnitude = Math.sqrt(realValue * realValue + imaginaryValue * imaginaryValue) * magnitudeScale

      // Apply smoothing and set the current magnitude.
      magnitudes[i] = smoothingTimeConstant * magnitudes[i] + (1 - smoothingTimeConstant) * scalarMagnitude
    }

    const byteFrequencyData = new Float32Array(frequencyBinCount)
    for (let i = 0; i < frequencyBinCount || i < magnitudesLength; i++) {
      // Convert the magnitude to byte value (0-255) and crop to min/max decibels.
      byteFrequencyData[i] = getByteValue(magnitudes[i], minDecibels, maxDecibels)
    }

    return byteFrequencyData
  }

  return getByteFrequencyData
}
