<template>
    <div>
        <header class="sticky top-0 z-50 bg-white shadow-sm">
            <div class="px-4 mx-auto max-w-7xl sm:px-6 lg:px-8">
                <div class="flex items-center justify-between h-16">
                    <NuxtLink to="/">
                        <div class="flex items-center">
                            <h1 class="text-xl font-bold text-blue-600 sm:text-2xl">ไปนำแหน่</h1>
                        </div>
                    </NuxtLink>

                    <nav class="items-center hidden space-x-6 md:flex lg:space-x-8">
                        <NuxtLink to="/findTrip"
                            class="font-medium text-gray-600 transition-colors duration-200 hover:text-blue-700"
                            :class="{ 'text-blue-600': $route.path === '/findTrip' }">
                            ค้นหาเส้นทาง
                        </NuxtLink>

                        <div
                            v-if="user && (user.role === 'PASSENGER' || user.role === 'DRIVER' || user.role === 'ADMIN')">
                            <NuxtLink to="/createTrip"
                                class="text-gray-600 transition-colors duration-200 hover:text-blue-600"
                                :class="{ 'text-blue-600': $route.path === '/createTrip' }">
                                สร้างเส้นทาง
                            </NuxtLink>
                        </div>

                        <!-- ผู้โดยสาร: ลิงก์เดี่ยว ไม่มีดรอปดาวน์ -->
                        <div v-if="user && user.role === 'PASSENGER'">
                            <NuxtLink to="/myTrip"
                                class="flex items-center text-gray-600 transition-colors duration-200 hover:text-blue-600"
                                :class="{ 'text-blue-600': $route.path.startsWith('/myTrip') }">
                                การเดินทางของฉัน
                            </NuxtLink>
                        </div>

                        <!-- คนขับ: แสดงคำว่า การเดินทางทั้งหมด + ดรอปดาวน์ (การเดินทางของฉัน / คำขอจองเส้นทางของฉัน) -->
                        <div v-else-if="user && (user.role === 'DRIVER' || user.role === 'ADMIN')">
                            <div class="relative dropdown-trigger">
                                <NuxtLink to="/myTrip"
                                    class="flex items-center text-gray-600 transition-colors duration-200 hover:text-blue-600"
                                    :class="{ 'text-blue-600': $route.path.startsWith('/myTrip') || $route.path.startsWith('/myRoute') }">
                                    การเดินทางทั้งหมด
                                    <svg class="w-4 h-4 ml-1 transition-transform duration-200" fill="none"
                                        stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                            d="M19 9l-7 7-7-7"></path>
                                    </svg>
                                </NuxtLink>

                                <div
                                    class="absolute right-0 py-2 mt-5 bg-white border border-gray-200 rounded-lg shadow-lg dropdown-menu top-full w-50 user-dropdown-arrow">
                                    <NuxtLink to="/myTrip"
                                        class="flex items-center block w-full px-4 py-2 text-left text-gray-700 transition-colors duration-200 hover:bg-blue-50 hover:text-blue-600">
                                        การเดินทางของฉัน
                                    </NuxtLink>
                                    <NuxtLink to="/myRoute"
                                        class="flex items-center block w-full px-4 py-2 text-left text-gray-700 transition-colors duration-200 hover:bg-blue-50 hover:text-blue-600">
                                        คำขอจองเส้นทางของฉัน
                                    </NuxtLink>
                                </div>
                            </div>
                        </div>

                        <div v-if="!token" class="flex items-center space-x-3 ">
                            <NuxtLink to="/register"
                                class="text-gray-600 transition-colors duration-200 hover:text-blue-600">สมัครสมาชิก
                            </NuxtLink>
                            <span class="text-gray-600">|</span>
                            <NuxtLink to="/login"
                                class="text-gray-600 transition-colors duration-200 hover:text-blue-600">เข้าสู่ระบบ
                            </NuxtLink>
                        </div>

                        <!-- โปรไฟล์ passenger , driver -->
                        <div v-else-if="user && (user.role === 'PASSENGER' || user.role === 'DRIVER')"
                            class="relative dropdown-trigger">
                            <div
                                class="flex items-center px-3 py-2 pl-4 space-x-2 transition-colors duration-200 border-l border-gray-200 rounded-lg cursor-pointer hover:bg-blue-50">
                                <div class="flex items-center justify-center w-8 h-8 bg-blue-100 rounded-full">
                                    <svg class="w-5 h-5 text-blue-600" fill="none" stroke="currentColor"
                                        viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                            d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                                    </svg>
                                </div>
                                <span class="font-medium text-blue-600">{{ user.firstName }}</span>
                                <svg class="w-4 h-4 text-blue-600 transition-transform duration-200" fill="none"
                                    stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                        d="M19 9l-7 7-7-7"></path>
                                </svg>
                            </div>
                            <div
                                class="absolute right-0 w-40 py-2 mt-2 bg-white border border-gray-200 rounded-lg shadow-lg dropdown-menu top-full user-dropdown-arrow">
                                <NuxtLink to="/profile"
                                    class="flex items-center block w-full px-4 py-2 text-left text-gray-700 transition-colors duration-200 hover:bg-blue-50 hover:text-blue-600">
                                    บัญชีของฉัน
                                </NuxtLink>
                                <button @click="logout"
                                    class="flex items-center block w-full px-4 py-2 text-left text-red-600 transition-colors duration-200 hover:bg-red-50 hover:text-red-700">
                                    Logout
                                </button>
                            </div>
                        </div>

                        <!-- โปรไฟล์ admin -->
                        <div v-else-if="user && user.role === 'ADMIN'" class="relative dropdown-trigger">
                            <div
                                class="flex items-center px-3 py-2 pl-4 space-x-2 transition-colors duration-200 border-l border-gray-200 rounded-lg cursor-pointer hover:bg-blue-50">
                                <div class="flex items-center justify-center w-8 h-8 bg-blue-100 rounded-full">
                                    <svg class="w-5 h-5 text-blue-600" fill="none" stroke="currentColor"
                                        viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                            d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                                    </svg>
                                </div>
                                <span class="font-medium text-blue-600">{{ user.firstName }}</span>
                                <svg class="w-4 h-4 text-blue-600 transition-transform duration-200" fill="none"
                                    stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                        d="M19 9l-7 7-7-7"></path>
                                </svg>
                            </div>
                            <div
                                class="absolute right-0 w-40 py-2 mt-2 bg-white border border-gray-200 rounded-lg shadow-lg dropdown-menu top-full user-dropdown-arrow">
                                <NuxtLink to="/profile"
                                    class="flex items-center block w-full px-4 py-2 text-left text-gray-700 transition-colors duration-200 hover:bg-blue-50 hover:text-blue-600">
                                    บัญชีของฉัน
                                </NuxtLink>
                                <NuxtLink to="/admin/users"
                                    class="flex items-center block w-full px-4 py-2 text-left text-gray-700 transition-colors duration-200 hover:bg-blue-50 hover:text-blue-600">
                                    Dashboard
                                </NuxtLink>
                                <button @click="logout"
                                    class="flex items-center block w-full px-4 py-2 text-left text-red-600 transition-colors duration-200 hover:bg-red-50 hover:text-red-700">
                                    Logout
                                </button>
                            </div>
                        </div>


                    </nav>

                    <div class="md:hidden">
                        <button @click="toggleMobileMenu" type="button"
                            class="text-gray-600 transition-colors duration-200 hover:text-blue-600 focus:outline-none focus:text-blue-600">
                            <svg class="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path v-if="!isMobileMenuOpen" stroke-linecap="round" stroke-linejoin="round"
                                    stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
                                <path v-else stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                    d="M6 18L18 6M6 6l12 12" />
                            </svg>
                        </button>
                    </div>
                </div>

                <!-- ==================== Mobile Menu ==================== -->
                <div v-show="isMobileMenuOpen" class="border-t border-gray-200 md:hidden">
                    <div class="px-2 pt-2 pb-3 space-y-1 bg-white">
                        <NuxtLink to="/findTrip"
                            class="block px-3 py-2 font-medium transition-colors duration-200 rounded-md"
                            :class="$route.path === '/findTrip' ? 'text-blue-600 bg-blue-50' : 'text-gray-600 hover:text-blue-600 hover:bg-blue-50'"
                            @click="closeMobileMenu">
                            ค้นหาเส้นทาง
                        </NuxtLink>

                        <NuxtLink to="/createTrip" class="block px-3 py-2 transition-colors duration-200 rounded-md"
                            :class="$route.path === '/createTrip' ? 'text-blue-600 bg-blue-50' : 'text-gray-600 hover:text-blue-600 hover:bg-blue-50'"
                            @click="closeMobileMenu">
                            สร้างเส้นทาง
                        </NuxtLink>

                        <!-- ผู้โดยสาร: ลิงก์เดี่ยว -->
                        <NuxtLink v-if="user && user.role === 'PASSENGER'" to="/myTrip"
                            class="block px-3 py-2 transition-colors duration-200 rounded-md"
                            :class="$route.path.startsWith('/myTrip') ? 'text-blue-600 bg-blue-50' : 'text-gray-600 hover:text-blue-600 hover:bg-blue-50'"
                            @click="closeMobileMenu">
                            การเดินทางของฉัน
                        </NuxtLink>

                        <!-- คนขับ: เมนูย่อย 2 รายการ -->
                        <div v-else-if="user && user.role === 'DRIVER'" class="relative">
                            <button @click="toggleMobileTripMenu"
                                class="flex items-center justify-between w-full px-3 py-2 text-left text-gray-600 transition-colors duration-200 rounded-md hover:text-blue-600 hover:bg-blue-50">
                                การเดินทางทั้งหมด
                                <svg class="w-4 h-4 transition-transform duration-200"
                                    :class="{ 'rotate-180': isMobileTripMenuOpen }" fill="none" stroke="currentColor"
                                    viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                        d="M19 9l-7 7-7-7"></path>
                                </svg>
                            </button>
                            <div v-show="isMobileTripMenuOpen" class="mt-1 ml-4">
                                <NuxtLink to="/myTrip"
                                    class="block px-3 py-2 text-gray-500 transition-colors duration-200 rounded-md hover:text-blue-600 hover:bg-blue-50"
                                    @click="closeMobileMenu">
                                    การเดินทางของฉัน
                                </NuxtLink>
                                <NuxtLink to="/myRoute"
                                    class="block px-3 py-2 text-gray-500 transition-colors duration-200 rounded-md hover:text-blue-600 hover:bg-blue-50"
                                    @click="closeMobileMenu">
                                    คำขอจองเส้นทางของฉัน
                                </NuxtLink>
                            </div>
                        </div>

                        <div v-if="!token">
                            <NuxtLink to="/register" class="block px-3 py-2 transition-colors duration-200 rounded-md"
                                :class="$route.path === '/register' ? 'text-blue-600 bg-blue-50' : 'text-gray-600 hover:text-blue-600 hover:bg-blue-50'"
                                @click="closeMobileMenu">
                                สมัครสมาชิก
                            </NuxtLink>
                            <NuxtLink to="/login" class="block px-3 py-2 transition-colors duration-200 rounded-md"
                                :class="$route.path === '/login' ? 'text-blue-600 bg-blue-50' : 'text-gray-600 hover:text-blue-600 hover:bg-blue-50'"
                                @click="closeMobileMenu">
                                เข้าสู่ระบบ
                            </NuxtLink>
                        </div>

                        <div v-else-if="user && (user.role === 'PASSENGER' || user.role === 'DRIVER')"
                            class="pt-2 mt-2 border-t border-gray-200">
                            <div class="flex items-center px-3 py-2">
                                <div class="flex items-center justify-center w-8 h-8 bg-blue-100 rounded-full">
                                    <svg class="w-5 h-5 text-blue-600" fill="none" stroke="currentColor"
                                        viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                            d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                                    </svg>
                                </div>
                                <span class="ml-2 font-medium text-gray-700">{{ user.firstName }}</span>
                            </div>
                            <div class="mt-1 ml-6">
                                <NuxtLink to="/profile" @click="closeMobileMenu"
                                    class="flex items-center block w-full px-3 py-2 text-left text-gray-600 transition-colors duration-200 rounded-md hover:bg-blue-50 hover:text-blue-600">
                                    บัญชีของฉัน
                                </NuxtLink>
                                <button @click="logout"
                                    class="flex items-center block w-full px-3 py-2 text-left text-red-600 transition-colors duration-200 rounded-md hover:bg-red-50 hover:text-red-700">
                                    Logout
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
                <!-- ==================== End Mobile Menu ==================== -->
            </div>
        </header>

        <main>
            <NuxtPage />
        </main>
    </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import { useAuth } from '~/composables/useAuth'

