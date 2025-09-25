<template>

    <div class="">
        <AdminHeader />
        <AdminSidebar />

        <!-- Main Content -->
        <main id="main-content" class="main-content mt-16 ml-0 lg:ml-[280px] p-6">
            <!-- Page Title -->
             <h1>dsds</h1>

        </main>

        <!-- Mobile Overlay -->
        <div id="overlay" class="fixed inset-0 z-40 hidden bg-black bg-opacity-50 lg:hidden"
            onclick="closeMobileSidebar()"></div>
    </div>
</template>

<script setup>
import { onMounted, onUnmounted } from 'vue'
import AdminHeader from '~/components/admin/AdminHeader.vue'
import AdminSidebar from '~/components/admin/AdminSidebar.vue'

useHead({
    title: 'TailAdmin Dashboard',
    link: [
        {
            rel: 'stylesheet',
            href: 'https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css'
        }
    ]
})

function defineGlobalScripts() {
    window.toggleSidebar = function () {
        const sidebar = document.getElementById('sidebar');
        const mainContent = document.getElementById('main-content');
        const toggleIcon = document.getElementById('toggle-icon');

        if (!sidebar || !mainContent || !toggleIcon) return;

        sidebar.classList.toggle('collapsed');

        if (sidebar.classList.contains('collapsed')) {
            mainContent.style.marginLeft = '80px';
            toggleIcon.classList.replace('fa-chevron-left', 'fa-chevron-right');
        } else {
            mainContent.style.marginLeft = '280px';
            toggleIcon.classList.replace('fa-chevron-right', 'fa-chevron-left');
        }
    }

    window.toggleMobileSidebar = function () {
        const sidebar = document.getElementById('sidebar');
        const overlay = document.getElementById('overlay');

        if (!sidebar || !overlay) return;

        sidebar.classList.toggle('mobile-open');
        overlay.classList.toggle('hidden');
    }

    window.closeMobileSidebar = function () {
        const sidebar = document.getElementById('sidebar');
        const overlay = document.getElementById('overlay');

        if (!sidebar || !overlay) return;

        sidebar.classList.remove('mobile-open');
        overlay.classList.add('hidden');
    }

    window.toggleSubmenu = function (menuId) {
        const menu = document.getElementById(menuId);
        const icon = document.getElementById(menuId + '-icon');

        if (!menu || !icon) return;

        menu.classList.toggle('hidden');

        if (menu.classList.contains('hidden')) {
            icon.classList.replace('fa-chevron-up', 'fa-chevron-down');
        } else {
            icon.classList.replace('fa-chevron-down', 'fa-chevron-up');
        }
    }

    // Resize listener ตามต้นฉบับ
    window.__adminResizeHandler__ = function () {
        const sidebar = document.getElementById('sidebar');
        const mainContent = document.getElementById('main-content');
        const overlay = document.getElementById('overlay');

        if (!sidebar || !mainContent || !overlay) return;

        if (window.innerWidth >= 1024) {
            sidebar.classList.remove('mobile-open');
            overlay.classList.add('hidden');

            if (sidebar.classList.contains('collapsed')) {
                mainContent.style.marginLeft = '80px';
            } else {
                mainContent.style.marginLeft = '280px';
            }
        } else {
            mainContent.style.marginLeft = '0';
        }
    }

    window.addEventListener('resize', window.__adminResizeHandler__)
}

function cleanupGlobalScripts() {
    window.removeEventListener('resize', window.__adminResizeHandler__ || (() => { }))
    delete window.toggleSidebar
    delete window.toggleMobileSidebar
    delete window.closeMobileSidebar
    delete window.toggleSubmenu
    delete window.__adminResizeHandler__
}

onMounted(() => {
    defineGlobalScripts()
    // run once to set correct margin on load for current viewport
    if (typeof window.__adminResizeHandler__ === 'function') {
        window.__adminResizeHandler__()
    }
})

onUnmounted(() => {
    cleanupGlobalScripts()
})
</script>

<style>
.sidebar {
    transition: width 0.3s ease;
}

.sidebar.collapsed {
    width: 80px;
}

.sidebar:not(.collapsed) {
    width: 280px;
}

.sidebar-item {
    transition: all 0.3s ease;
}

.sidebar-item:hover {
    background-color: rgba(59, 130, 246, 0.05);
}

.sidebar.collapsed .sidebar-text {
    display: none;
}

.sidebar.collapsed .sidebar-item {
    justify-content: center;
}

.main-content {
    transition: margin-left 0.3s ease;
}

@media (max-width: 768px) {
    .sidebar {
        position: fixed;
        z-index: 1000;
        transform: translateX(-100%);
    }

    .sidebar.mobile-open {
        transform: translateX(0);
    }

    .main-content {
        margin-left: 0 !important;
    }
}
</style>
