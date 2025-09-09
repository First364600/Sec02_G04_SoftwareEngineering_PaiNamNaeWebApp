<template>
  <div class="bg-gray-50 min-h-screen flex items-center justify-center p-4 font-['Kanit']">
    <main class="bg-white rounded-lg shadow-lg max-w-md w-full p-6 sm:p-8">
      <h1 class="text-3xl font-bold text-blue-600 mb-8 text-center">สมัครสมาชิก</h1>

      <!-- Stepper Indicator -->
      <div class="relative mb-10">
        <div class="absolute top-1/2 left-0 w-full h-0.5 bg-gray-200 -translate-y-1/2"></div>
        <div class="absolute top-1/2 left-0 h-0.5 bg-blue-600 -translate-y-1/2 transition-all duration-500"
          :style="{ width: stepProgress }"></div>
        <div class="flex justify-between items-center relative">
          <div v-for="step in totalSteps" :key="step" class="flex flex-col items-center w-1/3 z-10">
            <div :class="getStepClass(step)">
              <span>{{ step }}</span>
            </div>
            <span :class="getLabelClass(step)">{{ getStepLabel(step) }}</span>
          </div>
        </div>
      </div>

      <!-- Registration Form -->
      <form @submit.prevent="handleRegister" novalidate>
        <!-- Step 1: Account Info -->
        <div v-if="currentStep === 1">
          <h2 class="text-xl font-semibold text-gray-800 mb-4">ข้อมูลบัญชีผู้ใช้</h2>
          <div class="mb-4">
            <label for="username" class="block text-sm font-medium text-gray-700 mb-1">ชื่อผู้ใช้ <span
                class="text-red-500">*</span></label>
            <input type="text" id="username" v-model="formData.username" placeholder="example123"
              class="w-full px-4 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 transition"
              :class="{ 'border-red-500 ring-1 ring-red-500': errors.username }">
            <p v-if="errors.username" class="text-red-600 text-xs mt-1">{{ errors.username }}</p>
            <p v-else class="mt-1 text-xs text-gray-500">ความยาว 4–20 ตัวอักษร ภาษาอังกฤษ ตัวเลข หรือขีดล่าง (_)
              เท่านั้น</p>
          </div>
          <div class="mb-4">
            <label for="email" class="block text-sm font-medium text-gray-700 mb-1">อีเมล <span
                class="text-red-500">*</span></label>
            <input type="email" id="email" v-model="formData.email" placeholder="example@example.com"
              class="w-full px-4 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 transition"
              :class="{ 'border-red-500 ring-1 ring-red-500': errors.email }">
            <p v-if="errors.email" class="text-red-600 text-xs mt-1">{{ errors.email }}</p>
          </div>
          <div class="mb-4">
            <label for="password" class="block text-sm font-medium text-gray-700 mb-1">รหัสผ่าน <span
                class="text-red-500">*</span></label>
            <input type="password" id="password" v-model="formData.password" placeholder="อย่างน้อย 8 ตัวอักษร"
              class="w-full px-4 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 transition"
              :class="{ 'border-red-500 ring-1 ring-red-500': errors.password }">
            <p v-if="errors.password" class="text-red-600 text-xs mt-1">{{ errors.password }}</p>
            <p v-else class="mt-1 text-xs text-gray-500">ต้องประกอบด้วย A–Z, a–z และตัวเลข 0–9</p>
          </div>
          <div class="mb-6">
            <label for="confirmPassword" class="block text-sm font-medium text-gray-700 mb-1">ยืนยันรหัสผ่าน <span
                class="text-red-500">*</span></label>
            <input type="password" id="confirmPassword" v-model="formData.confirmPassword"
              placeholder="กรอกรหัสผ่านอีกครั้ง"
              class="w-full px-4 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 transition"
              :class="{ 'border-red-500 ring-1 ring-red-500': errors.confirmPassword }">
            <p v-if="errors.confirmPassword" class="text-red-600 text-xs mt-1">{{ errors.confirmPassword }}</p>
          </div>
          <button type="button" @click="nextStep"
            class="w-full py-3 bg-blue-600 text-white rounded-md font-medium hover:bg-blue-700 transition">ถัดไป</button>
        </div>

        <!-- Step 2: Personal Info -->
        <div v-if="currentStep === 2">
          <h2 class="text-xl font-semibold text-gray-800 mb-4">ข้อมูลส่วนตัว</h2>
          <div class="mb-4">
            <label for="firstName" class="block text-sm font-medium text-gray-700 mb-1">ชื่อจริง <span
                class="text-red-500">*</span></label>
            <input type="text" id="firstName" v-model="formData.firstName" placeholder="กรอกชื่อจริง"
              class="w-full px-4 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 transition"
              :class="{ 'border-red-500 ring-1 ring-red-500': errors.firstName }">
            <p v-if="errors.firstName" class="text-red-600 text-xs mt-1">{{ errors.firstName }}</p>
          </div>
          <div class="mb-4">
            <label for="lastName" class="block text-sm font-medium text-gray-700 mb-1">นามสกุล <span
                class="text-red-500">*</span></label>
            <input type="text" id="lastName" v-model="formData.lastName" placeholder="กรอกนามสกุล"
              class="w-full px-4 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 transition"
              :class="{ 'border-red-500 ring-1 ring-red-500': errors.lastName }">
            <p v-if="errors.lastName" class="text-red-600 text-xs mt-1">{{ errors.lastName }}</p>
          </div>
          <div class="mb-4">
            <label for="phoneNumber" class="block text-sm font-medium text-gray-700 mb-1">เบอร์โทรศัพท์ <span
                class="text-red-500">*</span></label>
            <input type="tel" id="phoneNumber" v-model="formData.phoneNumber" placeholder="เช่น 0891234567"
              class="w-full px-4 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 transition"
              :class="{ 'border-red-500 ring-1 ring-red-500': errors.phoneNumber }">
            <p v-if="errors.phoneNumber" class="text-red-600 text-xs mt-1">{{ errors.phoneNumber }}</p>
          </div>
          <div class="mb-6">
            <label class="block text-sm font-medium text-gray-700 mb-2">เพศ <span class="text-red-500">*</span></label>
            <div class="flex gap-6">
              <label class="flex items-center"><input type="radio" name="gender" value="male" v-model="formData.gender"
                  class="mr-2 text-blue-600 focus:ring-blue-500"> ชาย</label>
              <label class="flex items-center"><input type="radio" name="gender" value="female"
                  v-model="formData.gender" class="mr-2 text-blue-600 focus:ring-blue-500"> หญิง</label>
            </div>
            <p v-if="errors.gender" class="text-red-600 text-xs mt-1">{{ errors.gender }}</p>
          </div>
          <div class="flex gap-4">
            <button type="button" @click="prevStep"
              class="w-full py-3 bg-gray-600 text-white rounded-md font-medium hover:bg-gray-700 transition">ย้อนกลับ</button>
            <button type="button" @click="nextStep"
              class="w-full py-3 bg-blue-600 text-white rounded-md font-medium hover:bg-blue-700 transition">ถัดไป</button>
          </div>
        </div>

        <!-- Step 3: Verification -->
        <div v-if="currentStep === 3">
          <h2 class="text-xl font-semibold text-gray-800 mb-4">ยืนยันตัวตน</h2>
          <div class="mb-4">
            <label class="block text-sm font-medium text-gray-700 mb-1">บัตรประชาชน <span
                class="text-red-500">*</span></label>
            <div v-if="!idCardPreview" @click="triggerFileUpload('idCardFile')"
              class="border-2 border-dashed border-gray-300 rounded-md p-6 text-center cursor-pointer hover:border-blue-500 transition"
              :class="{ 'border-red-500 ring-1 ring-red-500': errors.idCardFile }">
              <i class="fa-regular fa-image text-4xl text-gray-400"></i>
              <p class="mt-2 text-sm text-gray-600">กดเพื่อเลือกรูปภาพ</p>
            </div>
            <div v-else class="relative">
              <img :src="idCardPreview" alt="ID Card Preview" class="w-full rounded-md mt-2" />
              <button type="button" @click="removeImage('idCard')"
                class="absolute top-2 right-2 bg-black bg-opacity-50 text-white rounded-full w-6 h-6 flex items-center justify-center">&times;</button>
            </div>
            <input type="file" id="idCardFile" @change="handleFileUpload($event, 'idCard')" accept="image/*"
              class="hidden">
            <p v-if="errors.idCardFile" class="text-red-600 text-xs mt-1">{{ errors.idCardFile }}</p>
          </div>
          <div class="mb-4">
            <label for="idNumber" class="block text-sm font-medium text-gray-700 mb-1">หมายเลขบัตรประชาชน <span
                class="text-red-500">*</span></label>
            <input type="text" id="idNumber" v-model="formData.idNumber" placeholder="กรอกหมายเลข 13 หลัก"
              class="w-full px-4 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 transition"
              :class="{ 'border-red-500 ring-1 ring-red-500': errors.idNumber }">
            <p v-if="errors.idNumber" class="text-red-600 text-xs mt-1">{{ errors.idNumber }}</p>
          </div>
          <div class="mb-4">
            <label for="expiryDate" class="block text-sm font-medium text-gray-700 mb-1">วันหมดอายุบัตร <span
                class="text-red-500">*</span></label>
            <input type="text" id="expiryDate" v-model="formData.expiryDate" placeholder="วว/ดด/ปปปป"
              @input="formatExpiryDate" maxlength="10"
              class="w-full px-4 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 transition"
              :class="{ 'border-red-500 ring-1 ring-red-500': errors.expiryDate }">
            <p v-if="errors.expiryDate" class="text-red-600 text-xs mt-1">{{ errors.expiryDate }}</p>
          </div>
          <div class="mb-4">
            <label class="block text-sm font-medium text-gray-700 mb-1">รูปถ่ายใบหน้าปกติ (Selfie) <span
                class="text-red-500">*</span></label>
            <div v-if="!selfiePreview" @click="triggerFileUpload('selfieFile')"
              class="border-2 border-dashed border-gray-300 rounded-md p-6 text-center cursor-pointer hover:border-blue-500 transition"
              :class="{ 'border-red-500 ring-1 ring-red-500': errors.selfieFile }">
              <i class="fa-regular fa-image text-4xl text-gray-400"></i>
              <p class="mt-2 text-sm text-gray-600">กดเพื่อเลือกรูปภาพ</p>
            </div>
            <div v-else class="relative">
              <img :src="selfiePreview" alt="Selfie Preview" class="w-full rounded-md mt-2" />
              <button type="button" @click="removeImage('selfie')"
                class="absolute top-2 right-2 bg-black bg-opacity-50 text-white rounded-full w-6 h-6 flex items-center justify-center">&times;</button>
            </div>
            <input type="file" id="selfieFile" @change="handleFileUpload($event, 'selfie')" accept="image/*"
              class="hidden">
            <p v-if="errors.selfieFile" class="text-red-600 text-xs mt-1">{{ errors.selfieFile }}</p>
          </div>
          <div class="mb-4 bg-red-50 border border-red-200 rounded-md p-4 text-sm text-red-700">
            <p class="font-semibold mb-2">ข้อควรหลีกเลี่ยง:</p>
            <ul class="space-y-1">
              <li class="flex items-center"><i
                  class="fa-solid fa-circle-xmark mr-2 text-red-500"></i>ใบหน้าไม่ชัดหรือถูกบัง</li>
              <li class="flex items-center"><i
                  class="fa-solid fa-circle-xmark mr-2 text-red-500"></i>บัตรไม่ชัดหรือไม่เต็ม</li>
              <li class="flex items-center"><i class="fa-solid fa-circle-xmark mr-2 text-red-500"></i>แสงน้อยเกินไป</li>
              <li class="flex items-center"><i class="fa-solid fa-circle-xmark mr-2 text-red-500"></i>ระยะไกลเกินไป</li>
            </ul>
          </div>
          <div class="mb-6">
            <label class="flex items-start">
              <input type="checkbox" v-model="formData.pdpa"
                class="mr-3 mt-1 h-4 w-4 text-blue-600 border-gray-300 rounded focus:ring-blue-500">
              <span class="text-sm text-gray-700">ข้าพเจ้ายินยอมรับ <a href="#"
                  class="text-blue-600 hover:underline">ข้อตกลงและเงื่อนไขฯ</a> และได้อ่าน <a href="#"
                  class="text-blue-600 hover:underline">นโยบายความเป็นส่วนตัว</a> แล้ว</span>
            </label>
            <p v-if="errors.pdpa" class="text-red-600 text-xs mt-1">{{ errors.pdpa }}</p>
          </div>
          <div class="flex gap-4">
            <button type="button" @click="prevStep"
              class="w-full py-3 bg-gray-600 text-white rounded-md font-medium hover:bg-gray-700 transition">ย้อนกลับ</button>
            <button type="submit"
              class="w-full py-3 bg-blue-600 text-white rounded-md font-medium hover:bg-blue-700 transition">สมัครสมาชิก</button>
          </div>
        </div>
      </form>

      <p class="mt-8 text-center text-gray-600 text-sm">
        มีบัญชีแล้ว? <NuxtLink to="/login" class="text-blue-600 hover:underline font-medium">เข้าสู่ระบบ</NuxtLink>
      </p>
    </main>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue';
