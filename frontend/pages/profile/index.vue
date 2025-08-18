<template>
    <div class="bg-gray-50">
        <div class="min-h-screen flex items-center justify-center py-8 ">
            <div class="flex bg-white rounded-lg shadow-lg overflow-hidden max-w-6xl w-full mx-4 border border-gray-300">

                <ProfileSidebar />

                <main class="flex-1 p-8 ">
                    <div>
                        <div class="text-center mb-8">
                            <h2 class="text-2xl font-bold text-gray-900 mb-2">โปรไฟล์ของฉัน</h2>
                            <p class="text-sm text-gray-600">จัดการข้อมูลส่วนตัวของคุณให้เป็นปัจจุบันอยู่เสมอ</p>
                        </div>

                        <form @submit.prevent="handleProfileUpdate" class="space-y-6" novalidate>
                            <div class="text-center">
                                <img :src="previewUrl" alt="Profile Preview"
                                    class="w-24 h-24 rounded-full mx-auto mb-3 object-cover border-4 border-white shadow-md" />
                                <input type="file" accept="image/*" @change="handleFileChange" ref="fileInput"
                                    class="hidden" />
                                <button type="button" @click="fileInput.click()"
                                    class="text-sm text-blue-600 hover:text-blue-800 font-medium">เปลี่ยนรูปภาพ</button>
                            </div>

                            <div>
                                <label for="username"
                                    class="block text-sm font-medium text-gray-700 mb-2">ชื่อผู้ใช้</label>
                                <input id="username" :value="originalUserData?.username" type="text" disabled
                                    class="w-full px-4 py-3 border border-gray-200 bg-gray-100 rounded-md text-gray-600" />
                            </div>

                            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                                <div>
                                    <label for="firstName"
                                        class="block text-sm font-medium text-gray-700 mb-2">ชื่อจริง</label>
                                    <input id="firstName" v-model="form.firstName" type="text"
                                        placeholder="กรอกชื่อจริง" @focus="showNameWarning = true"
                                        @blur="showNameWarning = false"
                                        class="w-full px-4 py-3 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500" />
                                </div>
                                <div>
                                    <label for="lastName"
                                        class="block text-sm font-medium text-gray-700 mb-2">นามสกุล</label>
                                    <input id="lastName" v-model="form.lastName" type="text" placeholder="กรอกนามสกุล"
                                        @focus="showNameWarning = true" @blur="showNameWarning = false"
                                        class="w-full px-4 py-3 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500" />
                                </div>
                            </div>

                            <div v-if="showNameWarning" class="text-center -mt-2">
                                <p class="text-sm text-red-600">
                                    หากมีการเปลี่ยนแปลงชื่อ-นามสกุล กรุณาตรวจสอบให้แน่ใจว่าตรงกับบัตรประชาชน
                                    <br>และอาจจำเป็นต้องยืนยันตัวตนสำหรับผู้ขับขี่ใหม่อีกครั้ง
                                </p>
                            </div>

                            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                                <div>
                                    <label for="email"
                                        class="block text-sm font-medium text-gray-700 mb-2">อีเมล</label>
                                    <input id="email" v-model="form.email" type="email"
                                        placeholder="example@example.com"
                                        class="w-full px-4 py-3 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500" />
                                </div>
                                <div>
                                    <label for="phoneNumber"
                                        class="block text-sm font-medium text-gray-700 mb-2">เบอร์โทรศัพท์</label>
                                    <input id="phoneNumber" v-model="form.phoneNumber" type="text"
                                        placeholder="กรอกเบอร์โทรศัพท์"
                                        class="w-full px-4 py-3 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500" />
                                </div>
                            </div>

                            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                                <div>
                                    <label class="block text-sm font-medium text-gray-700 mb-2">วันที่สร้างบัญชี</label>
                                    <input type="text" :value="formatDate(originalUserData?.createdAt)" disabled
                                        class="w-full px-4 py-3 border border-gray-200 bg-gray-100 rounded-md text-gray-600" />
                                </div>
                                <div>
                                    <label
                                        class="block text-sm font-medium text-gray-700 mb-2">วันที่แก้ไขล่าสุด</label>
                                    <input type="text" :value="formatDate(originalUserData?.updatedAt)" disabled
                                        class="w-full px-4 py-3 border border-gray-200 bg-gray-100 rounded-md text-gray-600" />
                                </div>
                            </div>

                            <div class="border-t border-gray-200 pt-6">
                                <h3 class="text-lg font-semibold text-gray-800 mb-4">เปลี่ยนรหัสผ่าน</h3>
                                <div>
                                    <label for="currentPassword"
                                        class="block text-sm font-medium text-gray-700 mb-2">รหัสผ่านเดิม</label>
                                    <input type="password" id="currentPassword" placeholder="กรอกรหัสผ่านเดิม"
                                        v-model="form.currentPassword"
                                        class="w-full px-4 py-3 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500" />
                                </div>

                                <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mt-4">
                                    <div>
                                        <label for="newPassword"
                                            class="block text-sm font-medium text-gray-700 mb-2">รหัสผ่านใหม่</label>
                                        <input type="password" id="newPassword" minlength="6" v-model="form.newPassword"
                                            placeholder="รหัสผ่านใหม่ (อย่างน้อย 6 ตัวอักษร)"
                                            class="w-full px-4 py-3 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500" />
                                    </div>
                                    <div>
                                        <label for="confirmNewPassword"
                                            class="block text-sm font-medium text-gray-700 mb-2">ยืนยันรหัสผ่านใหม่</label>
                                        <input type="password" id="confirmNewPassword" minlength="6"
                                            v-model="form.confirmNewPassword" placeholder="กรอกรหัสผ่านใหม่อีกครั้ง"
                                            class="w-full px-4 py-3 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500" />
                                    </div>
                                </div>
                            </div>

                            <div class="pt-6 flex justify-end gap-4">
                                <button type="button" @click="resetForm" :disabled="isLoading"
                                    class="px-6 py-3 border border-gray-300 text-gray-700 rounded-md hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-gray-400 disabled:opacity-50">
                                    ยกเลิก
                                </button>
                                <button type="submit" :disabled="isLoading"
                                    class="px-6 py-3 bg-blue-600 text-white rounded-md font-medium hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 disabled:bg-blue-400 disabled:cursor-not-allowed flex items-center">
                                    <svg v-if="isLoading" class="animate-spin -ml-1 mr-3 h-5 w-5 text-white"
                                        xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                                        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor"
                                            stroke-width="4"></circle>
                                        <path class="opacity-75" fill="currentColor"
                                            d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z">
                                        </path>
                                    </svg>
                                    {{ isLoading ? 'กำลังบันทึก...' : 'บันทึกการเปลี่ยนแปลง' }}
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
import { ref, onMounted, reactive } from 'vue'
import { useAuth } from '~/composables/useAuth';
import { useToast } from '~/composables/useToast';
import ProfileSidebar from '~/components/ProfileSidebar.vue';
import dayjs from 'dayjs'
import 'dayjs/locale/th'

