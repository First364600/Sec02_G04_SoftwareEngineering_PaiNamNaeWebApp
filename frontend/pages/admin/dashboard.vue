<template>

    <div class="">
        <AdminHeader />
        <AdminSidebar />

        <!-- Main Content -->
        <main id="main-content" class="main-content mt-16 ml-0 lg:ml-[280px] p-6">
            <!-- Page Title -->
            <div class="mx-auto max-w-8xl">
                <!-- Title + Controls -->
                <div class="flex flex-col gap-3 mb-6 sm:flex-row sm:items-center sm:justify-between">
                    <h1 class="text-2xl font-semibold text-gray-800">Users (Admin)</h1>


                    <!-- Quick Search -->
                    <div class="flex items-center gap-2">
                        <input v-model.trim="filters.q" @keyup.enter="applyFilters" type="text"
                            placeholder="ค้นหา : Email / User / Name"
                            class="max-w-full px-3 py-2 border border-gray-300 rounded-md w-72 focus:outline-none focus:ring-2 focus:ring-blue-500" />
                        <button @click="applyFilters"
                            class="px-4 py-2 text-white bg-blue-600 rounded-md hover:bg-blue-700">
                            ค้นหา
                        </button>
                    </div>
                </div>

                <!-- Advanced Filters -->
                <!-- Advanced Filters -->
                <div class="mb-4 bg-white border border-gray-300 rounded-lg shadow-sm">
                    <!-- 24-cols on lg; single column on mobile -->
                    <div class="grid grid-cols-1 gap-3 px-4 py-4 sm:px-6 lg:grid-cols-[repeat(24,minmax(0,1fr))]">
                        <!-- Role (3/24) -->
                        <div class="lg:col-span-3">
                            <label class="block mb-1 text-xs font-medium text-gray-600">บทบาท</label>
                            <select v-model="filters.role"
                                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500">
                                <option value="">ทั้งหมด</option>
                                <option value="ADMIN">ADMIN</option>
                                <option value="DRIVER">DRIVER</option>
                                <option value="PASSENGER">PASSENGER</option>
                            </select>
                        </div>

                        <!-- From (5/24) -->
                        <div class="lg:col-span-5">
                            <label class="block mb-1 text-xs font-medium text-gray-600">สร้างตั้งแต่
                                (YYYY-MM-DD)</label>
                            <input v-model="filters.createdFrom" type="date"
                                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500" />
                        </div>

                        <!-- To (5/24) -->
                        <div class="lg:col-span-5">
                            <label class="block mb-1 text-xs font-medium text-gray-600">ถึงวันที่</label>
                            <input v-model="filters.createdTo" type="date"
                                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500" />
                        </div>

                        <!-- SortBy (4/24) -->
                        <div class="lg:col-span-4">
                            <label class="block mb-1 text-xs font-medium text-gray-600">เรียงตาม</label>
                            <select v-model="filters.sortBy"
                                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500">
                                <option value="">(ค่าเริ่มต้น)</option>
                                <option value="createdAt">createdAt</option>
                                <option value="updatedAt">updatedAt</option>
                                <option value="lastLogin">lastLogin</option>
                            </select>
                        </div>

                        <!-- SortOrder (3/24) -->
                        <div class="lg:col-span-3">
                            <label class="block mb-1 text-xs font-medium text-gray-600">ลำดับ</label>
                            <select v-model="filters.sortOrder"
                                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500">
                                <option value="desc">desc</option>
                                <option value="asc">asc</option>
                            </select>
                        </div>

                        <!-- Actions (4/24) -->
                        <div class="flex items-end justify-end gap-2 lg:col-span-4">
                            <button @click="clearFilters"
                                class="px-3 py-2 text-gray-700 border border-gray-300 rounded-md hover:bg-gray-50">
                                ล้างตัวกรอง
                            </button>
                            <button @click="applyFilters"
                                class="px-4 py-2 text-white bg-blue-600 rounded-md hover:bg-blue-700">
                                ใช้ตัวกรอง
                            </button>
                        </div>
                    </div>
                </div>

                <!-- Card -->
                <div class="bg-white border border-gray-300 rounded-lg shadow-sm">
                    <div class="flex items-center justify-between px-4 py-4 border-b border-gray-200 sm:px-6">
                        <div class="text-sm text-gray-600">
                            หน้าที่ {{ pagination.page }} / {{ totalPages }} • ทั้งหมด {{ pagination.total }} ผู้ใช้
                        </div>
                        <!-- <div class="text-sm text-gray-500">limit: {{ pagination.limit }}</div> -->
                    </div>

                    <!-- Loading / Error -->
                    <div v-if="isLoading" class="p-8 text-center text-gray-500">กำลังโหลดข้อมูล...</div>
                    <div v-else-if="loadError" class="p-8 text-center text-red-600">
                        {{ loadError }}
                    </div>

                    <!-- Table -->
                    <div v-else class="overflow-x-auto">
                        <table class="min-w-full divide-y divide-gray-200">
                            <thead class="bg-gray-50">
                                <tr>
                                    <th class="px-4 py-3 text-xs font-medium text-left text-gray-500 uppercase">ผู้ใช้
                                    </th>
                                    <th class="px-4 py-3 text-xs font-medium text-left text-gray-500 uppercase">อีเมล
                                    </th>
                                    <th class="px-4 py-3 text-xs font-medium text-left text-gray-500 uppercase">
                                        ชื่อผู้ใช้</th>
                                    <th class="px-4 py-3 text-xs font-medium text-left text-gray-500 uppercase">บทบาท
                                    </th>
                                    <th class="px-4 py-3 text-xs font-medium text-left text-gray-500 uppercase">
                                        ยืนยันตัวตน</th>
                                    <th class="px-4 py-3 text-xs font-medium text-left text-gray-500 uppercase">สถานะ
                                    </th>
                                    <th class="px-4 py-3 text-xs font-medium text-left text-gray-500 uppercase">
                                        สร้างเมื่อ</th>
                                    <th class="px-4 py-3 text-xs font-medium text-left text-gray-500 uppercase">
                                        การกระทำ</th>
                                </tr>
                            </thead>
                            <tbody class="bg-white divide-y divide-gray-200">
                                <tr v-for="u in users" :key="u.id" class="hover:bg-gray-50">
                                    <td class="px-4 py-3">
                                        <div class="flex items-center gap-3">
                                            <img :src="u.profilePicture || `https://ui-avatars.com/api/?name=${encodeURIComponent(u.firstName || 'U')}&background=random&size=64`"
                                                class="object-cover rounded-full w-9 h-9" alt="avatar" />
                                            <div>
                                                <div class="font-medium text-gray-900">
                                                    {{ u.firstName }} {{ u.lastName }}
                                                </div>
                                                <div class="text-xs text-gray-500">
                                                    {{ u.gender || '-' }}
                                                </div>
                                            </div>
                                        </div>
                                    </td>
                                    <td class="px-4 py-3 text-gray-700">{{ u.email }}</td>
                                    <td class="px-4 py-3 text-gray-700">{{ u.username }}</td>
                                    <td class="px-4 py-3">
                                        <span
                                            class="inline-flex items-center px-2 py-1 text-xs font-medium rounded-full"
                                            :class="roleBadge(u.role)">
                                            <i class="mr-1 fa-solid fa-shield-halved" v-if="u.role === 'ADMIN'"></i>
                                            {{ u.role }}
                                        </span>
                                    </td>
                                    <td class="px-4 py-3">
                                        <span
                                            class="inline-flex items-center px-2 py-1 text-xs font-medium rounded-full"
                                            :class="u.isVerified ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-600'">
                                            <i class="mr-1 fa-solid fa-circle-check" v-if="u.isVerified"></i>
                                            {{ u.isVerified ? 'ยืนยันแล้ว' : 'ยังไม่ยืนยัน' }}
                                        </span>
                                    </td>
                                    <td class="px-4 py-3">
                                        <span
                                            class="inline-flex items-center px-2 py-1 text-xs font-medium rounded-full"
                                            :class="u.isActive ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700'">
                                            {{ u.isActive ? 'ใช้งาน' : 'ปิดการใช้งาน' }}
                                        </span>
                                    </td>
                                    <td class="px-4 py-3 text-gray-700">
                                        <div class="text-sm">
                                            {{ formatDate(u.createdAt) }}
                                        </div>
                                        <div class="text-xs text-gray-500">
                                            อัปเดต {{ formatDate(u.updatedAt) }}
                                        </div>
                                    </td>

                                    <td class="px-4 py-3 ">
                                        <button @click="onEditUser(u)"
                                            class="p-2 text-gray-500 transition-colors hover:text-blue-600"
                                            title="แก้ไข" aria-label="แก้ไข">
                                            <i class="text-lg fa-regular fa-pen-to-square"></i>
                                        </button>
                                        <button @click="onDeleteUser(u)"
                                            class="p-2 text-gray-500 transition-colors hover:text-red-600" title="ลบ"
                                            aria-label="ลบ">
                                            <i class="text-lg fa-regular fa-trash-can"></i>
                                        </button>
                                    </td>
                                </tr>


                                <tr v-if="!users.length">
                                    <td colspan="7" class="px-4 py-10 text-center text-gray-500">ไม่มีข้อมูลผู้ใช้</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>


                    <!-- Pagination (footer) -->
                    <div
                        class="flex flex-col gap-3 px-4 py-4 border-t border-gray-200 sm:px-6 sm:flex-row sm:items-center sm:justify-between">
                        <!-- Left: info + limit -->
                        <div class="flex flex-wrap items-center gap-3 text-sm">
                            <!-- <span>หน้าที่ {{ pagination.page }} / {{ totalPages }} • ทั้งหมด {{ pagination.total }}
                                ผู้ใช้</span> -->

                            <div class="flex items-center gap-2">
                                <span class="text-xs text-gray-500">Limit:</span>
                                <select v-model.number="pagination.limit" @change="applyFilters"
                                    class="px-2 py-1 text-sm border border-gray-300 rounded-md focus:ring-blue-500">
                                    <option :value="10">10</option>
                                    <option :value="20">20</option>
                                    <option :value="50">50</option>
                                </select>
                            </div>
                        </div>

                        <!-- Right: pager -->
                        <nav class="flex items-center gap-1">
                            <button class="px-3 py-2 text-sm border rounded-md disabled:opacity-50"
                                :disabled="pagination.page <= 1 || isLoading" @click="changePage(pagination.page - 1)">
                                Previous
                            </button>

                            <!-- page numbers + ellipsis -->
                            <template v-for="(p, idx) in pageButtons" :key="`p-${idx}-${p}`">
                                <span v-if="p === '…'" class="px-2 text-sm text-gray-500">…</span>
                                <button v-else class="px-3 py-2 text-sm border rounded-md"
                                    :class="p === pagination.page ? 'bg-blue-50 text-blue-600 border-blue-200' : 'hover:bg-gray-50'"
                                    :disabled="isLoading" @click="changePage(p)">
                                    {{ p }}
                                </button>
                            </template>

                            <button class="px-3 py-2 text-sm border rounded-md disabled:opacity-50"
                                :disabled="pagination.page >= totalPages || isLoading"
                                @click="changePage(pagination.page + 1)">
                                Next
                            </button>
                        </nav>
                    </div>
                </div>
            </div>

        </main>

        <!-- Mobile Overlay -->
        <div id="overlay" class="fixed inset-0 z-40 hidden bg-black bg-opacity-50 lg:hidden"
            onclick="closeMobileSidebar()">
        </div>
    </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted, onUnmounted } from 'vue'
