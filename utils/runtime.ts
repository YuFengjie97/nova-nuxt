export function runtimePath(url: string) {
  const runtimeConfig = useRuntimeConfig()
  const baseURL = runtimeConfig.public.baseURL
  return `${baseURL}${url}`
}
