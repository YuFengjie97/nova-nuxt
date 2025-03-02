import process from 'node:process'

// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  compatibilityDate: '2024-11-01',
  devtools: { enabled: true },
  modules: [
    '@unocss/nuxt',
  ],
  app: {
    pageTransition: { name: 'page', mode: 'out-in' },
  },
  css: ['normalize.css', '~/assets/css/global.css'],
  runtimeConfig: {
    public: {
      apiBase: process.env.BASE_URL || '/nova-nuxt/',
    },
  },
})
