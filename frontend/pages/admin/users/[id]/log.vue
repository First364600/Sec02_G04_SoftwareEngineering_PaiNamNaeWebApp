<template>
  <div>
    <AdminHeader />
    <AdminSidebar />

    <main id="main-content" class="main-content mt-16 ml-0 lg:ml-[280px] p-6">
      <div class="mx-auto max-w-8xl">

        <!-- Header -->
        <div class="flex items-center justify-between mb-6">
          <h1 class="text-2xl font-semibold text-gray-800">Log Event</h1>

          <button
            @click="exportLogs"
            class="inline-flex items-center gap-2 px-4 py-2 text-white bg-blue-600 rounded-md hover:bg-blue-700"
            >
            Export
          </button>
        </div>

        <!-- ================= USER SUMMARY TABLE ================= -->
        <div v-if="user && Object.keys(user).length" class="mb-6 overflow-hidden bg-white border border-gray-200 rounded-xl shadow-sm">
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
                    <img
                      :src="user.profilePicture || avatarFallback"
                      class="object-cover rounded-full w-9 h-9"
                    />
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
                    :class="user.isVerified
                      ? 'bg-green-100 text-green-700'
                      : 'bg-gray-100 text-gray-600'"
                  >
                    {{ user.isVerified ? 'Verified' : 'Pending' }}
                  </span>
                </td>

                <!-- STATUS -->
                <td class="px-4 py-3">
                  <span
                    class="inline-flex px-2 py-1 text-xs rounded-full"
                    :class="user.isActive
                      ? 'bg-green-100 text-green-700'
                      : 'bg-gray-100 text-gray-600'"
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
                  <div class="overflow-hidden">
                    <table class="min-w-full text-sm text-gray-700">
                      <thead class="bg-gray-50">
                        <tr>
                          <th class="px-4 py-3 text-left text-xs text-gray-500 uppercase">Event</th>
                          <th class="px-4 py-3 text-left text-xs text-gray-500 uppercase">User Id</th>
                          <th class="px-4 py-3 text-left text-xs text-gray-500 uppercase">Name</th>
                          <th class="px-4 py-3 text-left text-xs text-gray-500 uppercase">Date</th>
                          <th class="px-4 py-3 text-left text-xs text-gray-500 uppercase">IP Adddress</th>
                          <th class="px-4 py-3 text-left text-xs text-gray-500 uppercase">Log on - Log off</th>
                        </tr>
                      </thead>

                      <tbody class="divide-y">
                        <tr v-for="log in logs" :key="log.id">
                          <td class="px-4 py-3">{{ log.event }}</td>
                          <td class="px-4 py-3">{{ log.userId }}</td>
                          <td class="px-4 py-3">{{ log.name }}</td>
                          <td class="px-4 py-3">{{ formatDate(log.date) }}</td>
                          <td class="px-4 py-3">{{ log.ip }}</td>
                        
                          <td class="px-4 py-3">
                            <span
                              class="px-2 py-1 text-xs rounded-full"
                              :class="getStatusClass(log.session)"
                            >
                              {{ log.session }}
                            </span>
                          </td>
                        </tr>

                        <tr v-if="!logs.length">
                          <td colspan="7" class="py-10 text-center text-gray-400">
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

const search = ref('') //เก็บค่า search text
const dateFrom = ref('') //เก็บวันที่เริ่มต้น filter
const dateTo = ref('') //เก็บวันที่สิ้นสุด filter


const route = useRoute()
const config = useRuntimeConfig()

const userId = route.params.id

const logs = ref([])
const user = ref({})
const isLoading = ref(false)

const pagination = reactive({
  page: 1,
  limit: 20,
  total: 0,
  totalPages: 1
})

//generate รูปโปรไฟล์อัตโนมัติ
const avatarFallback =
  'https://ui-avatars.com/api/?name=U&background=random'

function formatDate(d) {
  if (!d) return '-'
  return dayjs(d).format('DD/MM/YYYY HH:mm')
}

//ดึงข้อมูล Log จาก API
async function fetchLogs(page = 1) {
  isLoading.value = true
  try {
    const token =
      useCookie('token').value ||
      localStorage.getItem('token')

    const res = await $fetch(`/logs`, {
      baseURL: config.public.apiBase,
      headers: {
        Authorization: `Bearer ${token}`
      },
      query: {
  page,
  limit: pagination.limit,
  search: search.value,
  dateFrom: dateFrom.value,
  dateTo: dateTo.value
}
    })

   logs.value = (res.data || [])
  .filter(log => log.user_id === userId)
  .map(log => ({
    id: log.id,
    event: log.action,
    userId: log.user_id,
    name: log.user?.email || 'Guest',
    date: log.created_at,
    ip: log.ip_address,
    mac: '-',
    session: log.action
  }))

    //user.value = res.user || {}

   pagination.page = res.meta?.current_page || page
   pagination.totalPages = res.meta?.total_pages || 1
   pagination.total = res.meta?.total_items || logs.value.length


  } finally {
    isLoading.value = false
  }
}


//โหลดข้อมูล User รายคน
async function fetchUser() {
  try {
    const token =
      useCookie('token').value ||
      localStorage.getItem('token')

    const res = await $fetch(`/users/admin/${userId}`, {
    baseURL: config.public.apiBase,
    headers: {
        Authorization: `Bearer ${token}`
    }
    })

    user.value = res.data

  } catch (e) {
    console.error('fetch user error', e)
  }
}

//กำหนดสี role
function roleBadge(role) {
  if (role === 'ADMIN') return 'bg-purple-100 text-purple-700'
  if (role === 'DRIVER') return 'bg-blue-100 text-blue-700'
  return 'bg-gray-100 text-gray-700'
}

function changePage(p) {
  fetchLogs(p)
}

onMounted(() => {
  fetchLogs(1)
  fetchUser()
})


//อันนี้เพิ่ม
function getStatusClass(session) {
  if (!session) return 'bg-gray-100 text-gray-600'

  if (session.toLowerCase().includes('login'))
    return 'bg-green-100 text-green-700'

  if (session.toLowerCase().includes('logout'))
    return 'bg-red-100 text-red-700'

  return 'bg-gray-100 text-gray-600'
}

//Export CSV
function exportLogs() {

  const rows = logs.value.map(l => ({
    Event: l.event,
    UserId: l.userId,
    Name: l.name,
    Date: formatDate(l.date),
    IP: l.ip,
    Session: l.session
  }))

  const csv =
    Object.keys(rows[0]).join(',') + '\n' +
    rows.map(r => Object.values(r).join(',')).join('\n')

  const blob = new Blob([csv], { type: 'text/csv' })

  const url = window.URL.createObjectURL(blob)

  const a = document.createElement('a')
  a.href = url
  a.download = `user-${userId}-logs.csv`
  a.click()

  window.URL.revokeObjectURL(url)
}
</script>
