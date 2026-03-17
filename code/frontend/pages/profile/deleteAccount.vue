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
            <div class="mb-6 p-4 bg-red-50 border border-red-200 rounded-lg">
              <div class="flex items-center gap-2 mb-2">
                <svg class="w-4 h-4 text-red-600 flex-shrink-0" fill="currentColor" viewBox="0 0 20 20">
                  <path fill-rule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clip-rule="evenodd"/>
                </svg>
                <p class="text-sm font-semibold text-red-700">หากลบบัญชี:</p>
              </div>
              <ul class="space-y-1 text-sm text-red-600 pl-6">
                <li class="flex items-start gap-1.5"><span class="mt-1.5 w-1 h-1 rounded-full bg-red-400 flex-shrink-0"></span>ข้อมูลส่วนตัวทั้งหมดจะถูกลบ</li>
                <li class="flex items-start gap-1.5"><span class="mt-1.5 w-1 h-1 rounded-full bg-red-400 flex-shrink-0"></span>ไม่สามารถกู้คืนบัญชีได้</li>
                <li class="flex items-start gap-1.5"><span class="mt-1.5 w-1 h-1 rounded-full bg-red-400 flex-shrink-0"></span>ระบบจะเก็บ Log ตามที่กฎหมายกำหนด (อย่างน้อย 90 วัน)</li>
                <li class="flex items-start gap-1.5"><span class="mt-1.5 w-1 h-1 rounded-full bg-red-400 flex-shrink-0"></span>จะมีการแจ้งเตือนการลบข้อมูลอีกครั้ง</li>
                <li class="flex items-start gap-1.5"><span class="mt-1.5 w-1 h-1 rounded-full bg-red-400 flex-shrink-0"></span>ข้อมูลส่วนบุคคลของคุณจะถูกลบเมื่อการลบบัญชีเสร็จสิ้น</li>
              </ul>
            </div>

        <!-- แก้ไขและเพิ่มเติมโค้ดตรงนี้ -->
        <div class="p-4 mb-6 border rounded-md bg-gray-50">
            <p class="mb-3 font-medium">ข้อมูลส่วนบุคคลที่ต้องการจะรับ (ระบบจะส่งข้อมูลไปที่อีเมลของคุณ)</p>

            <div class="space-y-2">
              
              <!-- ประวัติส่วนตัว -->
              <label class="flex items-center gap-3 p-3 rounded-lg border cursor-pointer transition-all"
                :class="selectProfileData ? 'bg-blue-50 border-blue-400' : 'bg-white border-gray-200 hover:border-gray-300'">
                <div class="flex-shrink-0 w-5 h-5 rounded border-2 flex items-center justify-center transition-all"
                  :class="selectProfileData ? 'bg-blue-500 border-blue-500' : 'border-gray-300'">
                  <svg v-if="selectProfileData" class="w-3 h-3 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M5 13l4 4L19 7"/>
                  </svg>
                </div>
                <input type="checkbox" v-model="selectProfileData" class="hidden" />
                <div>
                  <p class="text-sm font-medium text-gray-800">ประวัติส่วนตัว</p>
                  <p class="text-xs text-gray-500">ข้อมูลโปรไฟล์ ชื่อ อีเมล และรูปภาพ</p>
                </div>
              </label>

              <!-- ประวัติการเดินทาง -->
              <label class="flex items-center gap-3 p-3 rounded-lg border cursor-pointer transition-all"
                :class="selectTripHistoryData ? 'bg-blue-50 border-blue-400' : 'bg-white border-gray-200 hover:border-gray-300'">
                <div class="flex-shrink-0 w-5 h-5 rounded border-2 flex items-center justify-center transition-all"
                  :class="selectTripHistoryData ? 'bg-blue-500 border-blue-500' : 'border-gray-300'">
                  <svg v-if="selectTripHistoryData" class="w-3 h-3 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M5 13l4 4L19 7"/>
                  </svg>
                </div>
                <input type="checkbox" v-model="selectTripHistoryData" class="hidden" />
                <div>
                  <p class="text-sm font-medium text-gray-800">ประวัติการเดินทาง</p>
                  <p class="text-xs text-gray-500">บันทึกการจองและการเดินทางทั้งหมด</p>
                </div>
              </label>

              <!-- ประวัติเส้นทาง (เฉพาะ Driver) -->
              <label v-if="isDriver" class="flex items-center gap-3 p-3 rounded-lg border cursor-pointer transition-all"
                :class="selectRouteAndVehicleData ? 'bg-blue-50 border-blue-400' : 'bg-white border-gray-200 hover:border-gray-300'">
                <div class="flex-shrink-0 w-5 h-5 rounded border-2 flex items-center justify-center transition-all"
                  :class="selectRouteAndVehicleData ? 'bg-blue-500 border-blue-500' : 'border-gray-300'">
                  <svg v-if="selectRouteAndVehicleData" class="w-3 h-3 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M5 13l4 4L19 7"/>
                  </svg>
                </div>
                <input type="checkbox" v-model="selectRouteAndVehicleData" class="hidden" />
                <div>
                  <p class="text-sm font-medium text-gray-800">ประวัติการสร้างเส้นทางและข้อมูลรถยนต์</p>
                  <p class="text-xs text-gray-500">เส้นทางที่สร้าง รายละเอียดรถ และประวัติการขับ</p>
                </div>
              </label>

            </div>

            <p v-if="!hasSelectedData" class="mt-3 text-xs text-red-500 flex items-center gap-1">
              <svg class="w-3 h-3" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clip-rule="evenodd"/>
              </svg>
              กรุณาเลือกข้อมูลอย่างน้อย 1 รายการ
            </p>
       </div>

        
        <label class="flex items-start gap-3 mb-6 cursor-pointer group">
          <div class="flex-shrink-0 w-5 h-5 mt-0.5 rounded border-2 flex items-center justify-center transition-all"
            :class="accepted ? 'bg-blue-500 border-blue-500' : 'border-gray-300 group-hover:border-blue-400'">
            <svg v-if="accepted" class="w-3 h-3 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M5 13l4 4L19 7"/>
            </svg>
          </div>
          <input type="checkbox" v-model="accepted" class="hidden" />
          <div>
            <p class="text-sm font-medium text-gray-800">รับทราบข้อตกลง</p>
            <p class="text-xs text-gray-400 mt-0.5">ฉันเข้าใจและยอมรับว่าการลบบัญชีนี้ไม่สามารถย้อนกลับได้</p>
          </div>
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

  <!-- แก้ไขและเพิ่มเติมโค้ดตรงนี้ กรณีลบสำเร็จ-->
  <ConfirmModal
    :show="showSuccessPopup"
    title="ลบบัญชีสำเร็จ"
    message="เราได้ทำการลบข้อมูลของบัญชีเรียบร้อยแล้ว"
    confirm-text="ตกลง"
    :cancel-text="null"
    :closable="false"
    variant="danger"
    @confirm="handleAfterDelete"
  />

 <!--เพิ่มตรงนี้ กรณีมีการเดินทางค้างอยู่ -->