import { useAuth } from '~/composables/useAuth';
import { useRouter } from '#app';

const { register } = useAuth();
const router = useRouter();

const currentStep = ref(1);
const totalSteps = 3;

const formData = reactive({
  username: '',
  email: '',
  password: '',
  confirmPassword: '',
  firstName: '',
  lastName: '',
  phoneNumber: '',
  gender: '',
  idCardFile: null,
  idNumber: '',
  expiryDate: '',
  selfieFile: null,
  pdpa: false,
});

const errors = reactive({});
const idCardPreview = ref(null);
const selfiePreview = ref(null);

onMounted(() => {
  const faScript = document.createElement('script');
  faScript.src = 'https://kit.fontawesome.com/a076d05399.js';
  faScript.crossOrigin = 'anonymous';
  document.head.appendChild(faScript);

  const fontLink = document.createElement('link');
  fontLink.href = 'https://fonts.googleapis.com/css2?family=Kanit:wght@400;500;600;700&display=swap';
  fontLink.rel = 'stylesheet';
  document.head.appendChild(fontLink);
});

const stepProgress = computed(() => {
  if (totalSteps <= 1) return '0%';
  return `${((currentStep.value - 1) / (totalSteps - 1)) * 100}%`;
});

const getStepLabel = (step) => {
  return ['บัญชีผู้ใช้', 'ข้อมูลส่วนตัว', 'ยืนยันตัวตน'][step - 1];
};

