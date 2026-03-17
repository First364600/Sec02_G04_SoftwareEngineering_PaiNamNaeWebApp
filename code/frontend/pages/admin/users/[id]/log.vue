<template>
  <div>
    <AdminHeader />
    <AdminSidebar />
    <main id="main-content" class="main-content mt-16 ml-0 lg:ml-[280px] p-6">
      <div class="mx-auto max-w-8xl">

        <!-- Header -->
        <div class="flex items-center justify-between mb-6">
          <h1 class="text-2xl font-semibold text-gray-800">
            Log Event
          </h1>

          <div class="flex items-center gap-3">
            <button
              @click="openExportModal"
              class="inline-flex items-center px-4 py-2 text-white bg-blue-600 rounded-md hover:bg-blue-700"
            >
              Export
            </button>
          </div>
        </div>


        <!-- ================= USER SUMMARY TABLE ================= -->
        <div
          v-if="user && Object.keys(user).length"
          class="mb-6 overflow-hidden bg-white border border-gray-200 rounded-xl shadow-sm"
        >
          <table class="min-w-full text-sm text-gray-700">
            <thead class="bg-gray-50">
              <tr>
                <th class="px-4 py-3 text-xs text-left text-gray-500 uppercase">ผู้ใช้</th>
                <th class="px-4 py-3 text-xs text-left text-gray-500 uppercase">อีเมล</th>
                <th class="px-4 py-3 text-xs text-left text-gray-500 uppercase">ชื่อผู้ใช้</th>
                <th class="px-4 py-3 text-xs text-left text-gray-500 uppercase">บทบาท</th>
                <th class="px-4 py-3 text-xs text-left text-gray-500 uppercase">ยืนยันตัวตน</th>
                <th class="px-4 py-3 text-xs text-left text-gray-500 uppercase">สถานะ</th>
                <th class="px-4 py-3 text-xs text-left text-gray-500 uppercase">สร้างเมื่อ</th>
                <th class="px-4 py-3 text-xs text-left text-gray-500 uppercase">เบอร์โทร</th>
              </tr>
            </thead>
            <tbody class="divide-y">
              <tr class="hover:bg-gray-50">
                <!-- USER -->
                <td class="px-4 py-3">
                  <div class="flex items-center gap-3">
                    <img :src="getAvatarUrl(user)" class="object-cover rounded-full w-9 h-9" />
                    <div>
                      <div class="font-medium text-gray-900">
                        {{ user.firstName }} {{ user.lastName }}
                      </div>
                      <div class="text-xs text-gray-500">
                        {{ user.gender || '-' }}
                      </div>
                    </div>
                  </div>
                </td>
                <!-- EMAIL -->
                <td class="px-4 py-3">{{ user.email }}</td>
                <!-- USERNAME -->
                <td class="px-4 py-3">{{ user.username }}</td>
                <!-- ROLE -->
                <td class="px-4 py-3">
                  <span
                    class="inline-flex px-2 py-1 text-xs rounded-full"
                    :class="roleBadge(user.role)"
                  >
                    {{ user.role }}
                  </span>
                </td>
                <!-- VERIFY -->
                <td class="px-4 py-3">
                  <span
                    class="inline-flex px-2 py-1 text-xs rounded-full"
                    :class="user.isVerified ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-600'"
                  >
                    {{ user.isVerified ? 'ยืนยันแล้ว' : 'ยังไม่ยืนยัน' }}
                  </span>
                </td>
                <!-- STATUS -->
                <td class="px-4 py-3">
                  <span
                    class="inline-flex px-2 py-1 text-xs rounded-full"
                    :class="user.isActive ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-600'"
                  >
                    {{ user.isActive ? 'Active' : 'Disabled' }}
                  </span>
                </td>
                <!-- CREATED -->
                <td class="px-4 py-3">
                  {{ formatDate(user.createdAt) }}
                </td>
                <!-- PHONE -->
                <td class="px-4 py-3">
                  {{ user.phoneNumber || '-' }}
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <!-- ================= LOG TABLE CARD ================= -->
        <div class="bg-white border border-gray-200 rounded-xl shadow-sm">
          <!-- Pagination Header -->
          <div class="px-4 py-3 border-b">
            <div class="text-sm text-gray-600">
              หน้า {{ pagination.page }}/{{ pagination.totalPages }}
              ทั้งหมด {{ pagination.total }} รายการ
            </div>
          </div>

          <!-- Log Table -->
          <div class="w-full overflow-x-auto">
            <table class="min-w-[1200px] text-sm text-gray-700">
              <thead class="bg-gray-50">
                <tr>
                  <th class="px-4 py-3 text-left text-xs text-gray-500 uppercase w-[420px]">
                    Event
                  </th>
                  <th class="px-4 py-3 text-left text-xs text-gray-500 uppercase w-[260px]">
                    User Id
                  </th>
                  <th class="px-4 py-3 text-left text-xs text-gray-500 uppercase w-[220px]">
                    Name
                  </th>
                  <th class="px-4 py-3 text-left text-xs text-gray-500 uppercase w-[180px]">
                    Date
                  </th>
                  <th class="px-4 py-3 text-left text-xs text-gray-500 uppercase w-[140px]">
                    IP Address
                  </th>
                  <th class="px-4 py-3 text-left text-xs text-gray-500 uppercase w-[140px]">
                    Log Type
                  </th>
                </tr>
              </thead>
              <tbody class="divide-y">
                <tr
                  v-for="log in logs"
                  :key="log.id"
                  class="hover:bg-gray-50"
                >
                  <!-- EVENT -->
                  <td class="px-4 py-3 font-mono text-gray-600 max-w-[420px] truncate">
                    {{ log.event }}
                  </td>
                  <!-- USER ID -->
                  <td class="px-4 py-3 font-mono text-gray-500">
                    {{ log.userId }}
                  </td>
                  <!-- NAME -->
                  <td class="px-4 py-3">
                    {{ log.name }}
                  </td>
                  <!-- DATE -->
                  <td class="px-4 py-3">
                    {{ formatDate(log.createdAt) }}
                  </td>
                  <!-- IP -->
                  <td class="px-4 py-3 font-mono">
                    {{ log.ipAddress }}
                  </td>
                  <!-- LOG TYPE -->
                  <td class="px-4 py-3">
                    <span
                      class="px-2 py-1 text-xs rounded-full"
                      :class="getLogTypeClass(log.logType)"
                    >
                      {{ log.logType }}
                    </span>
                  </td>
                </tr>
                <tr v-if="!logs.length">
                  <td colspan="6" class="py-10 text-center text-gray-400">
                    ไม่มีข้อมูล Log
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Pagination -->
          <div class="flex justify-end gap-2 px-6 py-4 border-t">
            <button
              class="px-3 py-1 border rounded"
              :disabled="pagination.page <= 1"
              @click="changePage(pagination.page - 1)"
            >
              Previous
            </button>
            <button
              class="px-3 py-1 border rounded"
              :disabled="pagination.page >= pagination.totalPages"
              @click="changePage(pagination.page + 1)"
            >
              Next
            </button>
          </div>
        </div>

      </div>
    </main>

    <!-- ================= EXPORT MODAL ================= -->
    <div
      v-if="showExportModal"
      class="fixed inset-0 z-50 flex items-center justify-center bg-black/40"
    >
      <div class="w-full max-w-3xl p-8 bg-white rounded-2xl shadow-xl">
        <!-- Header -->
        <h2 class="mb-6 text-3xl font-semibold text-blue-600">
          Export log
        </h2>

        <!-- Personal Data Section -->
        <div class="p-6 mb-6 border rounded-xl">
          <h3 class="mb-4 font-semibold text-gray-700">
            ข้อมูลส่วนบุคคล
          </h3>
          <div class="space-y-4">
            <label class="flex items-center gap-3">
              <input type="checkbox" v-model="exportOptions.personal" class="w-5 h-5" />
              <span>ประวัติส่วนตัว</span>
            </label>
            <label class="flex items-center gap-3">
              <input type="checkbox" v-model="exportOptions.travel" class="w-5 h-5" />
              <span>ประวัติการเดินทาง</span>
            </label>
            <label class="flex items-center gap-3">
              <input type="checkbox" v-model="exportOptions.routes" class="w-5 h-5" />
              <span>ประวัติการสร้างเส้นทางและข้อมูลรถยนต์ (กรณีเป็นผู้ขับขี่)</span>
            </label>
          </div>
        </div>

        <!-- Date Range -->
        <div class="mb-6">
          <h3 class="mb-3 font-semibold text-gray-700">วันที่</h3>
          <div class="flex items-center gap-4">
            <input
              type="date"
              v-model="exportOptions.dateFrom"
              class="px-4 py-2 border rounded-lg"
            />
            <span>-</span>
            <input
              type="date"
              v-model="exportOptions.dateTo"
              class="px-4 py-2 border rounded-lg"
            />
          </div>
        </div>

        <!-- Log Type -->
        <div class="p-6 mb-6 border rounded-xl">
          <h3 class="mb-4 font-semibold text-gray-700">
            ประเภทของ Log
          </h3>
          <div class="space-y-4">
            <label class="flex items-center gap-3">
              <input type="checkbox" value="AUTH" v-model="exportOptions.logTypes" />
              <span>Authentication &amp; Access Logs</span>
            </label>
            <label class="flex items-center gap-3">
              <input type="checkbox" value="TRANSACTION" v-model="exportOptions.logTypes" />
              <span>Transactional &amp; Activity Logs</span>
            </label>
            <label class="flex items-center gap-3">
              <input type="checkbox" value="BEHAVIOR" v-model="exportOptions.logTypes" />
              <span>Navigation &amp; Behavioral Logs</span>
            </label>
            <label class="flex items-center gap-3">
              <input type="checkbox" value="SECURITY" v-model="exportOptions.logTypes" />
              <span>Security &amp; Audit Logs</span>
            </label>
          </div>
        </div>

        <!-- Footer Buttons -->
        <div class="flex justify-end gap-4">
          <button
            @click="closeExportModal"
            class="px-6 py-2 border rounded-lg"
          >
            Cancel
          </button>
          <button
            @click="confirmExport"
            class="px-6 py-2 text-white bg-blue-600 rounded-lg hover:bg-blue-700"
          >
            Export
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
definePageMeta({
  layout: 'admin'
})

