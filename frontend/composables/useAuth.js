import { useCookie } from '#app'
import { useRouter } from 'vue-router'

export function useAuth() {
  const { $api } = useNuxtApp()
  const token = useCookie('token')
  const user = useCookie('user')
  const router = useRouter()

  const login = async (email, username, password) => {
    const res = await $api('/auth/login', {
      method: 'POST',
      body: { email, username, password }
    })
    token.value = res.token
    user.value = res.user
  }

  const register = async (formData) => {
    const res = await $api('/users', {
      method: 'POST',
      body: formData
    })
    return res
  }

  const logout = () => {
    token.value = null
    user.value = null
    return router.push('/')
  }

  return { token, user, login, logout, register }
}
