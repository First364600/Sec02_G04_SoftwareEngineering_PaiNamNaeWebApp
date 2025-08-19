<template>
    <div class="bg-gray-50">
        <div class="flex items-center justify-center py-8 ">
            <div
                class="flex bg-white rounded-lg shadow-lg overflow-hidden max-w-6xl w-full mx-4 border border-gray-300">

                <ProfileSidebar />

                
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