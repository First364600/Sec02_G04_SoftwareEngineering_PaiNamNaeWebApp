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

        async onResponse({ response }) {

          if (response._data && response._data.hasOwnProperty('data')) {
            response._data = response._data.data;
          }
        },

        async onResponseError({ response }) {
          if (response.status === 401) {
            // ล้างคุกกี้แล้วพาไป /login
            useCookie('token').value = null
            useCookie('user').value = null
            return navigateTo('/login')
          }
        },

      }),
    },
  };
});