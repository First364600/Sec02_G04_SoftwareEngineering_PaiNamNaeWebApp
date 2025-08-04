<template>
    <div class="bg-gray-50">
        <!-- Main Container - Centered -->
        <div class="min-h-screen flex items-center justify-center py-8">
            <div class="flex bg-white rounded-lg shadow-lg overflow-hidden max-w-6xl w-full mx-4">

                <!-- Sidebar Menu -->
                <aside class="w-80 bg-gray-50 p-6 border-r border-gray-200 hidden md:block">
                    <!-- Header -->
                    <div class="mb-8">
                        <h1 class="text-xl font-bold text-gray-900 text-center mb-2">โปรไฟล์และการตั้งค่า</h1>
                        <p class="text-sm text-gray-600 text-center">จัดการข้อมูลส่วนตัวและความปลอดภัยของบัญชี</p>
                    </div>

                    <!-- Menu Items -->
                    <nav class="space-y-4">
                        <!-- การจัดการบัญชี -->
                        <div>
                            <h3 class="text-sm font-semibold text-gray-900 mb-2 px-4">การจัดการบัญชี</h3>
                            <ul class="space-y-1">
                                <li>
                                    <a href="#"
                                        :class="['block px-4 py-2 text-sm rounded-md font-medium', activeTab === 'profile' ? 'text-blue-600 bg-blue-100' : 'text-gray-700 hover:bg-gray-100']">
                                        โปรไฟล์ของฉัน
                                    </a>
                                </li>
                            </ul>
                        </div>

                        <!-- การยืนยันตัวตน -->
                        <div>
                            <h3 class="text-sm font-semibold text-gray-900 mb-2 px-4">การยืนยันตัวตน</h3>
                            <ul class="space-y-1">
                                <li>
                                    <a href="#" @click.prevent="activeTab = 'verification'"
                                        :class="['block px-4 py-2 text-sm rounded-md', activeTab === 'verification' ? 'text-blue-600 bg-blue-100' : 'text-gray-700 hover:bg-gray-100']">
                                        การยืนยันตัวตนขั้นพื้นฐาน
                                    </a>
                                </li>
                                <li>
                                    <NuxtLink to="/"
                                        class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 rounded-md">
                                        การยืนยันตัวตนสำหรับผู้ขับขี่
                                    </NuxtLink>
                                </li>
                            </ul>
                        </div>

                        <!-- โหมดผู้ขับขี่ -->
                        <div>
                            <h3 class="text-sm font-semibold text-gray-900 mb-2 px-4">โหมดผู้ขับขี่</h3>
                            <ul class="space-y-1">
                                <li>
                                    <a href="#"
                                        :class="['block px-4 py-2 text-sm rounded-md', activeTab === 'myCar' ? 'text-blue-600 bg-blue-100' : 'text-gray-700 hover:bg-gray-100']">
                                        ข้อมูลรถยนต์ของฉัน
                                    </a>
                                </li>
                            </ul>
                        </div>
                    </nav>
                </aside>

                <!-- Main Content -->
                <main class="flex-1 p-8 overflow-y-auto" style="max-height: 90vh;">

                    <!-- My Profile Section -->
                    <div>
                        <div class="text-center mb-8">
                            <h2 class="text-2xl font-bold text-gray-900 mb-2">โปรไฟล์ของฉัน</h2>
                            <p class="text-sm text-gray-600">จัดการข้อมูลส่วนตัวของคุณให้เป็นปัจจุบันอยู่เสมอ</p>
                        </div>

                        <form @submit.prevent="handleProfileUpdate" class="space-y-6" novalidate>
                            <!-- รูปโปรไฟล์ -->
                            <div class="text-center">
                                <img :src="previewUrl" alt="Profile Preview"
                                    class="w-24 h-24 rounded-full mx-auto mb-3 object-cover border-4 border-white shadow-md" />
                                <p class="text-xs text-gray-600 mb-3">* ระบบจะใช้รูปภาพนี้เพื่อแสดงบนโปรไฟล์</p>
                                <input type="file" accept="image/*" @change="handleFileChange"
                                    class="mx-auto block text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-full file:border-0 file:text-sm file:font-medium file:bg-blue-50 file:text-blue-700 hover:file:bg-blue-100 cursor-pointer" />
                            </div>

                            <!-- ชื่อจริง -->
                            <div>
                                <label for="firstName"
                                    class="block text-sm font-medium text-gray-700 mb-2">ชื่อจริง</label>
                                <input id="firstName" v-model="firstName" type="text" placeholder="กรอกชื่อจริง"
                                    class="w-full px-4 py-3 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500" />
                            </div>

                            <!-- นามสกุล -->
                            <div>
                                <label for="lastName"
                                    class="block text-sm font-medium text-gray-700 mb-2">นามสกุล</label>
                                <input id="lastName" v-model="lastName" type="text" placeholder="กรอกนามสกุล" required
                                    class="w-full px-4 py-3 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500" />
                            </div>

                            <!-- เบอร์โทรศัพท์ -->
                            <div>
                                <label for="phone"
                                    class="block text-sm font-medium text-gray-700 mb-2">เบอร์โทรศัพท์</label>
                                <input type="text" id="phone" v-model="phoneNumber" disabled
                                    class="w-full px-4 py-3 border border-gray-200 bg-gray-100 rounded-md text-gray-600" />
                            </div>

                            <!-- อีเมล -->
                            <div>
                                <label for="email" class="block text-sm font-medium text-gray-700 mb-2">อีเมล</label>
                                <input id="email" v-model="email" type="email" placeholder="example@example.com"
                                    class="w-full px-4 py-3 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500" />
                            </div>

                            <!-- วันที่สร้างบัญชี -->
                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-2">วันที่สร้างบัญชี</label>
                                <input type="text" :value="formatDate(user?.createdAt)" disabled
                                    class="w-full px-4 py-3 border border-gray-200 bg-gray-100 rounded-md text-gray-600" />
                            </div>

                            <!-- วันที่แก้ไขล่าสุด -->
                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-2">วันที่แก้ไขล่าสุด</label>
                                <input type="text" :value="formatDate(user?.updatedAt)" disabled
                                    class="w-full px-4 py-3 border border-gray-200 bg-gray-100 rounded-md text-gray-600" />
                            </div>

                            <!-- เปลี่ยนรหัสผ่าน -->
                            <div class="border-t border-gray-200 pt-6">
                                <h3 class="text-lg font-semibold text-gray-800 mb-4">เปลี่ยนรหัสผ่าน</h3>
                                <div class="space-y-4">
                                    <div>
                                        <label for="currentPassword"
                                            class="block text-sm font-medium text-gray-700 mb-2">รหัสผ่านเดิม</label>
                                        <input type="password" id="currentPassword" placeholder="กรอกรหัสผ่านเดิม"
                                            v-model="currentPassword"
                                            class="w-full px-4 py-3 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500" />
                                    </div>
                                    <div>
                                        <label for="newPassword"
                                            class="block text-sm font-medium text-gray-700 mb-2">รหัสผ่านใหม่</label>
                                        <input type="password" id="newPassword" minlength="6" v-model="newPassword"
                                            placeholder="รหัสผ่านใหม่ (อย่างน้อย 6 ตัวอักษร)"
                                            class="w-full px-4 py-3 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500" />
                                    </div>
                                    <div>
                                        <label for="confirmPassword"
                                            class="block text-sm font-medium text-gray-700 mb-2">ยืนยันรหัสผ่านใหม่</label>
                                        <input type="password" id="confirmPassword" minlength="6"
                                            v-model="confirmNewPassword" placeholder="กรอกรหัสผ่านใหม่อีกครั้ง"
                                            class="w-full px-4 py-3 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500" />
                                    </div>
                                </div>
                            </div>

                            <!-- ปุ่มดำเนินการ -->
                            <div class="pt-6 flex justify-end gap-4">
                                <button type="button" @click="resetForm"
                                    class="px-6 py-3 border border-gray-300 text-gray-700 rounded-md hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-gray-400">
                                    ยกเลิก
                                </button>
                                <button type="submit"
                                    class="px-6 py-3 bg-blue-600 text-white rounded-md font-medium hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500">
                                    บันทึกการเปลี่ยนแปลง
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
import { ref, onMounted } from 'vue'
import { useNuxtApp } from '#app'
import { useAuth } from '~/composables/useAuth';
import dayjs from 'dayjs'

