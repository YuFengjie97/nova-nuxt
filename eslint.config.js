// @ts-check
import antfu from '@antfu/eslint-config'

export default antfu(
  {
    rules: {
      'no-console': 'off',
      'no-lone-blocks': 'off',
      'unused-imports/no-unused-vars': 'off',
      '@typescript-eslint/ban-ts-comment': 'off',
      // 'max-len': ['error', { code: 200 }],
    },
  },
)
