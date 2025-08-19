<template>
    <div class="bg-gray-50">
        <div class="min-h-screen flex items-center justify-center py-8">
            <div
                class="flex bg-white rounded-lg shadow-lg overflow-hidden max-w-6xl w-full mx-4 border border-gray-200">

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
                        <h1 class="text-3xl font-bold text-gray-800 mb-2">การยืนยันตัวตนสำหรับผู้ขับขี่</h1>
                        <p class="text-gray-600 max-w-md mx-auto">
                            อัปโหลดภาพบัตรขับขี่ประจำตัวและรูปถ่าย เพื่อยืนยันตัวตนของคุณ
                        </p>
                    </div>

                    <div class="bg-white rounded-xl p-8 ">
                        <form @submit.prevent="handleSubmit" novalidate class="space-y-8">

                            <div class="relative">
                                <div class="flex items-center mb-6">
                                    <div class="step-indicator mr-4">1</div>
                                    <label class="text-xl font-semibold text-gray-800">
                                        รูปบัตรขับขี่ประจำตัว (ด้านหน้า) <span class="text-red-500">*</span>
                                    </label>
                                </div>
                                <h4 class="text-sm font-medium text-gray-700 mb-2">ตัวอย่างที่ถูกต้อง:</h4>
                                <div class="grid md:grid-cols-2 gap-6 mb-6">
                                    <div class="space-y-4">
                                        <div class="license-card p-6 h-40 relative">
                                            <div class="relative z-10 h-full flex flex-col justify-between">
                                                <div class="flex justify-between items-start">
                                                    <div>
                                                        <div class="thai-text">ใบอนุญาติขับรถยนต์</div>
                                                        <div class="text-xs text-blue-800 font-bold">DRIVING LICENSE
                                                        </div>
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
                                    <div @click="triggerFileInput('licensePhoto')"
                                        class="upload-zone h-40 border-2 border-dashed border-gray-300 rounded-lg p-8 bg-gray-50 hover:bg-gray-100 hover:border-blue-400 relative flex items-center justify-center">
                                        <div v-if="!previews.licensePhoto" class="text-center">
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
                                        <img v-else :src="previews.licensePhoto"
                                            class="w-full h-full object-cover rounded-md" />
                                        <input type="file" ref="licensePhotoInput"
                                            @change="handleFileChange($event, 'licensePhoto')" class="hidden"
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
                                        <input type="file" ref="selfiePhotoInput"
                                            @change="handleFileChange($event, 'selfiePhoto')" class="hidden"
                                            accept="image/png, image/jpeg" />
                                    </div>
                                </div>
                            </div>

                            <div class="relative">
                                <div class="flex items-center mb-4">
                                    <div class="step-indicator mr-4">3</div>
                                    <h2 class="text-xl font-semibold text-gray-800">ข้อมูลในบัตรขับขี่ประจำตัว</h2>
                                </div>
                                <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6">
                                    <div>
                                        <label for="firstNameOnLicense"
                                            class="block text-sm font-medium text-gray-700 mb-2">ชื่อ (บนบัตร) <span
                                                class="text-red-500">*</span></label>
                                        <input v-model="form.firstNameOnLicense" id="firstNameOnLicense" type="text"
                                            class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
                                            required />
                                    </div>
                                    <div>
                                        <label for="lastNameOnLicense"
                                            class="block text-sm font-medium text-gray-700 mb-2">นามสกุล (บนบัตร) <span
                                                class="text-red-500">*</span></label>
                                        <input v-model="form.lastNameOnLicense" id="lastNameOnLicense" type="text"
                                            class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
                                            required />
                                    </div>
                                    <div>
                                        <label for="licenseNumber"
                                            class="block text-sm font-medium text-gray-700 mb-2">เลขที่ใบขับขี่ <span
                                                class="text-red-500">*</span></label>
                                        <input v-model="form.licenseNumber" id="licenseNumber" type="text"
                                            class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
                                            required />
                                    </div>
                                    <div>
                                        <label for="typeOnLicense"
                                            class="block text-sm font-medium text-gray-700 mb-2">ชนิดของบัตรขับขี่ <span
                                                class="text-red-500">*</span></label>
                                        <select v-model="form.typeOnLicense" id="typeOnLicense"
                                            class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
                                            required>
                                            <option disabled value="">กรุณาเลือกชนิดของบัตร</option>
                                            <option value="PRIVATE_CAR_TEMPORARY">รถยนต์ส่วนบุคคลชั่วคราว (2 ปี)
                                            </option>
                                            <option value="PRIVATE_CAR">รถยนต์ส่วนบุคคล (5 ปี)</option>
                                            <option value="PUBLIC_CAR">รถยนต์สาธารณะ</option>
                                            <option value="LIFETIME">ตลอดชีพ</option>
                                        </select>
                                    </div>
                                    <div>
                                        <label for="licenseIssueDate"
                                            class="block text-sm font-medium text-gray-700 mb-2">วันออกใบขับขี่ <span
                                                class="text-red-500">*</span></label>
                                        <input v-model="form.licenseIssueDate" id="licenseIssueDate" type="date"
                                            class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
                                            required />
                                    </div>
                                    <div>
                                        <label for="licenseExpiryDate"
                                            class="block text-sm font-medium text-gray-700 mb-2">วันหมดอายุใบขับขี่
                                            <span class="text-red-500">*</span></label>
                                        <input v-model="form.licenseExpiryDate" id="licenseExpiryDate" type="date"
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
import { ref, reactive, computed } from 'vue'
import ProfileSidebar from '~/components/ProfileSidebar.vue';
import { useToast } from '~/composables/useToast';

