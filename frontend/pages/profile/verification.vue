<template>
    <div class="bg-gray-50">
        <div class="min-h-screen flex items-center justify-center py-8">
            <div
                class="flex bg-white rounded-lg shadow-lg overflow-hidden max-w-6xl w-full mx-4 border border-gray-300">

                <ProfileSidebar />

                <main class="flex-1 p-8 ">
                    <div class="text-center mb-8">
                        <div class="inline-flex items-center justify-center w-16 h-16 bg-blue-600 rounded-full mb-4">
                            <svg class="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                    d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z">
                                </path>
                            </svg>
                        </div>
                        <h1 class="text-3xl font-bold text-gray-800 mb-2">การยืนยันตัวตนขั้นพื้นฐาน</h1>
                        <p class="text-gray-600 max-w-md mx-auto">
                            อัปโหลดภาพบัตรประชาชนและรูปถ่าย เพื่อยืนยันตัวตนของคุณ
                        </p>
                    </div>

                    <div class="bg-white rounded-xl p-8 ">
                        <form @submit.prevent="handleSubmit" novalidate class="space-y-8">

                            <div class="relative">
                                <div class="flex items-center mb-6">
                                    <div class="step-indicator mr-4">1</div>
                                    <label class="text-xl font-semibold text-gray-800">
                                        รูปบัตรประชาชน (ด้านหน้า) <span class="text-red-500">*</span>
                                    </label>
                                </div>
                                <h4 class="text-sm font-medium text-gray-700 mb-2">ตัวอย่างที่ถูกต้อง:</h4>
                                <div class="grid md:grid-cols-2 gap-6 mb-6">
                                    <div class="space-y-4">
                                        <div class="license-card p-6 h-40 relative">
                                            <div class="relative z-10 h-full flex flex-col justify-between">
                                                <div class="flex justify-between items-start">
                                                    <div>
                                                        <div class="thai-text">ใบบัตรประชาชน</div>
                                                        <div class="text-xs text-blue-800 font-bold">ID CARD</div>
                                                    </div>
                                                </div>
                                                <div class="flex items-center space-x-3">
                                                    <div
                                                        class="w-12 h-12 bg-blue-300 rounded-md flex items-center justify-center">
                                                        <svg class="w-6 h-6 text-blue-700" fill="currentColor"
                                                            viewBox="0 0 20 20">
                                                            <path fill-rule="evenodd"
                                                                d="M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z"
                                                                clip-rule="evenodd"></path>
                                                        </svg>
                                                    </div>
                                                    <div>
                                                        <div class="text-xs text-blue-800 font-semibold">นาย สมชาย ใจดี
                                                        </div>
                                                        <div class="text-xs text-blue-700">เลขที่ 12345678</div>
                                                        <div class="text-xs text-blue-600">หมดอายุ 01/01/2027</div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <p class="text-xs text-gray-600 text-center">วางบัตรบนพื้นผิวเรียบ ถ่ายให้ชัดเจน
                                        </p>
                                    </div>
                                    <div @click="triggerFileInput('nationalIdPhoto')"
                                        class="upload-zone h-40 border-2 border-dashed border-gray-300 rounded-lg p-8 bg-gray-50 hover:bg-gray-100 hover:border-blue-400 relative flex items-center justify-center">
                                        <div v-if="!previews.nationalIdPhoto" class="text-center">
                                            <svg class="w-12 h-12 text-gray-400 mx-auto mb-4" fill="none"
                                                stroke="currentColor" viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                                    d="M3 9a2 2 0 012-2h.93a2 2 0 001.664-.89l.812-1.22A2 2 0 0110.07 4h3.86a2 2 0 011.664.89l.812 1.22A2 2 0 0018.07 7H19a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V9z">
                                                </path>
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                                    d="M15 13a3 3 0 11-6 0 3 3 0 016 0z"></path>
                                            </svg>
                                            <p class="text-lg text-gray-600 mb-2">คลิกเพื่ออัปโหลด</p>
                                            <p class="text-sm text-gray-500">JPG, PNG (ไม่เกิน 10MB)</p>
                                        </div>
                                        <img v-else :src="previews.nationalIdPhoto"
                                            class="w-full h-full object-cover rounded-md" />
                                        <input type="file" ref="nationalIdInput"
                                            @change="handleFileChange($event, 'nationalIdPhoto')" class="hidden"
                                            accept="image/png, image/jpeg" />
                                    </div>
                                </div>
                            </div>

                            <div class="relative">
                                <div class="flex items-center mb-6">
                                    <div class="step-indicator mr-4">2</div>
                                    <label class="text-xl font-semibold text-gray-800">
                                        รูปถ่าย (Selfie) <span class="text-red-500">*</span>
                                    </label>
                                </div>
                                <h4 class="text-sm font-medium text-gray-700 mb-2">ตัวอย่างที่ถูกต้อง:</h4>
                                <div class="grid md:grid-cols-2 gap-6 mb-6">
                                    <div class="space-y-4">
                                        <div class="selfie-frame p-6 h-40 relative">
                                            <div class="relative z-10 h-full flex items-center justify-center">
                                                <div class="flex items-center space-x-4">
                                                    <div
                                                        class="person-silhouette w-20 h-20 flex items-center justify-center">
                                                        <svg class="w-12 h-12 text-gray-200" fill="currentColor"
                                                            viewBox="0 0 20 20">
                                                            <path fill-rule="evenodd"
                                                                d="M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z"
                                                                clip-rule="evenodd"></path>
                                                        </svg>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <p class="text-xs text-gray-600 text-center">ถือบัตรชิดข้างใบหน้า
                                            ให้เห็นทั้งสองอย่างชัดเจน</p>
                                    </div>
                                    <div @click="triggerFileInput('selfiePhoto')"
                                        class="upload-zone h-40 border-2 border-dashed border-gray-300 rounded-lg p-8 bg-gray-50 hover:bg-gray-100 hover:border-blue-400 relative flex items-center justify-center">
                                        <div v-if="!previews.selfiePhoto" class="text-center">
                                            <svg class="w-12 h-12 text-gray-400 mx-auto mb-4" fill="none"
                                                stroke="currentColor" viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                                    d="M3 9a2 2 0 012-2h.93a2 2 0 001.664-.89l.812-1.22A2 2 0 0110.07 4h3.86a2 2 0 011.664.89l.812 1.22A2 2 0 0018.07 7H19a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V9z" />
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                                    d="M15 13a3 3 0 11-6 0 3 3 0 016 0z" />
                                            </svg>
                                            <p class="text-lg text-gray-600 mb-2">คลิกเพื่ออัปโหลด</p>
                                            <p class="text-sm text-gray-500">JPG, PNG (ไม่เกิน 10MB)</p>
                                        </div>
                                        <img v-else :src="previews.selfiePhoto"
                                            class="w-full h-full object-cover rounded-md" />
                                        <input type="file" ref="selfieInput"
                                            @change="handleFileChange($event, 'selfiePhoto')" class="hidden"
                                            accept="image/png, image/jpeg" />
                                    </div>
                                </div>
                            </div>

                            <div class="relative">
                                <div class="flex items-center mb-4">
                                    <div class="step-indicator mr-4">3</div>
                                    <h2 class="text-xl font-semibold text-gray-800">ข้อมูลในบัตรประจำตัวประชาชน</h2>
                                </div>
                                <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6">
                                    <div>
                                        <label for="nationalIdNumber"
                                            class="block text-sm font-medium text-gray-700 mb-2">เลขบัตรประชาชน <span
                                                class="text-red-500">*</span></label>
                                        <input v-model="formattedNationalId" id="nationalIdNumber" type="text"
                                            maxlength="17" placeholder="x-xxxx-xxxxx-xx-x"
                                            class="w-full border border-gray-300 rounded-lg focus:outline-none px-3 py-2 focus:ring-2 focus:ring-blue-500"
                                            required />
                                    </div>
                                    <div>
                                        <label for="nationalIdExpiryDate"
                                            class="block text-sm font-medium text-gray-700 mb-2">วันหมดอายุในบัตร <span
                                                class="text-red-500">*</span></label>
                                        <input v-model="form.nationalIdExpiryDate" id="nationalIdExpiryDate" type="date"
                                            class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
                                            required />
                                    </div>
                                </div>
                            </div>

                            <p class="text-sm text-gray-500 text-center mt-4">
                                ข้อมูลของคุณจะได้รับการตรวจสอบโดยเจ้าหน้าที่ระบบโดยเร็วที่สุด
                            </p>
                            <div class="pt-6 flex justify-end gap-4">
                                <button type="button" @click="resetForm" :disabled="isLoading"
                                    class="px-6 py-3 border border-gray-300 text-gray-700 rounded-md hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-gray-400 disabled:opacity-50">
                                    ยกเลิก
                                </button>
                                <button type="submit" :disabled="!isFormValid || isLoading"
                                    class="px-6 py-3 bg-blue-600 text-white rounded-md font-medium hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 disabled:bg-blue-400 disabled:cursor-not-allowed flex items-center">
                                    <svg v-if="isLoading" class="animate-spin -ml-1 mr-3 h-5 w-5 text-white"
                                        xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                                        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor"
                                            stroke-width="4"></circle>
                                        <path class="opacity-75" fill="currentColor"
                                            d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z">
                                        </path>
                                    </svg>
                                    {{ isLoading ? 'กำลังส่งข้อมูล...' : 'ส่งคำขอยืนยันตัวตน' }}
                                </button>
                            </div>

                        </form>
                    </div>
                </main>
            </div>
        </div>
    </div>