<ConfirmModal
  :show="showPendingTripModal"
  title="ไม่สามารถลบบัญชีได้"
  message="คุณยังมีการเดินทางที่กำลังดำเนินการอยู่ กรุณาสิ้นสุดหรือยกเลิกการเดินทางก่อน จึงจะสามารถลบบัญชีได้"
  confirm-text="ตกลง"
  :cancel-text="null"
  variant="danger"
  @confirm="handleAfterCanNotDelete"
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
import { errorMessages } from 'vue/compiler-sfc'

definePageMeta({ middleware: 'auth' })

const router = useRouter()
const { user, logout, deleteAccount } = useAuth()
const { sendUserDataToEmail } = useUser()

/* <!-- แก้ไขและเพิ่มเติมโค้ดตรงนี้ --> */
const selectProfileData = ref(false)
const selectTripHistoryData = ref(false)
const selectRouteAndVehicleData = ref(false)
const showPendingTripModal = ref(false) //แก้ตรงนี้

const accepted = ref(false)
const confirmText = ref('')
const isLoading = ref(false)
const showSuccessPopup = ref(false)
const confirmClose = ref(false) 
const errorMessage = ref('')

const toast = ref({ show: false, title: '', message: '', type: 'info' })

const profileImage = computed(() =>
  user?.value?.profilePicture ||
  `https://ui-avatars.com/api/?name=${user?.value?.username || 'U'}`
)

const isDriver = computed(() =>
  user?.value?.role === 'DRIVER' || 
  user?.value?.roles?.includes('DRIVER') ||
  user?.value?.isDriver === true
)

const hasSelectedData = computed(() => {
  if (isDriver.value) {
    return selectProfileData.value || selectTripHistoryData.value || selectRouteAndVehicleData.value
  }
  return selectProfileData.value || selectTripHistoryData.value
})

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
    await deleteAccount()
    confirmClose.value = false
    showSuccessPopup.value = true
    await sendToUserEmail()
  } catch (error) {
      console.log("FULL ERROR:", error)

      if (error.statusCode === 400) {
        showPendingTripModal.value = true
      } else {
        showToast('ล้มเหลว', error.statusMessage || 'ไม่สามารถลบบัญชีได้', 'error')
      }
  } finally {
    isLoading.value = false
  }
}

async function handleAfterDelete() {
  showSuccessPopup.value = false
  await logout()
  router.replace('/')
}

async function handleAfterCanNotDelete() {
  showPendingTripModal.value = false
  // await logout()
  // router.replace('/')
}

async function sendToUserEmail() {
  try {
    await sendUserDataToEmail({
      selectProfileData: selectProfileData.value,
      selectTripHistoryData: selectTripHistoryData.value,
      selectRouteAndVehicleData: selectRouteAndVehicleData.value
    })
    showToast("สำเร็จ", "ระบบกำลังส่งข้อมูลไปยังอีเมลของคุณ", "success")
  } catch (e) {
    console.error('Send email error:', e)
    showToast("ผิดพลาด", "ไม่สามารถส่งข้อมูลไปยังอีเมลได้", "error")
    throw e  
  }
}

</script>

<style scoped>
.fixed.top-5.right-5 {
  z-index: 9999 !important;
}
</style>