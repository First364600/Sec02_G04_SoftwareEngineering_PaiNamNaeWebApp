export default defineNuxtRouteMiddleware((to) => {
  const token = useCookie('token').value
  if (!token && to.path !== '/login') {
    return navigateTo('/login')
  }
})