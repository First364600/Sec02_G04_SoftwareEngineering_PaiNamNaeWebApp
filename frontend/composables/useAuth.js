import { useCookie }    from '#app'
import { useRouter }    from 'vue-router'

export function useAuth() {
  const { $api } = useNuxtApp()
  const token = useCookie('token')
  const user  = useCookie('user')
  const router = useRouter()

  const login = async (email, password) => {
    const res = await $api('/auth/login', {
      method: 'POST',
      body: { email, password }
    })
    token.value = res.token
    user.value  = res.user
  }

  const register = async (email,password,firstName,lastName)=>{
    const res = await $api('/users',{
      method:'POST',
      body: {email,password,firstName,lastName}
    })
    return res
  }

  const logout = () => {
    token.value = null
    user.value  = null
    return router.push('/')
  }

  return { token, user, login, logout, register}
}