const getStepClass = (step) => {
  let baseClasses = 'flex items-center justify-center w-10 h-10 rounded-full font-semibold transition-all duration-500';
  if (step < currentStep.value) {
    return `${baseClasses} bg-blue-600 text-white`;
  } else if (step === currentStep.value) {
    return `${baseClasses} bg-blue-600 text-white ring-4 ring-blue-200`;
  } else {
    return `${baseClasses} bg-gray-300 text-gray-500`;
  }
};

const getLabelClass = (step) => {
  let baseClasses = 'text-xs text-center mt-2 transition-all duration-500';
  if (step < currentStep.value) {
    return `${baseClasses} font-semibold text-blue-600`;
  } else if (step === currentStep.value) {
    return `${baseClasses} font-semibold text-blue-600`;
  } else {
    return `${baseClasses} text-gray-500`;
  }
};

const clearErrors = () => {
  Object.keys(errors).forEach(key => delete errors[key]);
};

const validationFunctions = [
  () => {
    clearErrors();
    if (!formData.username || formData.username.length < 4) errors.username = 'ชื่อผู้ใช้ต้องมีอย่างน้อย 4 ตัวอักษร';
    if (!/^\S+@\S+\.\S+$/.test(formData.email)) errors.email = 'รูปแบบอีเมลไม่ถูกต้อง';
    if (!formData.password || formData.password.length < 8) errors.password = 'รหัสผ่านต้องมีอย่างน้อย 8 ตัวอักษร';
    if (formData.password !== formData.confirmPassword || !formData.confirmPassword) errors.confirmPassword = 'รหัสผ่านไม่ตรงกัน';
    return Object.keys(errors).length === 0;
  },
  () => {
    clearErrors();
    if (!formData.firstName.trim()) errors.firstName = 'กรุณากรอกชื่อจริง';
    if (!formData.lastName.trim()) errors.lastName = 'กรุณากรอกนามสกุล';
    if (!/^\d{9,10}$/.test(formData.phoneNumber)) errors.phoneNumber = 'รูปแบบเบอร์โทรศัพท์ไม่ถูกต้อง';
    if (!formData.gender) errors.gender = 'กรุณาเลือกเพศ';
    return Object.keys(errors).length === 0;
  },
  () => {
    clearErrors();
    if (!formData.idCardFile) errors.idCardFile = 'กรุณาอัปโหลดรูปบัตรประชาชน';
    if (!/^\d{13}$/.test(formData.idNumber)) errors.idNumber = 'กรุณากรอกหมายเลขบัตรประชาชน 13 หลัก';
    if (!formData.expiryDate.trim() || !/^\d{2}\/\d{2}\/\d{4}$/.test(formData.expiryDate)) errors.expiryDate = 'กรุณากรอกวันหมดอายุบัตรในรูปแบบ วว/ดด/ปปปป';
    if (!formData.selfieFile) errors.selfieFile = 'กรุณาอัปโหลดรูปถ่ายใบหน้า';
    if (!formData.pdpa) errors.pdpa = 'กรุณายอมรับข้อตกลงและเงื่อนไข';
    return Object.keys(errors).length === 0;
  }
];