const { $api } = useNuxtApp()
const { user } = useAuth()

const firstName = ref('')
const lastName = ref('')
const email = ref('')
const phoneNumber = ref('')
const currentPassword = ref('')
const newPassword = ref('')
const confirmNewPassword = ref('')
const profilePictureFile = ref(null)
const previewUrl = ref('')

onMounted(() => {
    if (user.value) {
        firstName.value = user.value.firstName || ''
        lastName.value = user.value.lastName || ''
        email.value = user.value.email || ''
        phoneNumber.value = user.value.phoneNumber || ''
    }

    if (user.value.profilePicture) {
        const pic = user.value.profilePicture
        previewUrl.value = pic.startsWith('http')
            ? pic
            : `${useNuxtApp().$config.public.apiBase}${pic}`
    }
})

function resetForm() {
    if (user.value) {
        firstName.value = user.value.firstName || ''
        lastName.value = user.value.lastName || ''
        email.value = user.value.email || ''
        phoneNumber.value = user.value.phoneNumber || ''

        currentPassword.value = user.value.currentPassword || ''
        newPassword.value = user.value.newPassword || ''
        confirmNewPassword.value = user.value.confirmNewPassword || ''
    }
}

// ฟอร์แมตรูปวันที่
function formatDate(raw) {
    return raw ? dayjs(raw).format('YYYY-MM-DD HH:mm') : ''
}

function handleFileChange(e) {
    const file = e.target.files?.[0]
    if (file) {
        profilePictureFile.value = file
        previewUrl.value = URL.createObjectURL(file)
    }
}

async function handleProfileUpdate() {
    try {
        // const payload = {
        //     firstName: firstName.value,
        //     lastName: lastName.value,
        //     email: email.value
        // }

        const form = new FormData()
        form.append('firstName', firstName.value)
        form.append('lastName', lastName.value)
        form.append('email', email.value)

        if (profilePictureFile.value) {
            form.append('profilePicture', profilePictureFile.value)
        }
        const updatedUser = await $api('/users/me', {
            method: 'PUT',
            body: form
        })
        user.value = updatedUser

        if (currentPassword.value || newPassword.value || confirmNewPassword.value) {
            if (!currentPassword.value || !newPassword.value || !confirmNewPassword.value) {
                alert('กรุณากรอกรหัสผ่านให้ครบถ้วน')
                return
            }
            if (newPassword.value !== confirmNewPassword.value) {
                alert('รหัสผ่านใหม่ไม่ตรงกัน')
                return
            }

            await $api('/auth/change-password', {
                method: 'PUT',
                body: {
                    currentPassword: currentPassword.value,
                    newPassword: newPassword.value,
                    confirmNewPassword: confirmNewPassword.value
                }
            })
            alert('เปลี่ยนรหัสผ่านสำเร็จ')

            currentPassword.value = ''
            newPassword.value = ''
            confirmNewPassword.value = ''
        }

        alert('อัพเดตโปรไฟล์สำเร็จ')
    } catch (err) {
        console.error(err)
        alert('เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง')
    }
}
</script>

<style scoped></style>
