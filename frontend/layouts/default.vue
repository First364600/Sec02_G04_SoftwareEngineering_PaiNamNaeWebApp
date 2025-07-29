<template>
    <div>
        <!-- Header -->
        <header class="bg-white shadow-sm  sticky top-0 z-50">
            <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                <div class="flex justify-between items-center h-16">
                    <!-- Logo -->
                    <NuxtLink to="/">
                        <div class="flex items-center">
                            <h1 class="text-xl sm:text-2xl font-bold text-blue-600">ไปนำแหน่</h1>
                        </div>
                    </NuxtLink>

                    <!-- Desktop Navigation -->
                    <nav class="hidden md:flex items-center space-x-6 lg:space-x-8">
                        <NuxtLink to="/findTrip"
                            class="text-gray-600 font-medium hover:text-blue-700 transition-colors duration-200"
                            :class="{ 'text-blue-600': $route.path === '/findTrip' }">
                            ค้นหาเส้นทาง
                        </NuxtLink>

                        <NuxtLink to="/createTrip"
                            class="text-gray-600 hover:text-blue-600 transition-colors duration-200"
                            :class="{ 'text-blue-600': $route.path === '/createTrip' }">
                            สร้างเส้นทาง
                        </NuxtLink>

                        <!-- การเดินทางของฉัน with dropdown -->
                        <div class="relative dropdown-trigger">
                            <NuxtLink to="/"
                                class="text-gray-600 hover:text-blue-600 transition-colors duration-200 flex items-center"
                                :class="{ 'text-blue-600': $route.path.startsWith('/') }">
                                การเดินทางของฉัน
                                <svg class="w-4 h-4 ml-1 transition-transform duration-200" fill="none"
                                    stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                        d="M19 9l-7 7-7-7"></path>
                                </svg>
                            </NuxtLink>
                            <!-- Dropdown Menu -->
                            <div
                                class="dropdown-menu absolute top-full left-0 mt-2 w-48 bg-white rounded-lg shadow-lg border border-gray-200 py-2 dropdown-arrow">
                                <NuxtLink to="/"
                                    class="block px-4 py-2 text-gray-700 hover:bg-blue-50 hover:text-blue-600 transition-colors duration-200">
                                    การเดินทางทั้งหมด
                                </NuxtLink>
                            </div>
                        </div>
                        <div v-if="!token" class="flex items-center space-x-3 ">
                            <a href="#"
                                class="text-gray-600 hover:text-blue-600 transition-colors duration-200">สมัครสมาชิก</a>
                            <span class="text-gray-600">|</span>
                            <a href="/login"
                                class="text-gray-600 hover:text-blue-600 transition-colors duration-200">เข้าสู่ระบบ</a>
                        </div>
                        <!-- User Profile with dropdown -->
                        <div v-else-if="user && user.role === 'PASSENGER'" class="relative dropdown-trigger">
                            <div
                                class="flex items-center space-x-2 pl-4 border-l border-gray-200 cursor-pointer hover:bg-blue-50 rounded-lg px-3 py-2 transition-colors duration-200">
                                <div class="w-8 h-8 bg-blue-100 rounded-full flex items-center justify-center">
                                    <svg class="w-5 h-5 text-blue-600" fill="none" stroke="currentColor"
                                        viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                            d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                                    </svg>
                                </div>
                                <span class="text-blue-600 font-medium">{{ user.firstName }}</span>
                                <svg class="w-4 h-4 text-blue-600 transition-transform duration-200" fill="none"
                                    stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                        d="M19 9l-7 7-7-7"></path>
                                </svg>
                            </div>
                            <!-- User Dropdown Menu -->
                            <div
                                class="dropdown-menu absolute top-full right-0 mt-2 w-40 bg-white rounded-lg shadow-lg border border-gray-200 py-2 user-dropdown-arrow">
                                <NuxtLink to="/profile"
                                    class="w-full text-left block px-4 py-2 text-gray-700 hover:bg-blue-50 hover:text-blue-600 transition-colors duration-200 flex items-center">

                                    บัญชีของฉัน
                                </NuxtLink>
                                <button @click="logout"
                                    class="w-full text-left block px-4 py-2 text-red-600 hover:bg-red-50 hover:text-red-700 transition-colors duration-200 flex items-center">
                                    <!-- <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                            d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1">
                                        </path>
                                    </svg> -->
                                    Logout
                                </button>
                            </div>
                        </div>
                    </nav>

                    <!-- Mobile menu button -->
                    <div class="md:hidden">
                        <button @click="toggleMobileMenu" type="button"
                            class="text-gray-600 hover:text-blue-600 focus:outline-none focus:text-blue-600 transition-colors duration-200">
                            <svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path v-if="!isMobileMenuOpen" stroke-linecap="round" stroke-linejoin="round"
                                    stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
                                <path v-else stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                    d="M6 18L18 6M6 6l12 12" />
                            </svg>
                        </button>
                    </div>
                </div>

                <!-- Mobile Navigation Menu -->
                <div v-show="isMobileMenuOpen" class="md:hidden border-t border-gray-200">
                    <div class="px-2 pt-2 pb-3 space-y-1 bg-white">
                        <NuxtLink to="/" class="block px-3 py-2 font-medium rounded-md transition-colors duration-200"
                            :class="$route.path === '/' ? 'text-blue-600 bg-blue-50' : 'text-gray-600 hover:text-blue-600 hover:bg-blue-50'"
                            @click="closeMobileMenu">
                            ค้นหาเส้นทาง
                        </NuxtLink>

                        <NuxtLink to="/" class="block px-3 py-2 rounded-md transition-colors duration-200"
                            :class="$route.path === '/' ? 'text-blue-600 bg-blue-50' : 'text-gray-600 hover:text-blue-600 hover:bg-blue-50'"
                            @click="closeMobileMenu">
                            สร้างเส้นทาง
                        </NuxtLink>

                        <!-- Mobile dropdown for การเดินทางของฉัน -->
                        <div class="relative">
                            <button @click="toggleMobileTripMenu"
                                class="w-full text-left px-3 py-2 text-gray-600 hover:text-blue-600 hover:bg-blue-50 rounded-md transition-colors duration-200 flex items-center justify-between">
                                การเดินทางของฉัน
                                <svg class="w-4 h-4 transition-transform duration-200"
                                    :class="{ 'rotate-180': isMobileTripMenuOpen }" fill="none" stroke="currentColor"
                                    viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                        d="M19 9l-7 7-7-7"></path>
                                </svg>
                            </button>
                            <div v-show="isMobileTripMenuOpen" class="ml-4 mt-1">
                                <NuxtLink to="/"
                                    class="block px-3 py-2 text-gray-500 hover:text-blue-600 hover:bg-blue-50 rounded-md transition-colors duration-200"
                                    @click="closeMobileMenu">
                                    การเดินทางทั้งหมด
                                </NuxtLink>
                            </div>
                        </div>

                        <div v-if="!token">
                            <NuxtLink to="/" class="block px-3 py-2 rounded-md transition-colors duration-200"
                                :class="$route.path === '/' ? 'text-blue-600 bg-blue-50' : 'text-gray-600 hover:text-blue-600 hover:bg-blue-50'"
                                @click="closeMobileMenu">
                                สมัครสมาชิก
                            </NuxtLink>

                            <NuxtLink to="/login" class="block px-3 py-2 rounded-md transition-colors duration-200"
                                :class="$route.path === '/login' ? 'text-blue-600 bg-blue-50' : 'text-gray-600 hover:text-blue-600 hover:bg-blue-50'"
                                @click="closeMobileMenu">
                                เข้าสู่ระบบ
                            </NuxtLink>
                        </div>

                        <!-- Mobile User Profile -->
                        <div v-else-if="user && user.role === 'PASSENGER'" class="border-t border-gray-200 pt-2 mt-2">
                            <div class="flex items-center px-3 py-2">
                                <div class="w-8 h-8 bg-blue-100 rounded-full flex items-center justify-center">
                                    <svg class="w-5 h-5 text-blue-600" fill="none" stroke="currentColor"
                                        viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                            d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                                    </svg>
                                </div>
                                <span class="ml-2 text-gray-700 font-medium">{{ user.firstName }}</span>
                            </div>
                            <div class="ml-6 mt-1">
                                <button @click="logout"
                                    class="w-full text-left block px-3 py-2 text-red-600 hover:bg-red-50 hover:text-red-700 rounded-md transition-colors duration-200 flex items-center">
                                    <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                            d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1">
                                        </path>
                                    </svg>
                                    Logout
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
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
// Reactive data
const isMobileMenuOpen = ref(false)
const isMobileTripMenuOpen = ref(false)

// Methods
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

// Handle click outside to close mobile menu
const handleClickOutside = (event) => {
    // You can add logic here if needed
}

const handleResize = () => {
    if (window.innerWidth >= 768) {
        isMobileMenuOpen.value = false
        isMobileTripMenuOpen.value = false
    }
}

// Lifecycle hooks
onMounted(() => {
    document.addEventListener('click', handleClickOutside)
    window.addEventListener('resize', handleResize)
})

onUnmounted(() => {
    document.removeEventListener('click', handleClickOutside)
    window.removeEventListener('resize', handleResize)
})

// SEO Head (optional)
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

/* Arrow for dropdown */
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

/* Smooth rotate animation */
.rotate-180 {
    transform: rotate(180deg);
}
</style>