import dayjs from 'dayjs'
import 'dayjs/locale/th'
import buddhistEra from 'dayjs/plugin/buddhistEra'
import AdminHeader from '~/components/admin/AdminHeader.vue'
import AdminSidebar from '~/components/admin/AdminSidebar.vue'
import { useToast } from '~/composables/useToast'

dayjs.locale('th')
dayjs.extend(buddhistEra)

definePageMeta({
    middleware: ['admin-auth']
})

const { $api } = useNuxtApp()
const { toast } = useToast()

const isLoading = ref(false)
const loadError = ref('')
const users = ref([])

const pagination = reactive({
    page: 1,
    limit: 20,
    total: 0,
    totalPages: 1
})

const filters = reactive({
    q: '',                 // full-text
    role: '',              // ADMIN/DRIVER/PASSENGER
    createdFrom: '',       // YYYY-MM-DD
    createdTo: '',         // YYYY-MM-DD
    sortBy: '',            // createdAt/updatedAt/lastLogin
    sortOrder: 'desc'      // asc/desc
})

// const hasActiveFilters = computed(() =>
//     !!(filters.q || filters.role || filters.createdFrom || filters.createdTo || filters.sortBy || (filters.sortOrder && filters.sortOrder !== 'desc'))
// )

const totalPages = computed(() =>
    Math.max(1, pagination.totalPages || Math.ceil((pagination.total || 0) / (pagination.limit || 20)))
)