</template>

<script setup>
import { ref, reactive, computed, watch } from 'vue'
import ProfileSidebar from '~/components/ProfileSidebar.vue';
import { useToast } from '~/composables/useToast';
import { useAuth } from '~/composables/useAuth';

definePageMeta({
    middleware: 'auth'
});

const { $api } = useNuxtApp();
const { user: userCookie } = useAuth();
const { toast } = useToast();

const isLoading = ref(false);
const nationalIdInput = ref(null);
const selfieInput = ref(null);

let originalData = null;

const form = reactive({
    nationalIdNumber: '',
    nationalIdExpiryDate: '',
    nationalIdPhoto: null,
    selfiePhoto: null,
});

const formattedNationalId = ref('');

watch(formattedNationalId, (newValue) => {
    const digitsOnly = newValue.replace(/\D/g, '');
    const truncatedDigits = digitsOnly.slice(0, 13);

    form.nationalIdNumber = truncatedDigits;

    let formatted = '';
    if (truncatedDigits.length > 0) {
        formatted += truncatedDigits.substring(0, 1);
    }
    if (truncatedDigits.length > 1) {
        formatted += '-' + truncatedDigits.substring(1, 5);
    }
    if (truncatedDigits.length > 5) {
        formatted += '-' + truncatedDigits.substring(5, 10);
    }
    if (truncatedDigits.length > 10) {
        formatted += '-' + truncatedDigits.substring(10, 12);
    }
    if (truncatedDigits.length > 12) {
        formatted += '-' + truncatedDigits.substring(12, 13);
    }

    // This check is crucial to prevent the watcher from re-triggering itself
    if (formatted !== newValue) {
        formattedNationalId.value = formatted;
    }
});

