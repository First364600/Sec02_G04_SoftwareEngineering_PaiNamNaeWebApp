import { useCookie } from '#app'

export default defineNuxtPlugin(() => {
  const config = useRuntimeConfig()

  const api = $fetch.create({
    baseURL: config.public.apiBase,
    credentials: 'include',

    async onRequest({ options }) {
      const token = useCookie('token').value
      if (token) {
        options.headers = {
          ...options.headers,
          Authorization: `Bearer ${token}`,
        }
      }
    },

    onResponse({ response }) {
      if (response._data && Object.prototype.hasOwnProperty.call(response._data, 'data')) {
        response._data = response._data.data
      }
    },

    onResponseError({ response }) {
      let body = response?._data
      if (typeof body === 'string') {
        try { body = JSON.parse(body) } catch { }
      }

      const msg =
        body?.message ||
        body?.error?.message ||
        body?.error ||
        response?.statusText ||
        'Request failed'

      throw createError({
        statusCode: response?.status || 500,
        statusMessage: msg,
        data: body, // <-- อันนี้คือสิ่งที่หน้าเพจไปอ่าน err.data.message
      })
    },
  })

  return { provide: { api } }
})
