<template>
  <div class="flex justify-center min-h-screen py-8 bg-gray-50">
    <div
      class="flex w-full max-w-6xl mx-4 overflow-hidden bg-white border border-gray-300 rounded-lg shadow-lg"
    >
      <ProfileSidebar />

      <main class="flex-1 p-8 min-h-screen">
        <div class="mb-6 text-center">
          <img
            :src="profileImage"
            class="object-cover w-24 h-24 mx-auto mb-3 rounded-full bg-gray-200"
          />
          <p class="text-gray-700 font-medium">
            {{ user?.username }}
          </p>
        </div>

        <h1 class="mb-6 text-xl font-bold text-center">
          การลบบัญชีผู้ใช้
        </h1>

        <div class="p-4 mb-6 text-sm text-red-600 rounded-md">
          <p class="mb-2 font-semibold">หากคุณลบบัญชี:</p>
          <ul class="space-y-1 list-disc pl-5">
            <li>ข้อมูลส่วนตัวทั้งหมดจะถูกลบ</li>
            <li>ไม่สามารถกู้คืนบัญชีได้</li>
            <li>ระบบจะเก็บ Log ตามกฎหมาย (อย่างน้อย 90 วัน)</li>
          </ul>
        </div>

        <label class="flex items-center gap-2 mb-6">
          <input type="checkbox" v-model="accepted" />
          <span>รับทราบข้อตกลง</span>
        </label>

        <div class="mb-8">
          <label class="block mb-2 text-sm font-medium">
            เพื่อยืนยันการลบบัญชี กรุณาพิมพ์คำว่า
            <span class="font-bold">"ยืนยัน"</span>
          </label>
          <input
            v-model="confirmText"
            type="text"
            class="w-full px-4 py-3 border border-gray-300 rounded-md
                   focus:outline-none focus:ring-2 focus:ring-red-500"
            placeholder="พิมพ์คำว่า ยืนยัน"
          />
        </div>

        <div class="flex justify-end">
          <button
            :disabled="!canDelete || isLoading"
            @click="handleDeleteAccount"
            class="px-6 py-3 font-medium text-white rounded-md
                   bg-blue-600 hover:bg-blue-700
                   disabled:bg-gray-300 disabled:cursor-not-allowed"
          >
            ยืนยันการลบข้อมูล
          </button>
        </div>
      </main>
    </div>
  </div>

  <ConfirmModal
  :show="showSuccessPopup"
  title="ลบบัญชีสำเร็จ"
  message="บัญชีของคุณถูกลบเรียบร้อยแล้ว"
  confirm-text="ตกลง"
  cancel-text=" "
  @confirm="handleAfterDelete"
  />
</template>
<script setup>
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import ProfileSidebar from '~/components/ProfileSidebar.vue'
import ConfirmModal from '~/components/ConfirmModal.vue'
import { useAuth } from '~/composables/useAuth'

definePageMeta({
  middleware: 'auth'
})

const router = useRouter()
const { user, logout } = useAuth()

const accepted = ref(false)
const confirmText = ref('')
const isLoading = ref(false)
const showSuccessPopup = ref(false)

const profileImage = computed(() => {
  return (
    user?.value?.profilePicture ||
    `https://ui-avatars.com/api/?name=${user?.value?.username || 'U'}`
  )
})

const canDelete = computed(() => {
  return accepted.value && confirmText.value === 'ยืนยัน'
})

async function handleDeleteAccount() {
  if (!canDelete.value) return
  isLoading.value = true

  try {
    showSuccessPopup.value = true
  } finally {
    isLoading.value = false
  }
}

async function handleAfterDelete() {
  showSuccessPopup.value = false
  await logout()
  router.replace('/')
}
</script>
<style scoped>
:deep(.btn-primary) {
  background-color: #2563eb; 
  color: white;
}
:deep(.btn-secondary) {
  display: none;
}
:deep(.modal-content),
:deep(.modal-card) {
  background-color: #ffffff; 
  border-radius: 12px;
}
:deep(.modal-content > div:last-child) {
  background-color: #ffffff;
}
:deep(.modal-icon) {
  width: 64px;
  height: 64px;
  margin: 0 auto 12px;

  display: flex;
  align-items: center;
  justify-content: center;

  background-color: #e0f2fe; 
  border-radius: 9999px;
}
:deep(.modal-icon svg),
:deep(.modal-icon .icon),
:deep(.modal-icon svg path) {
  width: 32px;
  height: 32px;
  color: #38bdf8;   
  fill: #38bdf8;
}
</style>