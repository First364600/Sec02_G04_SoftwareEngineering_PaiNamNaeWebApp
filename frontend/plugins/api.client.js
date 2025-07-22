import { useCookie } from "#app";

export default defineNuxtPlugin(() => {
  const config = useRuntimeConfig();
  return {
    provide: {
      api: $fetch.create({
        baseURL: config.public.apiBase,
        credentials: "include", // ให้เบราว์เซอร์แนบ Cookie ไปกับ request ด้วย
        async onRequest({ options }) {
          const token = useCookie("token").value;
          if (token) {
            options.headers = {
              ...options.headers,
              Authorization: `Bearer ${token}`,
            };
          }
        },
        
        async onResponse({ request, response, options }) {

          if (response._data && response._data.hasOwnProperty('data')) {
            response._data = response._data.data;
          }
        }
      }),
    },
  };
});