export default defineNuxtRouteMiddleware((to, from) => {

  const user = useCookie("user").value;
  const token = useCookie("token").value;

  if (!token) {

    return navigateTo("/login");
  }

  if (!user || user.role !== "ADMIN") {
    return navigateTo("/");

  }

});