import { ref, reactive, onMounted } from 'vue'
import { useRoute, useRuntimeConfig, useCookie } from '#app'
import dayjs from 'dayjs'
import AdminHeader from '~/components/admin/AdminHeader.vue'
import AdminSidebar from '~/components/admin/AdminSidebar.vue'

const route = useRoute()
const config = useRuntimeConfig()
const userId = route.params.id

const rawLogs = ref([])
const logs = ref([])
const user = ref({})
const isLoading = ref(false)

const pagination = reactive({
  page: 1,
  limit: 20,
  total: 0,
  totalPages: 1
})

const showExportModal = ref(false)
const exportOptions = reactive({
  personal: false,
  travel: false,
  routes: false,
  dateFrom: '',
  dateTo: '',
  logTypes: []
})

// Generate avatar URL อัตโนมัติ
const getAvatarUrl = (user) => {
  return (
    user?.profilePicture ||
    `https://ui-avatars.com/api/?name=${encodeURIComponent(user?.firstName || 'U')}&background=random&size=64`
  )
}

function openExportModal() {
  showExportModal.value = true
}

function closeExportModal() {
  showExportModal.value = false
}

function formatDate(d) {
  if (!d) return '-'
  return dayjs(d).format('DD/MM/YYYY HH:mm')
}