const nextStep = () => {
  if (validationFunctions[currentStep.value - 1]()) {
    if (currentStep.value < totalSteps) {
      currentStep.value++;
    }
  }
};

const prevStep = () => {
  if (currentStep.value > 1) {
    currentStep.value--;
    clearErrors();
  }
};

const handleRegister = async () => {
  if (validationFunctions[currentStep.value - 1]()) {
    console.log('Form is valid, preparing data to submit...');
    const parts = formData.expiryDate.split('/');
    const isoDate = new Date(`${parts[2]}-${parts[1]}-${parts[0]}`).toISOString();

    const dataToSubmit = new FormData();
    dataToSubmit.append('email', formData.email);
    dataToSubmit.append('username', formData.username);
    dataToSubmit.append('password', formData.password);
    dataToSubmit.append('firstName', formData.firstName);
    dataToSubmit.append('lastName', formData.lastName);
    dataToSubmit.append('phoneNumber', formData.phoneNumber);
    dataToSubmit.append('gender', formData.gender.toUpperCase());
    dataToSubmit.append('nationalIdNumber', formData.idNumber);
    dataToSubmit.append('nationalIdExpiryDate', isoDate);
    dataToSubmit.append('nationalIdPhotoUrl', formData.idCardFile);
    dataToSubmit.append('selfiePhotoUrl', formData.selfieFile);

    try {
      await register(dataToSubmit);
      router.push('/register/success');
    } catch (err) {
      console.error('Registration failed:', err);
      const errorMessage = err.data?.message || 'สมัครสมาชิกไม่สำเร็จ กรุณาลองใหม่อีกครั้ง';
      alert(errorMessage);
    }
  }
};

