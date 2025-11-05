export default defineNuxtConfig({
  compatibilityDate: '2025-08-04',
  devServer: {
    port: 3000 // Változtasd meg erre: 3001, 3002, stb.
  },
  modules: [
    '@nuxt/ui',
    '@nuxt/ui-pro',
    '@pinia/nuxt',
    '@vueuse/nuxt',
    '@nuxtjs/supabase',
    '@nuxtjs/i18n'
  ],
  css: ['~/assets/css/main.css', '~/assets/css/transitions.css'],
  app: {
    head: {
      meta: [
        {
          name: 'apple-mobile-web-app-capable',
          content: 'yes'
        },
        {
          name: 'apple-mobile-web-app-status-bar-style',
          content: 'black-translucent'
        },
        {
          name: 'viewport',
          content: 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover'
        }
      ],
      link: [
        {
          rel: 'preconnect',
          href: 'https://fonts.googleapis.com'
        },
        {
          rel: 'preconnect',
          href: 'https://fonts.gstatic.com',
          crossorigin: ''
        },
        {
          rel: 'stylesheet',
          href: 'https://fonts.googleapis.com/css2?family=Outfit:wght@100..900&display=swap'
        }
      ]
    },
    //pageTransition: { name: 'page', mode: 'out-in' }
  },
  nitro: {
    routeRules: {
      '/measure/aruco/api/facade/process': { proxy: 'https://aruco.everest.hu/process-image/' },
      '/measure/aruco/download/**': { proxy: 'https://aruco.everest.hu/download/**' }
    }
  },
  runtimeConfig: {
    public: {
      apiBaseUrl: process.env.API_BASE_URL || 'http://inki.api.test/api',
      googleMapsApiKey: process.env.NUXT_PUBLIC_GOOGLE_MAPS_API_KEY
    }
  },
  supabase: {
    url: process.env.SUPABASE_URL,
    key: process.env.SUPABASE_KEY,
    redirectOptions: {
      login: '/login',
      callback: '/confirm',
      exclude: ['/login', '/register', '/forgot-password'],
    },
    cookieOptions: {
      secure: process.env.NODE_ENV === 'production',
    },
    clientOptions: {
      auth: {
        persistSession: true,
        autoRefreshToken: true,
      }
    }
  },

  i18n: {
    locales: [
      {
        code: 'en',
        name: 'English',
        file: 'en.json'
      },
      {
        code: 'hu',
        name: 'Hungarian',
        file: 'hu.json'
      }
    ],
    lazy: true,
    langDir: 'locales',
    defaultLocale: 'en',
    strategy: 'no_prefix',
    detectBrowserLanguage: {
      useCookie: true,
      cookieKey: 'i18n_redirected',
      redirectOn: 'root'
    }
  }
})