interface DecorateOptions {
  magnitudeTargetMax?: number
  exponent?: number
  root?: number
  baseBarCount?: number
  cumulativeMaxMagnitude?: number
}

const defaultOptions = {
  magnitudeTargetMax: 32,
  exponent: 10,
  root: 1,
  baseBarCount: 200,
  cumulativeMaxMagnitude: 209.809,
}

// Decorates the audio frequency to receive the final values for bass or wide.
export function decorateAudioFrequency(spectrumFrequency: Float32Array, options: DecorateOptions) {
  const {
    magnitudeTargetMax,
    exponent,
    root,
    baseBarCount,
    cumulativeMaxMagnitude,
  } = { ...defaultOptions, ...options }
  const targetMax = magnitudeTargetMax

  // Step 1.
  // Normalizes all the values to maximum value.
  // Check the extra high bins and reduce them to get accurate result.

  const magnitudeMultiplier = targetMax / cumulativeMaxMagnitude
  let normalizedBin = 0

  for (let i = 0; i < spectrumFrequency.length; i++) {
    normalizedBin = spectrumFrequency[i] * magnitudeMultiplier
    spectrumFrequency[i] = normalizedBin <= targetMax ? normalizedBin : targetMax
  }

  // Step 2.
  // Exaggerate the peaks of a data array with a target max. All values beneath the target max are reduced.
  // The further below the target max a value is, the more it is reduced. Values at or near the target max are barely changed.

  if (exponent > 1) {
    const divisor = targetMax ** (exponent - 1)
    for (let i = 0; i < spectrumFrequency.length; i++) {
      spectrumFrequency[i] = spectrumFrequency[i] ** exponent / divisor
    }
  }

  // Step 3.
  // Does the opposite of exaggerate.
  // The further below the target max a value is, the more it is increased, approaching the target max.
  // This reduces the exaggeration of peaks in the array.

  if (root > 1) {
    const exponent = 1 / root
    const multiplier = (targetMax ** exponent) ** (root - 1)

    for (let i = 0; i < spectrumFrequency.length; i++) {
      spectrumFrequency[i] = spectrumFrequency[i] ** exponent * multiplier
    }
  }

  // Return the final result.
  return conformToBarCount(spectrumFrequency, baseBarCount)
}

function conformToBarCount(array: Float32Array, target: number): number[] {
  const newArr = []
  const multiplier = (array.length - 1) / (target - 1)

  for (let i = 0; i < target - 1; i++) {
    const point = i * multiplier
    const part1 = array[Math.floor(point)] * Math.abs(point % 1 - 1)
    const part2 = array[Math.ceil(point)] * (point % 1)
    newArr.push(part1 + part2)
  }

  newArr.push(array[array.length - 1])
  return newArr
}