// ดึงข้อมูล Log จาก API
async function fetchLogs(page = 1) {
  isLoading.value = true
  try {
    const token = useCookie('token').value || localStorage.getItem('token')
    const res = await $fetch(`/logs`, {
      baseURL: config.public.apiBase,
      headers: { Authorization: `Bearer ${token}` },
      query: {
        page,
        limit: pagination.limit,
        userId: userId
      }
    })
    rawLogs.value = res.data || []
    logs.value = rawLogs.value.map((log) => ({
      id: log.id,
      event: log.action,
      userId: log.userId,
      name: log.user?.email || 'Guest',
      createdAt: log.createdAt,
      ipAddress: log.ipAddress,
      logType: log.logType || '-'
    }))
    pagination.page = res.meta?.current_page || page
    pagination.totalPages = res.meta?.total_pages || 1
    pagination.total = res.meta?.total_items || 0
  } catch (error) {
    console.error('Fetch Logs Error:', error)
  } finally {
    isLoading.value = false
  }
}

// โหลดข้อมูล User รายคน
async function fetchUser() {
  try {
    const token = useCookie('token').value || localStorage.getItem('token')
    const res = await $fetch(`/users/admin/${userId}`, {
      baseURL: config.public.apiBase,
      headers: { Authorization: `Bearer ${token}` }
    })
    user.value = res.data
  } catch (e) {
    console.error('fetch user error', e)
  }
}

