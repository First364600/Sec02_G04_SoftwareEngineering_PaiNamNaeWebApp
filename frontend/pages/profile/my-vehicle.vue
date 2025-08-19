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