definePageMeta({
    middleware: 'auth'
});

const { $api } = useNuxtApp();
const { toast } = useToast();

const isLoading = ref(false);
const licensePhotoInput = ref(null);
const selfiePhotoInput = ref(null);

const form = reactive({
    licenseNumber: '',
    firstNameOnLicense: '',
    lastNameOnLicense: '',
    licenseIssueDate: '',
    licenseExpiryDate: '',
    typeOnLicense: '',
    licensePhoto: null,
    selfiePhoto: null,
});

const previews = reactive({
    licensePhoto: '',
    selfiePhoto: ''
});

const isFormValid = computed(() => {
    return form.licenseNumber && form.firstNameOnLicense && form.lastNameOnLicense &&
        form.licenseIssueDate && form.licenseExpiryDate && form.typeOnLicense &&
        form.licensePhoto && form.selfiePhoto;
});

const triggerFileInput = (type) => {
    if (type === 'licensePhoto') {
        licensePhotoInput.value?.click();
    } else if (type === 'selfiePhoto') {
        selfiePhotoInput.value?.click();
    }
};

const handleFileChange = (event, type) => {
    const file = event.target.files?.[0];
    if (!file) return;

    if (type === 'licensePhoto') {
        form.licensePhoto = file;
        previews.licensePhoto = URL.createObjectURL(file);
    } else if (type === 'selfiePhoto') {
        form.selfiePhoto = file;
        previews.selfiePhoto = URL.createObjectURL(file);
    }
};

const resetForm = () => {
    form.licenseNumber = '';
    form.firstNameOnLicense = '';
    form.lastNameOnLicense = '';
    form.licenseIssueDate = '';
    form.licenseExpiryDate = '';
    form.typeOnLicense = '';
    form.licensePhoto = null;
    form.selfiePhoto = null;
    previews.licensePhoto = '';
    previews.selfiePhoto = '';

    if (licensePhotoInput.value) licensePhotoInput.value.value = '';
    if (selfiePhotoInput.value) selfiePhotoInput.value.value = '';
};

const handleSubmit = async () => {
    if (!isFormValid.value) {
        toast.warning('ข้อมูลไม่ครบถ้วน', 'กรุณากรอกข้อมูลและอัปโหลดรูปภาพให้ครบทุกช่อง');
        return;
    }
    isLoading.value = true;
    try {
        const formData = new FormData();
        formData.append('licenseNumber', form.licenseNumber);
        formData.append('firstNameOnLicense', form.firstNameOnLicense);
        formData.append('lastNameOnLicense', form.lastNameOnLicense);
        formData.append('typeOnLicense', form.typeOnLicense);
        formData.append('licenseIssueDate', new Date(form.licenseIssueDate).toISOString());
        formData.append('licenseExpiryDate', new Date(form.licenseExpiryDate).toISOString());

        if (form.licensePhoto) {
            formData.append('licensePhotoUrl', form.licensePhoto);
        }
        if (form.selfiePhoto) {
            formData.append('selfiePhotoUrl', form.selfiePhoto);
        }

        await $api('/driver-verifications', {
            method: 'POST',
            body: formData,
        });

        toast.success('ส่งข้อมูลสำเร็จ', 'คำขอยืนยันตัวตนผู้ขับขี่ของคุณถูกส่งแล้ว');
        resetForm();

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

.selfie-frame {
    background: linear-gradient(135deg, #fef3c7 0%, #fbbf24 100%);
    border: 3px solid #f59e0b;
    border-radius: 20px;
    position: relative;
    overflow: hidden;
    box-shadow: 0 4px 12px rgba(245, 158, 11, 0.2);
}

.person-silhouette {
    background: linear-gradient(135deg, #6b7280 0%, #4b5563 100%);
    border-radius: 50%;
    position: relative;
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
</style>