<template>
  <div class="flex justify-center min-h-screen py-8 bg-gray-50">
    <div
      class="flex w-full max-w-6xl mx-4 overflow-hidden bg-white border border-gray-300 rounded-lg shadow-lg"
    >
      <ProfileSidebar />

      <main class="flex-1 p-8 min-h-screen">
        <!-- Profile -->
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

        <!-- Warning -->
        <div class="mb-6 text-sm text-red-600">
          <p class="mb-2 font-semibold">หากลบบัญชี:</p>
          <ul class="space-y-1 list-disc pl-5">
            <li>ข้อมูลส่วนตัวทั้งหมดจะถูกลบ</li>
            <li>ไม่สามารถกู้คืนบัญชีได้</li>
            <li>ระบบจะเก็บ Log ตามที่กฎหมายกำหนด (อย่างน้อย 90 วัน)</li>
            <li>จะมีการแจ้งเตือนการลบข้อมูลอีกครั้ง</li>
            <li>ข้อมูลส่วนบุคคลของคุณจะถูกลบเมื่อการลบบัญชีเสร็จสิ้น</li>
          </ul>
        </div>

        <!-- แก้ไขและเพิ่มเติมโค้ดตรงนี้ -->
        <div class="p-4 mb-6 border rounded-md bg-gray-50">
          <p class="mb-3 font-medium">ข้อมูลส่วนบุคคลที่จะถูกลบ</p>

          <label class="flex items-center gap-2 mb-2">
            <input type="checkbox" v-model="deleteProfile" />
            <span>ประวัติส่วนตัว</span>
          </label>

          <label class="flex items-center gap-2 mb-2">
            <input type="checkbox" v-model="deleteTripHistory" />
            <span>ประวัติการเดินทาง</span>
          </label>

          <label class="flex items-center gap-2">
            <input type="checkbox" v-model="deleteVehicleData" />
            <span>ประวัติการสร้างเส้นทางและข้อมูลรถยนต์ (กรณีเป็นผู้ขับขี่)</span>
          </label>

          <p
            v-if="!hasSelectedData"
            class="mt-2 text-xs text-red-500"
          >
            กรุณาเลือกข้อมูลอย่างน้อย 1 รายการ
          </p>
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

  <!-- แก้ไขและเพิ่มเติมโค้ดตรงนี้ -->
  <ConfirmModal
  :show="showSuccessPopup"
  title="ลบบัญชีสำเร็จ"
  message="เราได้ทำการลบข้อมูลของบัญชีเรียบร้อยแล้ว คุณต้องการดำเนินการต่อหรือไม่?"
  confirm-text="ตกลง"
  :cancel-text="null"
  variant="danger"
  @confirm="handleAfterDelete"
/>

  
  <div class="fixed top-5 right-5 z-[1001] pointer-events-none">
    <Notification
      v-if="toast.show"
      :id="toast.id"
      :type="toast.type"
      :title="toast.title"
      :message="toast.message"
      @close="toast.show = false"
    />
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import ProfileSidebar from '~/components/ProfileSidebar.vue'
import ConfirmModal from '~/components/ConfirmModal.vue'
import { useAuth } from '~/composables/useAuth'
import Notification from '~/components/ToastNotification.vue'

definePageMeta({ middleware: 'auth' })

const router = useRouter()
const { user, logout, deleteAccount } = useAuth()

/* <!-- แก้ไขและเพิ่มเติมโค้ดตรงนี้ --> */
const deleteProfile = ref(false)
const deleteTripHistory = ref(false)
const deleteVehicleData = ref(false)


const accepted = ref(false)
const confirmText = ref('')
const isLoading = ref(false)
const showSuccessPopup = ref(false)

const toast = ref({ show: false, title: '', message: '', type: 'info' })

const profileImage = computed(() =>
  user?.value?.profilePicture ||
  `https://ui-avatars.com/api/?name=${user?.value?.username || 'U'}`
)


const hasSelectedData = computed(() =>
  deleteProfile.value ||
  deleteTripHistory.value ||
  deleteVehicleData.value
)

const canDelete = computed(() =>
  accepted.value &&
  confirmText.value === 'ยืนยัน' &&
  hasSelectedData.value
)

function showToast(title, message, type = 'warning') {
  toast.value = { show: true, title, message, type, id: Date.now() }
}

async function handleDeleteAccount() {
  if (!canDelete.value) return

  isLoading.value = true
  try {
    await deleteAccount({
      deleteProfile: deleteProfile.value,
      deleteTripHistory: deleteTripHistory.value,
      deleteVehicleData: deleteVehicleData.value
    })
    showSuccessPopup.value = true
  } catch (e) {
    showToast('ล้มเหลว', 'ไม่สามารถลบบัญชีได้', 'error')
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
.fixed.top-5.right-5 {
  z-index: 9999 !important;
}
</style>