const pageButtons = computed(() => {
    const total = totalPages.value
    const current = pagination.page

    if (!total || total < 1) return []
    if (total <= 5) return Array.from({ length: total }, (_, i) => i + 1)

    // รวมหน้าแรก/สุดท้าย/ปัจจุบัน + เพื่อนบ้าน
    const set = new Set([1, total, current])
    if (current - 1 > 1) set.add(current - 1)
    if (current + 1 < total) set.add(current + 1)

    const pages = Array.from(set).sort((a, b) => a - b)

    // แทรก "…" เมื่อมีช่องว่างของหน้า
    const out = []
    for (let i = 0; i < pages.length; i++) {
        if (i > 0 && pages[i] - pages[i - 1] > 1) out.push('…')
        out.push(pages[i])
    }
    return out
})

function roleBadge(role) {
    if (role === 'ADMIN') return 'bg-purple-100 text-purple-700'
    if (role === 'DRIVER') return 'bg-blue-100 text-blue-700'
    return 'bg-gray-100 text-gray-700'
}

function formatDate(iso) {
    if (!iso) return '-'
    return dayjs(iso).format('D MMMM BBBB HH:mm')
}

async function fetchUsers(page = 1) {
    isLoading.value = true
    loadError.value = ''

    try {
        const res = await $api('/users/admin', {
            method: 'GET',
            query: {
                page,
                limit: pagination.limit,
                // map filters to API (omit empty)
                q: filters.q || undefined,
                role: filters.role || undefined,
                createdFrom: filters.createdFrom || undefined,
                createdTo: filters.createdTo || undefined,
                sortBy: filters.sortBy || undefined,
                sortOrder: filters.sortOrder || undefined
            }
        })

        users.value = Array.isArray(res) ? res : (res?.data ?? [])
        const p = Array.isArray(res) ? {} : (res?.pagination ?? {})
        pagination.page = p.page || page
        pagination.limit = p.limit || pagination.limit
        pagination.total = p.total ?? users.value.length
        pagination.totalPages = p.totalPages || Math.ceil(pagination.total / pagination.limit)

    } catch (err) {
        console.error(err)
        loadError.value = err?.data?.message || 'ไม่สามารถโหลดข้อมูลได้'
        toast.error('เกิดข้อผิดพลาด', loadError.value)
        users.value = []
    } finally {
        isLoading.value = false
    }
}

