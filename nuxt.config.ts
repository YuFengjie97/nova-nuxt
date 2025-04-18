import { env } from 'node:process'
import glsl from 'vite-plugin-glsl'
// 需要本地env文件,但是nuxt3因为安全,env文件不会选择推送
// const baseURL = process.env.BASE_URL || '/nova-nuxt/'

// import.meta.dev在构建时是undefined
const isDev = env.NODE_ENV === 'development'
const baseURL = isDev ? '/' : '/nova-nuxt/'

// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  compatibilityDate: '2024-11-01',
  devtools: { enabled: true },
  modules: [
    '@unocss/nuxt',
  ],
  vite: {
    plugins: [glsl()],
  },
  app: {
    baseURL,
    pageTransition: { name: 'page', mode: 'out-in' },
  },
  runtimeConfig: {
    public: {
      baseURL,
    },
  },
  css: ['normalize.css', '~/assets/css/global.css'],
})
