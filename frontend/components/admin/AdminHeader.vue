<template>
    <header class="fixed top-0 left-0 right-0 z-50 h-16 bg-white border border-gray-300 shadow-sm">
        <div class="flex items-center justify-between h-full px-4">
            <div class="flex items-center gap-4">
                <!-- Mobile Menu Toggle -->
                <button @click="toggleMobileSidebar" class="text-gray-600 lg:hidden hover:text-blue-600">
                    <i class="text-xl fas fa-bars"></i>
                </button>

                <!-- Logo -->
                <div class="flex items-center gap-2">
                    <div class="flex items-center justify-center w-8 h-8 bg-blue-600 rounded">
                        <i class="text-white fas fa-chart-line"></i>
                    </div>
                    <span class="text-xl font-semibold text-gray-800">PNNAdmin</span>
                </div>
            </div>

            <!-- Header Right -->
            <div class="flex items-center gap-4">
                <button class="relative text-gray-600 hover:text-blue-600">
                    <i class="text-xl fas fa-bell"></i>
                    <span class="absolute w-2 h-2 bg-red-500 rounded-full -top-1 -right-1"></span>
                </button>

                <div class="flex items-center gap-3">
                    <span class="hidden text-sm text-gray-700 md:block">{{ user.firstName }}</span>
                    <div class="flex items-center justify-center w-10 h-10 bg-blue-600 rounded-full">
                        <span class="font-semibold text-white">
                            <i class="w-6 text-lg text-center fas fa-user"></i>
                        </span>
                    </div>
                </div>
            </div>
        </div>
    </header>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import { useAuth } from '~/composables/useAuth'

const { token, user } = useAuth()
function toggleMobileSidebar() {
    const sidebar = document.getElementById('sidebar')
    const overlay = document.getElementById('overlay')
    if (!sidebar || !overlay) return
    sidebar.classList.toggle('mobile-open')
    overlay.classList.toggle('hidden')
}
</script>
