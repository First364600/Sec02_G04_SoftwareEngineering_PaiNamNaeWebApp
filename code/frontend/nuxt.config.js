import tailwindcssVite from "@tailwindcss/vite";

export default defineNuxtConfig({
  compatibilityDate: "2025-05-15",
  devtools: { enabled: true },
  runtimeConfig: {
    public: {
      apiBase: "http://localhost:3000/api/",
      // apiBase: process.env.API_BASE || "",
      gatewaySecret: process.env.NUXT_PUBLIC_GATEWAY_SECRET || process.env.GATEWAY_SECRET || "",
      googleMapsApiKey: process.env.NUXT_PUBLIC_GOOGLE_MAPS_API_KEY || "",
      vapidPublicKey: process.env.NUXT_PUBLIC_VAPID_KEY || "BNf1ku3n9OwnnajszQB5Dwln-sqwo9jd5vuN05dZXzouGQ9f5mUR_mOSLa8AIBwYz1XgxDJA7fRRh6fAitNgKqc"
    },
  },
  devServer: {
    port: 3001,
  },
  plugins: ["~/plugins/api.client.js"],
  app: {
    head: {
      title: "ไปนำแหน่",
      meta: [{ name: "description", content: "รายละเอียด" }],
      charset: "utf-8",
      viewport: "width=device-width, initial-scale=1, maximum-scale=1",
      link: [
        { rel: 'stylesheet', href: 'https://fonts.googleapis.com/css2?family=Kanit:wght@300;400;500;600;700&display=swap' }
      ]
    },

  },
  vite: {
    plugins: [tailwindcssVite()],
  },

  css: [
    '@fortawesome/fontawesome-free/css/all.min.css',
    'leaflet/dist/leaflet.css',
    '~/assets/css/input.css',
  ],
  build: {
    transpile: ['leaflet']
  },
});
