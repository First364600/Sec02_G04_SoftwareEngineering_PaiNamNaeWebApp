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
                                    <a href="#" @click.prevent="activeTab = 'profile'"
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
                                    <NuxtLink to="/driver-verification"
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
                                    <a href="#" @click.prevent="activeTab = 'myCar'"
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
                    <div v-if="activeTab === 'profile'">
                        <div class="text-center mb-8">
                            <h2 class="text-2xl font-bold text-gray-900 mb-2">โปรไฟล์ของฉัน</h2>
                            <p class="text-sm text-gray-600">จัดการข้อมูลส่วนตัวของคุณให้เป็นปัจจุบันอยู่เสมอ</p>
                        </div>

                        <form @submit.prevent="handleProfileUpdate" class="space-y-6" novalidate>
                            <!-- รูปโปรไฟล์ -->
                            <div class="text-center">
                                <img v-if="profilePicturePreview" :src="profilePicturePreview" alt="Profile Preview"
                                    class="w-24 h-24 rounded-full mx-auto mb-3 object-cover border-4 border-white shadow-md">
                                <div v-else
                                    class="w-24 h-24 bg-blue-500 rounded-full mx-auto mb-3 flex items-center justify-center border-4 border-white shadow-md">
                                    <svg class="w-12 h-12 text-white" fill="currentColor" viewBox="0 0 24 24">
                                        <path
                                            d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z" />
                                    </svg>
                                </div>
                                <p class="text-xs text-gray-600 mb-3">* ระบบจะใช้รูปภาพนี้เพื่อแสดงบนโปรไฟล์</p>
                                <input type="file" @change="handleProfilePictureChange" accept="image/*"
                                    class="mx-auto block text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-full file:border-0 file:text-sm file:font-medium file:bg-blue-50 file:text-blue-700 hover:file:bg-blue-100 cursor-pointer" />
                            </div>

                            <!-- ชื่อจริง -->
                            <div>
                                <label for="firstName" class="block text-sm font-medium text-gray-700 mb-2">ชื่อจริง
                                    *</label>
                                <input v-model="formData.firstName" id="firstName" type="text"
                                    placeholder="กรอกชื่อจริง" required
                                    class="w-full px-4 py-3 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500" />
                            </div>

                            <!-- นามสกุล -->
                            <div>
                                <label for="lastName" class="block text-sm font-medium text-gray-700 mb-2">นามสกุล
                                    *</label>
                                <input v-model="formData.lastName" id="lastName" type="text" placeholder="กรอกนามสกุล"
                                    required
                                    class="w-full px-4 py-3 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500" />
                            </div>

                            <!-- เบอร์โทรศัพท์ -->
                            <div>
                                <label for="phone"
                                    class="block text-sm font-medium text-gray-700 mb-2">เบอร์โทรศัพท์</label>
                                <input type="text" id="phone" value="0803852628" disabled
                                    class="w-full px-4 py-3 border border-gray-200 bg-gray-100 rounded-md text-gray-600" />
                            </div>

                            <!-- อีเมล -->
                            <div>
                                <label for="email" class="block text-sm font-medium text-gray-700 mb-2">อีเมล</label>
                                <input v-model="formData.email" id="email" type="email"
                                    placeholder="example@example.com"
                                    class="w-full px-4 py-3 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500" />
                            </div>

                            <!-- วันที่สร้างบัญชี -->
                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-2">วันที่สร้างบัญชี</label>
                                <input type="text" value="2025-01-01 12:00" disabled
                                    class="w-full px-4 py-3 border border-gray-200 bg-gray-100 rounded-md text-gray-600" />
                            </div>

                            <!-- วันที่แก้ไขล่าสุด -->
                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-2">วันที่แก้ไขล่าสุด</label>
                                <input type="text" value="2025-07-01 14:30" disabled
                                    class="w-full px-4 py-3 border border-gray-200 bg-gray-100 rounded-md text-gray-600" />
                            </div>

                            <!-- เปลี่ยนรหัสผ่าน -->
                            <div class="border-t border-gray-200 pt-6">
                                <h3 class="text-lg font-semibold text-gray-800 mb-4">เปลี่ยนรหัสผ่าน</h3>
                                <div class="space-y-4">
                                    <div>
                                        <label for="currentPassword"
                                            class="block text-sm font-medium text-gray-700 mb-2">รหัสผ่านเดิม</label>
                                        <input v-model="passwordData.current" type="password" id="currentPassword"
                                            placeholder="กรอกรหัสผ่านเดิม"
                                            class="w-full px-4 py-3 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500" />
                                    </div>
                                    <div>
                                        <label for="newPassword"
                                            class="block text-sm font-medium text-gray-700 mb-2">รหัสผ่านใหม่</label>
                                        <input v-model="passwordData.new" type="password" id="newPassword" minlength="6"
                                            placeholder="รหัสผ่านใหม่ (อย่างน้อย 6 ตัวอักษร)"
                                            class="w-full px-4 py-3 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500" />
                                    </div>
                                    <div>
                                        <label for="confirmPassword"
                                            class="block text-sm font-medium text-gray-700 mb-2">ยืนยันรหัสผ่านใหม่</label>
                                        <input v-model="passwordData.confirm" type="password" id="confirmPassword"
                                            minlength="6" placeholder="กรอกรหัสผ่านใหม่อีกครั้ง"
                                            class="w-full px-4 py-3 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500" />
                                    </div>
                                </div>
                            </div>

                            <!-- ปุ่มดำเนินการ -->
                            <div class="pt-6 flex justify-end gap-4">
                                <button type="button"
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

                    <!-- Placeholder for other tabs -->
                    <div v-if="activeTab !== 'profile'" class="text-center py-24">
                        <h2 class="text-2xl font-bold text-gray-900 mb-2">{{ tabTitle }}</h2>
                        <p class="text-center text-gray-500 mt-4">เนื้อหาในส่วนนี้ยังไม่ถูกสร้าง</p>
                    </div>

                </main>
            </div>
        </div>
    </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue';
