import { defineConfig, presetAttributify, presetIcons, presetWind3 } from 'unocss'

export default defineConfig({
  presets: [
    presetAttributify({
      /* preset 选项 */
    }),
    presetWind3(),
    presetIcons(),
  ],
})
