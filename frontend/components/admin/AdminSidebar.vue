<template>
    <aside id="sidebar" class="fixed bottom-0 left-0 bg-white shadow-lg sidebar top-16 ">
        <div class="py-4">
            <!-- Toggle Button -->
            <button onclick="toggleSidebar()"
                class="absolute flex items-center justify-center hidden w-6 h-6 transition-colors bg-white rounded-full shadow-md lg:block -right-3 top-6 hover:bg-blue-600 hover:text-white">
                <i class="text-xs fas fa-chevron-left" id="toggle-icon"></i>
            </button>

            <!-- Menu Items -->
            <nav class="px-3 space-y-1">
                <!-- User Profile -->
                <a href="#"
                    class="sidebar-item flex items-center gap-3 px-3 py-2.5 text-gray-700 rounded-lg hover:bg-blue-50">
                    <i class="w-6 text-lg text-center text-gray-500 fas fa-user"></i>
                    <span class="sidebar-text">User Profile</span>
                </a>

                <!-- Settings -->
                <div class="group">
                    <button onclick="toggleSubmenu('ecom-menu')"
                        class="sidebar-item w-full flex items-center justify-between gap-3 px-3 py-2.5 text-gray-700 rounded-lg hover:bg-blue-50">
                        <div class="flex items-center gap-3">
                            <i class="w-6 text-lg text-center text-gray-500 fas fa-user"></i>
                            <span class="sidebar-text">Setting</span>
                        </div>
                        <i class="text-xs transition-transform fas fa-chevron-down sidebar-text"
                            id="ecom-menu-icon"></i>
                    </button>
                    <div id="ecom-menu" class="hidden mt-1 ml-12 space-y-1 sidebar-text">
                        <a href="#" class="block px-3 py-2 text-sm text-gray-600 hover:text-blue-600">Logout</a>
                    </div>
                </div>
            </nav>
        </div>
    </aside>
</template>

<script setup>
</script>