const previews = reactive({
    nationalIdPhoto: '',
    selfiePhoto: ''
});

const isFormValid = computed(() => {
    const isNationalIdPhotoValid = form.nationalIdPhoto || previews.nationalIdPhoto;
    const isSelfiePhotoValid = form.selfiePhoto || previews.selfiePhoto;
    return form.nationalIdNumber && form.nationalIdExpiryDate && isNationalIdPhotoValid && isSelfiePhotoValid;
});



// const fetchVerificationData = async () => {
//     try {
//         const data = await $api('/users/me');
//         originalData = { ...data };

//         if (data.nationalIdNumber) form.nationalIdNumber = data.nationalIdNumber;
//         if (data.nationalIdExpiryDate) form.nationalIdExpiryDate = data.nationalIdExpiryDate.split('T')[0];
//         if (data.nationalIdPhotoUrl) previews.nationalIdPhoto = data.nationalIdPhotoUrl;
//         if (data.selfiePhotoUrl) previews.selfiePhoto = data.selfiePhotoUrl;
//     } catch (error) {
//         toast.error('เกิดข้อผิดพลาด', 'ไม่สามารถดึงข้อมูลเดิมของคุณได้');
//         console.error("Could not fetch existing verification data:", error);
//     }
// };

// onMounted(() => {
//     fetchVerificationData();
// });

const resetForm = () => {
    form.nationalIdNumber = '';
    formattedNationalId.value = '';
    form.nationalIdExpiryDate = '';
    form.nationalIdPhoto = null;
    form.selfiePhoto = null;
    previews.nationalIdPhoto = '';
    previews.selfiePhoto = '';

    // Reset file input fields if they exist to clear the selection
    if (nationalIdInput.value) nationalIdInput.value.value = '';
    if (selfieInput.value) selfieInput.value.value = '';
};