// กำหนดสี role badge
function roleBadge(role) {
  if (role === 'ADMIN') return 'bg-purple-100 text-purple-700'
  if (role === 'DRIVER') return 'bg-blue-100 text-blue-700'
  return 'bg-gray-100 text-gray-700'
}

function changePage(p) {
  fetchLogs(p)
}

// กำหนดสี log type badge
function getLogTypeClass(logType) {
  if (logType === 'AUTH') return 'bg-blue-100 text-blue-700'
  if (logType === 'TRANSACTION') return 'bg-green-100 text-green-700'
  if (logType === 'BEHAVIOR') return 'bg-yellow-100 text-yellow-700'
  if (logType === 'SECURITY') return 'bg-red-100 text-red-700'
  return 'bg-gray-100 text-gray-600'
}

// Export XLSX
async function confirmExport() {
  try {
    const token = useCookie('token').value || localStorage.getItem('token')
    const params = new URLSearchParams()
    params.append('userId', userId)

    if (exportOptions.logTypes.length) {
      params.append('logType', exportOptions.logTypes.join(','))
    }
    if (exportOptions.personal) params.append('includePersonal', 'true')
    if (exportOptions.travel) params.append('includeTravel', 'true')
    if (exportOptions.routes) params.append('includeRoutes', 'true')
    if (exportOptions.dateFrom) params.append('dateFrom', exportOptions.dateFrom)
    if (exportOptions.dateTo) params.append('dateTo', exportOptions.dateTo)

    const url = `${config.public.apiBase}logs/export?${params.toString()}`
    const response = await fetch(url, {
      headers: { Authorization: `Bearer ${token}` }
    })

    const blob = await response.blob()

    // ดึงชื่อไฟล์จาก backend header
    let fileName = 'export.xlsx'
    const disposition = response.headers.get('Content-Disposition')
    if (disposition && disposition.includes('filename=')) {
      fileName = disposition.split('filename=')[1].replace(/"/g, '')
    }

    const downloadUrl = window.URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = downloadUrl
    a.download = fileName
    a.click()
    window.URL.revokeObjectURL(downloadUrl)

    closeExportModal()
  } catch (err) {
    console.error('Export error:', err)
  }
}

onMounted(() => {
  fetchLogs(1)
  fetchUser()
})
</script>