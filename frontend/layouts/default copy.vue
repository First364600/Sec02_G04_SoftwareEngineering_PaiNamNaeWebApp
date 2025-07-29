<template>
    <div>
        <header class="bg-white shadow-sm  sticky top-0 z-50">
            <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                <div class="flex justify-between items-center h-16">
                    <!-- Logo -->
                    <h1 class="text-xl sm:text-2xl font-bold text-blue-600">Car Pool</h1>

                    <!-- Desktop Nav -->
                    <nav class="hidden md:flex space-x-6 lg:space-x-8">
                        <NuxtLink to="/" class="text-blue-600 font-medium hover:text-blue-700">ค้นหาเส้นทาง
                        </NuxtLink>
                        <NuxtLink to="/" class="text-gray-600 hover:text-blue-600">เสนอเส้นทาง</NuxtLink>
                        <NuxtLink to="/" class="text-gray-600 hover:text-blue-600">การเดินทางของฉัน</NuxtLink>

                        <!-- User Profile -->
                        <div v-if="!token" class="flex items-center space-x-3 ">
                            <NuxtLink to="/register"
                                class="text-gray-600 hover:text-blue-600 transition-colors duration-200">สมัครสมาชิก</NuxtLink>
                            <span class="text-gray-600">|</span>
                            <NuxtLink to="/login"
                                class="text-gray-600 hover:text-blue-600 transition-colors duration-200">เข้าสู่ระบบ</NuxtLink>
                        </div>
                    </nav>

                    <!-- Mobile menu button -->
                    <button @click="isOpen = !isOpen"
                        class="md:hidden text-gray-600 hover:text-blue-600 focus:outline-none transition-colors duration-200">
                        <svg v-if="!isOpen" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                d="M4 6h16M4 12h16M4 18h16" />
                        </svg>
                        <svg v-else class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                d="M6 18L18 6M6 6l12 12" />
                        </svg>
                    </button>
                </div>

                <!-- Mobile Nav -->
                <div v-show="isOpen" class="md:hidden border-t border-gray-200 bg-white">
                    <div class="px-2 pt-2 pb-3 space-y-1">
                        <NuxtLink to="/" class="block px-3 py-2 text-blue-600 font-medium bg-blue-50 rounded-md">
                            ค้นหาเส้นทาง</NuxtLink>
                        <NuxtLink to="/"
                            class="block px-3 py-2 text-gray-600 hover:text-blue-600 hover:bg-blue-50 rounded-md">
                            เสนอเส้นทาง</NuxtLink>
                        <NuxtLink to="/"
                            class="block px-3 py-2 text-gray-600 hover:text-blue-600 hover:bg-blue-50 rounded-md">
                            การเดินทางของฉัน</NuxtLink>
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
import { ref } from 'vue'
import { useAuth } from '~/composables/useAuth'

const isOpen = ref(false)
const { token, user, logout } = useAuth()
</script>

<style scoped>
body {
    font-family: 'Kanit', sans-serif;
}
</style>
