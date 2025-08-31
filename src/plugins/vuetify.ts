import 'vuetify/styles'
import { createVuetify } from 'vuetify'
import * as components from 'vuetify/components'
import * as directives from 'vuetify/directives'
import { mdi } from 'vuetify/iconsets/mdi'
import '@mdi/font/css/materialdesignicons.css'

export default createVuetify({
  components,
  directives,
  icons: {
    defaultSet: 'mdi',
    sets: {
      mdi,
    },
  },
  theme: {
    defaultTheme: 'light',
    themes: {
      light: {
        colors: {
          primary: '#2563EB',
          secondary: '#7C3AED',
          accent: '#06B6D4',
          error: '#FF5252',
          info: '#3B82F6',
          success: '#10B981',
          warning: '#F59E0B',
          background: '#F8FAFC',
        },
      },
      dark: {
        colors: {
          primary: '#3B82F6',
          secondary: '#8B5CF6',
          accent: '#06B6D4',
          error: '#EF4444',
          info: '#3B82F6',
          success: '#10B981',
          warning: '#F59E0B',
          background: '#0F172A',
        },
      },
    },
  },
  defaults: {
    VBtn: {
      style: 'text-transform: none; font-weight: 600;',
    },
    VCard: {
      style: 'border-radius: 12px;',
    },
    VTextField: {
      variant: 'outlined',
    },
    VSelect: {
      variant: 'outlined',
    },
  },
})