dayjs.locale('th')

definePageMeta({
    middleware: 'auth'
});

const { $api } = useNuxtApp()
const { user: userCookie } = useAuth()
const { toast } = useToast(); // [FIXED] Initialize the toast object

const fileInput = ref(null)
const previewUrl = ref('')
const isLoading = ref(false)
const showNameWarning = ref(false);

const form = reactive({
    firstName: '',
    lastName: '',
    email: '',
    phoneNumber: '',
    profilePictureFile: null,
    currentPassword: '',
    newPassword: '',
    confirmNewPassword: '',
});

let originalUserData = null;

const fetchUserData = async () => {
    try {
        const data = await $api('/users/me');
        originalUserData = { ...data };
        resetForm();
    } catch (error) {
        console.error("Failed to fetch user data:", error);
        toast.error('เกิดข้อผิดพลาด', 'ไม่สามารถดึงข้อมูลผู้ใช้ได้');
    }
}

const resetForm = () => {
    if (originalUserData) {
        form.firstName = originalUserData.firstName || '';
        form.lastName = originalUserData.lastName || '';
        form.email = originalUserData.email || '';
        form.phoneNumber = originalUserData.phoneNumber || '';
        previewUrl.value = originalUserData.profilePicture || `https://ui-avatars.com/api/?name=${form.firstName || 'U'}&background=random&size=128`;

        form.currentPassword = '';
        form.newPassword = '';
        form.confirmNewPassword = '';
        form.profilePictureFile = null;
    }
};

const formatDate = (dateString) => {
    if (!dateString) return '';
    return dayjs(dateString).format('D MMMM YYYY HH:mm');
}

onMounted(() => {
    fetchUserData();
});

function handleFileChange(e) {
    const file = e.target.files?.[0]
    if (file) {
        form.profilePictureFile = file
        previewUrl.value = URL.createObjectURL(file)
    }
}

async function handleProfileUpdate() {
    isLoading.value = true;

    try {
        const formData = new FormData()
        formData.append('firstName', form.firstName);
        formData.append('lastName', form.lastName);
        formData.append('email', form.email);
        formData.append('phoneNumber', form.phoneNumber);

        if (form.profilePictureFile) {
            formData.append('profilePicture', form.profilePictureFile);
        }

        const updatedUser = await $api('/users/me', {
            method: 'PUT',
            body: formData
        });

        userCookie.value = updatedUser;
        originalUserData = { ...updatedUser };

        let passwordChanged = false;
        if (form.currentPassword || form.newPassword || form.confirmNewPassword) {
            if (!form.currentPassword || !form.newPassword || !form.confirmNewPassword) {
                throw new Error("หากต้องการเปลี่ยนรหัสผ่าน กรุณากรอกข้อมูลรหัสผ่านให้ครบทุกช่อง");
            }
            if (form.newPassword !== form.confirmNewPassword) {
                throw new Error("รหัสผ่านใหม่และการยืนยันรหัสผ่านไม่ตรงกัน");
            }
            if (form.newPassword.length < 6) {
                throw new Error("รหัสผ่านใหม่ต้องมีอย่างน้อย 6 ตัวอักษร");
            }

            await $api('/auth/change-password', {
                method: 'PUT',
                body: {
                    currentPassword: form.currentPassword,
                    newPassword: form.newPassword,
                    confirmNewPassword: form.confirmNewPassword
                }
            });

            passwordChanged = true;
            form.currentPassword = '';
            form.newPassword = '';
            form.confirmNewPassword = '';
        }

        toast.success(
            'อัปเดตสำเร็จ!',
            passwordChanged ? 'โปรไฟล์และรหัสผ่านของคุณถูกบันทึกแล้ว' : 'ข้อมูลโปรไฟล์ของคุณถูกบันทึกแล้ว'
        );

    } catch (err) {
        const message = err.data?.message || err.message || 'เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง';
        toast.error('เกิดข้อผิดพลาด', message);
    } finally {
        isLoading.value = false;
        if (fileInput.value) {
            fileInput.value.value = '';
        }
        form.profilePictureFile = null;
    }
}
</script>

<style scoped>
/* Scoped styles can be added here if needed */
</style>