function changePage(next) {
    if (next < 1 || next > totalPages.value) return
    fetchUsers(next)
}

function applyFilters() {
    pagination.page = 1
    fetchUsers(1)
}

function clearFilters() {
    filters.q = ''
    filters.role = ''
    filters.createdFrom = ''
    filters.createdTo = ''
    filters.sortBy = ''
    filters.sortOrder = 'desc'
    pagination.page = 1
    fetchUsers(1)
}

function onEditUser(u) {
    // ปรับเส้นทางตามระบบของคุณ
    // เช่นมีเพจแก้ไข: /admin/users/[id]/edit
    navigateTo(`/admin/users/${u.id}/edit`).catch(() => { })
}

async function onDeleteUser(u) {
    const ok = confirm(`ยืนยันการลบผู้ใช้: ${u.email || u.username || u.id} ?`)
    if (!ok) return

    try {
        // TODO: เรียก API ลบจริงตามหลังบ้านของคุณ
        // await $api(`/users/admin/${u.id}`, { method: 'DELETE' })

        // ตัวอย่าง: แสดง toast และรีโหลดรายการ
        toast.success('ลบผู้ใช้แล้ว', `ID: ${u.id}`)
        fetchUsers(pagination.page)
    } catch (err) {
        console.error(err)
        toast.error('ลบไม่สำเร็จ', err?.data?.message || 'เกิดข้อผิดพลาด')
    }
}

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
    if (typeof window.__adminResizeHandler__ === 'function') window.__adminResizeHandler__()
    fetchUsers(1)
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
