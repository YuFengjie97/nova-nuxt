export function getFileUrl(file: File) {
  const url = URL.createObjectURL(file)
  return url
}