import { useAuth } from '~/composables/useAuth';

// ดึงข้อมูลผู้ใช้จาก composable
const { user } = useAuth();

// State สำหรับจัดการแท็บที่กำลังแสดง
const activeTab = ref('profile');

// Computed property to display correct title for placeholder tabs
const tabTitle = computed(() => {
    if (activeTab.value === 'verification') return 'การยืนยันตัวตนขั้นพื้นฐาน';
    if (activeTab.value === 'myCar') return 'ข้อมูลรถยนต์ของฉัน';
    return '';
});

// State สำหรับเก็บข้อมูลในฟอร์มโปรไฟล์
const formData = reactive({
    firstName: '',
    lastName: '',
    email: '',
    profilePictureFile: null,
});

// State สำหรับเก็บข้อมูลรหัสผ่าน
const passwordData = reactive({
    current: '',
    new: '',
    confirm: '',
});

// State สำหรับแสดงภาพโปรไฟล์ตัวอย่าง
const profilePicturePreview = ref(null);

// เมื่อ component ถูกสร้าง ให้ดึงข้อมูล user มาใส่ในฟอร์ม
onMounted(() => {
    if (user.value) {
        formData.firstName = user.value.firstName || '';
        formData.lastName = user.value.lastName || '';
        formData.email = user.value.email || '';
        // If user object has a profile picture URL, set it here
        // profilePicturePreview.value = user.value.profilePictureUrl || null;
    }
});

// ฟังก์ชันจัดการเมื่อมีการเลือกไฟล์รูปโปรไฟล์
const handleProfilePictureChange = (event) => {
    const file = event.target.files?.[0];
    if (!file) return;

    formData.profilePictureFile = file;

    // สร้าง URL สำหรับแสดงภาพตัวอย่าง
    const reader = new FileReader();
    reader.onload = (e) => {
        profilePicturePreview.value = e.target.result;
    };
    reader.readAsDataURL(file);
};

// ฟังก์ชันที่จะทำงานเมื่อกดปุ่ม "บันทึกการเปลี่ยนแปลง"
const handleProfileUpdate = () => {
    if (passwordData.new && passwordData.new !== passwordData.confirm) {
        alert('รหัสผ่านใหม่และการยืนยันรหัสผ่านไม่ตรงกัน');
        return;
    }

    const dataToSubmit = new FormData();
    dataToSubmit.append('firstName', formData.firstName);
    dataToSubmit.append('lastName', formData.lastName);
    dataToSubmit.append('email', formData.email);

    if (formData.profilePictureFile) {
        dataToSubmit.append('profilePicture', formData.profilePictureFile);
    }

    if (passwordData.current && passwordData.new) {
        dataToSubmit.append('currentPassword', passwordData.current);
        dataToSubmit.append('newPassword', passwordData.new);
    }

    console.log('กำลังบันทึกข้อมูลโปรไฟล์...');
    for (let [key, value] of dataToSubmit.entries()) {
        console.log(`${key}:`, value);
    }

    alert('บันทึกข้อมูลโปรไฟล์สำเร็จ!');
};

</script>

<style scoped>
/* Scoped styles can be added here if needed */
</style>
