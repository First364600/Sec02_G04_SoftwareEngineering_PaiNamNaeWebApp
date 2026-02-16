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
          <p class="mb-2 font-semibold">คำเตือนสำคัญก่อนลบบัญชี:</p>
          <ul class="space-y-1 list-disc pl-5">
            <li>ข้อมูลโปรไฟล์และประวัติการเดินทางทั้งหมดจะถูกลบถาวร</li>
            <li>คุณจะไม่สามารถกู้คืนบัญชีนี้ได้อีกหลังจากยืนยันการลบ</li>
            <li>ข้อมูลการทำธุรกรรมจะถูกเก็บไว้ตามระยะเวลาที่กฎหมายกำหนดเพื่อความปลอดภัย (อย่างน้อย 90 วัน)</li>
          </ul>
        </div>
           <div class="p-6 mb-8 border border-blue-200 rounded-lg bg-blue-50">
              <div class="flex items-start gap-3 mb-4">
                <svg class="w-6 h-6 text-blue-600 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                </svg>
                <div>
                  <h3 class="text-lg font-bold text-blue-800 leading-6">สำรองข้อมูลส่วนบุคคลของคุณ</h3>
                  <p class="mt-2 text-sm text-blue-700 leading-relaxed">
                    ตามสิทธิ์ภายใต้กฎหมายคุ้มครองข้อมูลส่วนบุคคล (PDPA) คุณสามารถขอรับสำเนาข้อมูลของคุณในรูปแบบไฟล์ (CSV) เพื่อนำไปใช้งานต่อในแพลตฟอร์มอื่นได้ก่อนทำการลบบัญชี
                  </p>
                </div>
              </div>

              <p class="mb-4 text-sm text-gray-700 font-medium">
                คุณต้องการรับสำเนาข้อมูลส่วนบุคคลของคุณในรูปแบบไฟล์ CSV หรือไม่?
              </p>
              
              <div class="space-y-3">
                <label class="flex items-center gap-3 p-3 transition-all bg-white border rounded-md cursor-pointer hover:border-blue-400">
                  <input 
                    type="radio" 
                    name="pdpa_request" 
                    v-model="requestData" 
                    :value="true" 
                    class="w-4 h-4 text-blue-600 border-gray-300 focus:ring-blue-500"
                  >
                  <span class="text-sm text-gray-700">ใช่, ฉันต้องการรับสำเนาข้อมูล</span>
                </label>
                
                <label class="flex items-center gap-3 p-3 transition-all bg-white border rounded-md cursor-pointer hover:border-gray-400">
                  <input 
                    type="radio" 
                    name="pdpa_request" 
                    v-model="requestData" 
                    :value="false" 
                    class="w-4 h-4 text-gray-600 border-gray-300 focus:ring-gray-500"
                  >
                  <span class="text-sm text-gray-700">ไม่, ฉันไม่ต้องการรับข้อมูล</span>
                </label>
              </div>
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
          :confirm-text="requestData ? 'เสร็จสิ้น' : 'ตกลง'"
          cancel-text=" "
          :disabled-confirm="requestData && !confirmClose"
          @confirm="handleAfterDelete"
        >
            <div class="text-center">
              <p class="mb-4 text-gray-600">บัญชีของคุณถูกลบเรียบร้อยแล้ว</p>
              
              <div v-if="requestData" class="p-4 mt-4 text-left border-l-4 border-blue-500 rounded-r-md bg-blue-50">
                <p class="mb-2 text-sm font-bold text-blue-800"> ดาวน์โหลดสำเนาข้อมูลของคุณ</p>
                <p class="mb-3 text-xs text-blue-600">
                  คุณสามารถดาวน์โหลดข้อมูลส่วนบุคคลเป็นไฟล์ CSV ได้ที่นี่ก่อนปิดหน้าต่าง
                </p>
                
                <button 
                  @click="handleDownloadCSV" 
                  type="button"
                  class="w-full py-2 mb-4 text-sm font-bold text-white transition-colors bg-blue-600 rounded-md hover:bg-blue-700"
                >
                  คลิกเพื่อดาวน์โหลด (CSV)
                </button>
                
                <label class="flex items-start gap-2 cursor-pointer group">
                  <input 
                    type="checkbox" 
                    v-model="confirmClose" 
                    class="mt-1 w-4 h-4 text-blue-600 border-gray-300 rounded focus:ring-blue-500" 
                  />
                  <span class="text-xs text-gray-500 group-hover:text-gray-700">
                    ฉันดาวน์โหลดข้อมูลเรียบร้อยแล้ว และรับทราบว่าข้อมูลจะถูกลบถาวรหลังจากปิดหน้านี้
                  </span>
                </label>
              </div>
            </div>
        </ConfirmModal> />

        <div class="fixed top-5 right-5 z-[1001] pointer-events-none flex flex-col items-end space-y-4">
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

definePageMeta({
  middleware: 'auth'
})

const router = useRouter()
const { user, logout, deleteAccount } = useAuth()

const accepted = ref(false)
const confirmText = ref('')
const isLoading = ref(false)
const showSuccessPopup = ref(false)

const requestData = ref(false)  
const confirmClose = ref(false)
const toast = ref({ show: false, title: '', message: '', type: 'info' })

const profileImage = computed(() => {
  return (
    user?.value?.profilePicture ||
    `https://ui-avatars.com/api/?name=${user?.value?.username || 'U'}`
  )
})

const canDelete = computed(() => {
  return accepted.value && confirmText.value === 'ยืนยัน'
})

function handleDownloadCSV() {
  // สร้างข้อมูลจำลองจาก User Profile รอดึงbackend จริง
  const data = [
    ["ID", "Username", "Email"],
    [user.value?.id || 'N/A', user.value?.username || 'N/A', user.value?.email || 'N/A']
  ];
  
  const csvContent = "data:text/csv;charset=utf-8," + data.map(e => e.join(",")).join("\n");
  const encodedUri = encodeURI(csvContent);
  const link = document.createElement("a");
  link.setAttribute("href", encodedUri);
  link.setAttribute("download", `my_data_${user.value?.username || 'user'}.csv`);
  document.body.appendChild(link);
  
  link.click();
  document.body.removeChild(link);
}

function showToast(title, message, type = 'warning') {
  toast.value.show = false 
  
  setTimeout(() => {
    toast.value = { 
      show: true, 
      title: title, 
      message: message, 
      type: type, 
      id: Date.now() 
    }
  }, 10)
}

async function handleDeleteAccount() {
  if (!canDelete.value) return
  isLoading.value = true

  try {
    const res = await deleteAccount()
    requestData.value = res
    confirmClose.value = false
    showSuccessPopup.value = true
  } catch (error) {
    console.error('Failed to delete account:', error)
    showToast(
      'ล้มเหลว',
      error?.data?.message || 'ไม่สามารถส่งคำขอลบบัญชีได้',
      'error'
    )
  } finally {
    isLoading.value = false
  }
}

async function handleAfterDelete() {
  if (requestData.value && !confirmClose.value) {
    showToast(
      'ดำเนินการไม่สำเร็จ', 
      'กรุณาติ๊กถูกยืนยันก่อนปิดหน้าต่างนี้ค่ะ', 
      'warning'
    )
    return
  }
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

:deep(.toast-container) {
  min-width: 320px !important; 
  max-width: 400px !important; 
  width: auto !important;
  display: block !important;
}

.fixed.top-5.right-5 {
  z-index: 9999 !important;
}
</style>