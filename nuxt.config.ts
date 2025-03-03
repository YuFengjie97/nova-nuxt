import process from 'node:process'

const baseURL = process.env.BASE_URL || '/nova-nuxt/'

// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  compatibilityDate: '2024-11-01',
  devtools: { enabled: true },
  modules: [
    '@unocss/nuxt',
  ],
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
