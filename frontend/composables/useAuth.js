import { useCookie } from '#app'
import { useRouter } from 'vue-router'

export function useAuth() {
  const { $api } = useNuxtApp()
  const token = useCookie('token', { maxAge: 60 * 60 * 24 * 7, secure: true })
  const user = useCookie('user', { maxAge: 60 * 60 * 24 * 7, secure: true })
  const router = useRouter()

  const login = async (identifier, password) => {
    const payload = { password }
    if (identifier.includes('@')) {
      payload.email = identifier
    } else {
      payload.username = identifier
    }

    const res = await $api('/auth/login', {
      method: 'POST',
      body: payload
    })
    token.value = res.token
    user.value = res.user
    return res
  }

  const register = async (email, password, firstName, lastName) => {
    const res = await $api('/users', {
      method: 'POST',
      body: { email, password, firstName, lastName }
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