const triggerFileUpload = (inputId) => {
  document.getElementById(inputId)?.click();
};

const handleFileUpload = (event, type) => {
  const file = event.target.files?.[0];
  if (!file) return;

  const reader = new FileReader();
  reader.onload = (e) => {
    const result = e.target?.result;
    if (type === 'idCard') {
      idCardPreview.value = result;
      formData.idCardFile = file;
      if (errors.idCardFile) delete errors.idCardFile;
    } else if (type === 'selfie') {
      selfiePreview.value = result;
      formData.selfieFile = file;
      if (errors.selfieFile) delete errors.selfieFile;
    }
  };
  reader.readAsDataURL(file);
};

const removeImage = (type) => {
  if (type === 'idCard') {
    idCardPreview.value = null;
    formData.idCardFile = null;
  } else if (type === 'selfie') {
    selfiePreview.value = null;
    formData.selfieFile = null;
  }
}

const formatExpiryDate = () => {
  let value = formData.expiryDate;
  const digits = value.replace(/\D/g, '');
  if (digits.length <= 2) {
    formData.expiryDate = digits;
  } else if (digits.length <= 4) {
    formData.expiryDate = `${digits.slice(0, 2)}/${digits.slice(2)}`;
  } else {
    formData.expiryDate = `${digits.slice(0, 2)}/${digits.slice(2, 4)}/${digits.slice(4, 8)}`;
  }
};
</script>

<style scoped>
/* Scoped styles for the parent component can remain here if any */
</style>
