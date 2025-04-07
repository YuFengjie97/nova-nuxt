export function runtimePath(url: string) {
  url = url[0] === '/' ? url.slice(1) : url
  const runtimeConfig = useRuntimeConfig()
  const baseURL = runtimeConfig.public.baseURL
  return `${baseURL}${url}`
}