const { token, user, logout } = useAuth()

const isMobileMenuOpen = ref(false)
const isMobileTripMenuOpen = ref(false)

const toggleMobileMenu = () => {
    isMobileMenuOpen.value = !isMobileMenuOpen.value
    if (!isMobileMenuOpen.value) {
        isMobileTripMenuOpen.value = false
    }
}

const closeMobileMenu = () => {
    isMobileMenuOpen.value = false
    isMobileTripMenuOpen.value = false
}

const toggleMobileTripMenu = () => {
    isMobileTripMenuOpen.value = !isMobileTripMenuOpen.value
}

const handleResize = () => {
    if (window.innerWidth >= 768) {
        isMobileMenuOpen.value = false
        isMobileTripMenuOpen.value = false
    }
}

onMounted(() => {
    window.addEventListener('resize', handleResize)
})

onUnmounted(() => {
    window.removeEventListener('resize', handleResize)
})

useHead({
    link: [
        {
            rel: 'stylesheet',
            href: 'https://fonts.googleapis.com/css2?family=Kanit:wght@300;400;500;600;700&display=swap'
        }
    ]
})
</script>

<style scoped>
* {
    font-family: 'Kanit', sans-serif;
}

.dropdown-menu {
    opacity: 0;
    visibility: hidden;
    transform: translateY(-10px);
    transition: all 0.3s ease;
}

.dropdown-trigger:hover .dropdown-menu {
    opacity: 1;
    visibility: visible;
    transform: translateY(0);
}

.dropdown-arrow::before {
    content: '';
    position: absolute;
    top: -6px;
    left: 50%;
    transform: translateX(-50%);
    width: 0;
    height: 0;
    border-left: 6px solid transparent;
    border-right: 6px solid transparent;
    border-bottom: 6px solid white;
}

.user-dropdown-arrow::before {
    left: 80%;
}

.rotate-180 {
    transform: rotate(180deg);
}
</style>