const triggerFileInput = (type) => {
    if (type === 'nationalIdPhoto') {
        nationalIdInput.value?.click();
    } else if (type === 'selfiePhoto') {
        selfieInput.value?.click();
    }
};

const handleFileChange = (event, type) => {
    const file = event.target.files?.[0];
    if (!file) return;

    if (type === 'nationalIdPhoto') {
        form.nationalIdPhoto = file;
        previews.nationalIdPhoto = URL.createObjectURL(file);
    } else if (type === 'selfiePhoto') {
        form.selfiePhoto = file;
        previews.selfiePhoto = URL.createObjectURL(file);
    }
};

const handleSubmit = async () => {
    if (!isFormValid.value) {
        toast.warning('ข้อมูลไม่ครบถ้วน', 'กรุณากรอกข้อมูลและอัปโหลดรูปภาพให้ครบทุกช่อง');
        return;
    }
    isLoading.value = true;
    try {
        const formData = new FormData();
        formData.append('nationalIdNumber', form.nationalIdNumber);

        const isoExpiryDate = new Date(form.nationalIdExpiryDate).toISOString();
        formData.append('nationalIdExpiryDate', isoExpiryDate);

        // [UPDATED] Changed key names to match API specification
        if (form.nationalIdPhoto instanceof File) {
            formData.append('nationalIdPhotoUrl', form.nationalIdPhoto);
        }
        if (form.selfiePhoto instanceof File) {
            formData.append('selfiePhotoUrl', form.selfiePhoto);
        }

        const updatedUser = await $api('/users/me', {
            method: 'PUT',
            body: formData,
        });

        userCookie.value = updatedUser;
        originalData = { ...updatedUser };

        toast.success('ส่งข้อมูลสำเร็จ', 'คำขอยืนยันตัวตนของคุณถูกส่งแล้ว');

    } catch (error) {
        toast.error('เกิดข้อผิดพลาด', error.data?.message || 'ไม่สามารถส่งข้อมูลได้');
    } finally {
        isLoading.value = false;
    }
};
</script>

<style scoped>
/* Copied from the HTML file */
.license-card {
    background: linear-gradient(135deg, #ffffff 0%, #f8fafc 100%);
    border: 3px solid #1e40af;
    border-radius: 12px;
    position: relative;
    overflow: hidden;
    box-shadow: 0 4px 12px rgba(30, 64, 175, 0.2);
}

.license-card::before {
    content: '';
    position: absolute;
    top: -50%;
    left: -50%;
    width: 200%;
    height: 200%;
    background: linear-gradient(45deg, transparent 30%, rgba(255, 255, 255, 0.3) 50%, transparent 70%);
    animation: shine 4s infinite;
}

@keyframes shine {
    0% {
        transform: translateX(-100%) translateY(-100%);
    }

    100% {
        transform: translateX(100%) translateY(100%);
    }
}

.selfie-frame {
    background: linear-gradient(135deg, #fef3c7 0%, #fbbf24 100%);
    border: 3px solid #f59e0b;
    border-radius: 20px;
    position: relative;
    overflow: hidden;
    box-shadow: 0 4px 12px rgba(245, 158, 11, 0.2);
}

.upload-zone {
    transition: all 0.3s ease;
    cursor: pointer;
}

.upload-zone:hover {
    transform: translateY(-2px);
    box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
}

.step-indicator {
    background: linear-gradient(135deg, #10b981 0%, #059669 100%);
    color: white;
    width: 28px;
    height: 28px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 14px;
    font-weight: bold;
    flex-shrink: 0;
    box-shadow: 0 2px 8px rgba(16, 185, 129, 0.3);
}

.thai-text {
    font-size: 10px;
    color: #1e40af;
    font-weight: 500;
}

.person-silhouette {
    background: linear-gradient(135deg, #6b7280 0%, #4b5563 100%);
    border-radius: 50%;
    position: relative;
}

.held-card {
    background: linear-gradient(135deg, #dbeafe 0%, #bfdbfe 100%);
    border: 2px solid #3b82f6;
    border-radius: 6px;
    transform: rotate(-15deg);
    box-shadow: 0 2px 8px rgba(59, 130, 246, 0.3);
}
</style>