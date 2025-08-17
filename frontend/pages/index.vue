<template>
    <div class="bg-gray-50 text-gray-900">
        <!-- HERO -->
        <section class="relative overflow-hidden">
            <div class="absolute inset-0 bg-gradient-to-b from-blue-50 to-transparent"></div>
            <div class="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pt-10 pb-16 lg:pt-16 lg:pb-24">


                <div class="grid grid-cols-1 lg:grid-cols-2 gap-8 lg:gap-12 items-center">
                    <div>
                        <h1 class="text-3xl sm:text-4xl lg:text-5xl font-extrabold tracking-tight text-gray-900">
                            เดินทางร่วมกัน <span class="text-blue-600">อย่างมั่นใจ</span> ด้วยความปลอดภัยเป็นอันดับหนึ่ง
                        </h1>
                        <p class="mt-4 text-gray-600 text-base sm:text-lg">
                            จับคู่ผู้โดยสารและผู้ขับอย่างฉลาดด้วยเส้นทางที่เหมาะสม ตรวจสอบตัวตนด้วย OTP มีปุ่ม <span
                                class="font-semibold">SOS</span> ส่งพิกัดฉุกเฉิน
                            พร้อมระบบรีวิวและติดตามแบบเรียลไทม์
                        </p>
                        <div class="mt-6 flex flex-col sm:flex-row gap-3">
                            <a href="#action-find"
                                class="inline-flex justify-center items-center bg-blue-600 text-white px-6 py-3 rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2">
                                ค้นหาเส้นทาง
                            </a>
                            <a href="#action-offer"
                                class="inline-flex justify-center items-center bg-white text-blue-600 border border-blue-200 px-6 py-3 rounded-md hover:bg-blue-50 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2">
                                เสนอเส้นทาง
                            </a>
                        </div>

                        <!-- Trust badges / stats -->
                        <div class="mt-8 grid grid-cols-2 sm:grid-cols-3 gap-4">
                            <div class="bg-white border border-gray-200 rounded-lg p-4 card">
                                <p class="text-2xl font-bold text-blue-600">4.8★</p>
                                <p class="text-sm text-gray-600">คะแนนความพึงพอใจ</p>
                            </div>
                            <div class="bg-white border border-gray-200 rounded-lg p-4 card">
                                <p class="text-2xl font-bold text-blue-600">+10K</p>
                                <p class="text-sm text-gray-600">ผู้ใช้ที่ไว้ใจ</p>
                            </div>
                            <div class="bg-white border border-gray-200 rounded-lg p-4 card">
                                <p class="text-2xl font-bold text-blue-600">24/7</p>
                                <p class="text-sm text-gray-600">ติดตามแบบเรียลไทม์</p>
                            </div>
                        </div>
                    </div>

                    <div class="relative">
                        <div class="bg-white border border-gray-200 rounded-xl shadow-md p-2 card">
                            <img class="w-full h-80 object-cover rounded-lg" alt="Carpool preview"
                                src="https://images.unsplash.com/photo-1549923746-c502d488b3ea?q=80&w=1600&auto=format&fit=crop" />
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- QUICK ACTIONS (Anchor targets for buttons) -->
        <section id="action-find" class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 -mt-10 lg:-mt-16 relative z-10">
            <div class="bg-white rounded-xl shadow-md border border-gray-200 p-6">
                <h2 class="text-xl font-semibold mb-4">เริ่มต้นอย่างรวดเร็ว</h2>
                <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-4">
                    <input type="text" placeholder="จุดเริ่มต้น"
                        class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent" />
                    <input type="text" placeholder="จุดปลายทาง"
                        class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent" />
                    <input type="date"
                        class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent" />
                    <select
                        class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent">
                        <option>1 ที่นั่ง</option>
                        <option>2 ที่นั่ง</option>
                        <option>3 ที่นั่ง</option>
                        <option>4 ที่นั่ง</option>
                    </select>
                    <button
                        class="w-full bg-blue-600 text-white py-2 px-4 rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 transition">ค้นหา</button>
                </div>
            </div>
        </section>

        <!-- FEATURES -->
        <section id="features" class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12 lg:py-16">
            <div class="text-center mb-10">
                <h2 class="text-2xl sm:text-3xl font-extrabold">ฟีเจอร์เด่นเพื่อความปลอดภัย</h2>
                <p class="mt-2 text-gray-600">ออกแบบโดยคำนึงถึงความน่าเชื่อถือและประสบการณ์ผู้ใช้</p>
            </div>

            <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
                <!-- Feature card -->
                <div class="bg-white border border-gray-200 rounded-lg p-6 card">
                    <div class="w-10 h-10 rounded-lg bg-blue-100 text-blue-600 flex items-center justify-center mb-3">🔐
                    </div>
                    <h3 class="font-semibold mb-1">ยืนยันตัวตนด้วย OTP</h3>
                    <p class="text-gray-600 text-sm">ตรวจสอบเบอร์โทรศัพท์ก่อนใช้งาน ป้องกันบัญชีปลอม
                        เพิ่มความไว้ใจทั้งสองฝ่าย</p>
                </div>
                <div class="bg-white border border-gray-200 rounded-lg p-6 card">
                    <div class="w-10 h-10 rounded-lg bg-blue-100 text-blue-600 flex items-center justify-center mb-3">🧭
                    </div>
                    <h3 class="font-semibold mb-1">แมตช์เส้นทางอัจฉริยะ</h3>
                    <p class="text-gray-600 text-sm">ใช้แผนที่และเส้นทางเพื่อจับคู่ผู้โดยสารกับผู้ขับที่เหมาะสมที่สุด
                    </p>
                </div>
                <div class="bg-white border border-gray-200 rounded-lg p-6 card">
                    <div class="w-10 h-10 rounded-lg bg-blue-100 text-blue-600 flex items-center justify-center mb-3">📡
                    </div>
                    <h3 class="font-semibold mb-1">ติดตามแบบเรียลไทม์</h3>
                    <p class="text-gray-600 text-sm">ติดตามความคืบหน้าการเดินทางด้วยจุดตรวจ (checkpoint)
                        และการอัปเดตตำแหน่ง
                    </p>
                </div>
                <div class="bg-white border border-gray-200 rounded-lg p-6 card">
                    <div class="w-10 h-10 rounded-lg bg-blue-100 text-blue-600 flex items-center justify-center mb-3">🆘
                    </div>
                    <h3 class="font-semibold mb-1">ปุ่ม SOS ส่งพิกัดฉุกเฉิน</h3>
                    <p class="text-gray-600 text-sm">ช่วยแจ้งผู้ติดต่อฉุกเฉินหรือเจ้าหน้าที่
                        พร้อมพิกัดทันทีเมื่อเกิดเหตุไม่คาดคิด</p>
                </div>
                <div class="bg-white border border-gray-200 rounded-lg p-6 card">
                    <div class="w-10 h-10 rounded-lg bg-blue-100 text-blue-600 flex items-center justify-center mb-3">⭐
                    </div>
                    <h3 class="font-semibold mb-1">รีวิวและเรตติ้ง</h3>
                    <p class="text-gray-600 text-sm">โปร่งใสด้วยคะแนนจากผู้ใช้จริง ช่วยตัดสินใจก่อนร่วมเดินทาง</p>
                </div>
                <div class="bg-white border border-gray-200 rounded-lg p-6 card">
                    <div class="w-10 h-10 rounded-lg bg-blue-100 text-blue-600 flex items-center justify-center mb-3">💬
                    </div>
                    <h3 class="font-semibold mb-1">แชทเรียลไทม์</h3>
                    <p class="text-gray-600 text-sm">สื่อสารก่อนออกเดินทางเพื่อยืนยันรายละเอียดและข้อตกลง</p>
                </div>
            </div>
        </section>

        <!-- HOW IT WORKS -->
        <section id="how" class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pb-12 lg:pb-16">
            <div class="bg-white border border-gray-200 rounded-xl p-6 lg:p-8">
                <h2 class="text-2xl font-extrabold mb-6">ใช้งานอย่างไร</h2>
                <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
                    <div class="bg-blue-50 rounded-lg p-5 border border-blue-100">
                        <h3 class="font-semibold text-blue-700 mb-3">สำหรับผู้โดยสาร</h3>
                        <ol class="space-y-2 text-gray-700 text-sm">
                            <li>1) ค้นหาเส้นทางที่ต้องการและเลือกผู้ขับที่เชื่อถือได้</li>
                            <li>2) จองที่นั่งและยืนยันผ่าน OTP</li>
                            <li>3) ติดตามการเดินทางผ่านแผนที่แบบเรียลไทม์</li>
                        </ol>
                    </div>
                    <div class="bg-green-50 rounded-lg p-5 border border-green-100">
                        <h3 class="font-semibold text-green-700 mb-3">สำหรับผู้ขับ</h3>
                        <ol class="space-y-2 text-gray-700 text-sm">
                            <li>1) เสนอเส้นทางและเวลาที่สะดวก</li>
                            <li>2) รับคำขอจองจากผู้โดยสารที่ยืนยันตัวตนแล้ว</li>
                            <li>3) ออกเดินทาง ปลอดภัยพร้อมรีวิวหลังจบการเดินทาง</li>
                        </ol>
                    </div>
                </div>
                <div class="mt-6 flex flex-col sm:flex-row gap-3">
                    <a href="#action-find"
                        class="inline-flex justify-center items-center bg-blue-600 text-white px-6 py-3 rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2">เริ่มค้นหา</a>
                    <a id="action-offer" href="#"
                        class="inline-flex justify-center items-center bg-white text-blue-600 border border-blue-200 px-6 py-3 rounded-md hover:bg-blue-50 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2">เริ่มเสนอเส้นทาง</a>
                </div>
            </div>
        </section>

        <!-- SAFETY HIGHLIGHTS -->
        <section class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pb-12 lg:pb-16">
            <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
                <div class="bg-white border border-gray-200 rounded-xl p-6 card">
                    <h3 class="font-semibold mb-2">ชั้นความปลอดภัยหลายระดับ</h3>
                    <p class="text-gray-600 text-sm">ตั้งแต่ยืนยันตัวตน, การตรวจโปรไฟล์, รีวิวชุมชน
                        จนถึงการติดตามเส้นทางทุกขั้นตอน</p>
                </div>
                <div class="bg-white border border-gray-200 rounded-xl p-6 card">
                    <h3 class="font-semibold mb-2">ความเป็นส่วนตัวมาก่อน</h3>
                    <p class="text-gray-600 text-sm">ซ่อนข้อมูลสำคัญ แสดงเฉพาะสิ่งจำเป็นก่อนยืนยันการเดินทาง</p>
                </div>
                <div class="bg-white border border-gray-200 rounded-xl p-6 card">
                    <h3 class="font-semibold mb-2">รองรับเหตุฉุกเฉิน</h3>
                    <p class="text-gray-600 text-sm">ปุ่ม SOS แจ้งเตือนพร้อมพิกัดแบบทันที ช่วยเหลือได้รวดเร็ว</p>
                </div>
            </div>
        </section>

        <!-- TESTIMONIALS -->
        <section class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pb-12 lg:pb-16">
            <div class="text-center mb-8">
                <h2 class="text-2xl sm:text-3xl font-extrabold">เสียงจากผู้ใช้</h2>
                <p class="mt-2 text-gray-600">ประสบการณ์จริงจากการเดินทางร่วมกัน</p>
            </div>
            <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                <div class="bg-white border border-gray-200 rounded-lg p-6 card">
                    <div class="flex items-center space-x-3">
                        <img class="w-10 h-10 rounded-full object-cover"
                            src="https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=60&h=60&fit=crop&crop=face"
                            alt="avatar" />
                        <div>
                            <p class="font-semibold">สมชาย ใจดี</p>
                            <p class="text-yellow-500 text-sm">★★★★★</p>
                        </div>
                    </div>
                    <p class="mt-3 text-gray-600 text-sm">ระบบชัดเจน ปลอดภัย อุ่นใจตลอดทริป</p>
                </div>
                <div class="bg-white border border-gray-200 rounded-lg p-6 card">
                    <div class="flex items-center space-x-3">
                        <img class="w-10 h-10 rounded-full object-cover"
                            src="https://images.unsplash.com/photo-1494790108755-2616b2dc0a48?w=60&h=60&fit=crop&crop=face"
                            alt="avatar" />
                        <div>
                            <p class="font-semibold">วรรณา สุขใจ</p>
                            <p class="text-yellow-500 text-sm">★★★★☆</p>
                        </div>
                    </div>
                    <p class="mt-3 text-gray-600 text-sm">จับคู่ไว เส้นทางสะดวก ประหยัดเวลา</p>
                </div>
                <div class="bg-white border border-gray-200 rounded-lg p-6 card">
                    <div class="flex items-center space-x-3">
                        <img class="w-10 h-10 rounded-full object-cover"
                            src="https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=60&h=60&fit=crop&crop=face"
                            alt="avatar" />
                        <div>
                            <p class="font-semibold">อนุชา รักเดินทาง</p>
                            <p class="text-yellow-500 text-sm">★★★★★</p>
                        </div>
                    </div>
                    <p class="mt-3 text-gray-600 text-sm">ผู้ขับและผู้โดยสารสุภาพมาก ๆ แนะนำเลย</p>
                </div>
            </div>
        </section>

        <!-- FAQ -->
        <section class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pb-12 lg:pb-16">
            <div class="bg-white border border-gray-200 rounded-xl divide-y divide-gray-200">
                <div class="p-6">
                    <h2 class="text-2xl font-extrabold">คำถามที่พบบ่อย</h2>
                </div>

                <div class="p-6">
                    <button class="w-full text-left font-medium flex justify-between items-center"
                        @click="toggleFaq('f1')">
                        ต้องยืนยันตัวตนอย่างไร?
                        <svg class="w-4 h-4 ml-1 transition-transform duration-300"
                            :class="{ 'rotate-180': openFaqId === 'f1' }" fill="none" stroke="currentColor"
                            viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7">
                            </path>
                        </svg>
                    </button>
                    <div class="faq-content mt-3 text-gray-600 text-sm" :class="{ 'show': openFaqId === 'f1' }">
                        <p>ผู้ใช้ต้องยืนยันหมายเลขโทรศัพท์ด้วยรหัส OTP ก่อนใช้งานจองหรือเสนอเส้นทาง</p>
                    </div>
                </div>

                <div class="p-6">
                    <button class="w-full text-left font-medium flex justify-between items-center"
                        @click="toggleFaq('f2')">
                        ปลอดภัยระหว่างเดินทางอย่างไร?
                        <svg class="w-4 h-4 ml-1 transition-transform duration-300"
                            :class="{ 'rotate-180': openFaqId === 'f2' }" fill="none" stroke="currentColor"
                            viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7">
                            </path>
                        </svg>
                    </button>
                    <div class="faq-content mt-3 text-gray-600 text-sm" :class="{ 'show': openFaqId === 'f2' }">
                        <p>มีปุ่ม SOS ส่งพิกัดฉุกเฉิน, การติดตามแบบเรียลไทม์ และระบบรีวิวช่วยคัดกรอง</p>
                    </div>
                </div>

                <div class="p-6">
                    <button class="w-full text-left font-medium flex justify-between items-center"
                        @click="toggleFaq('f3')">
                        มีค่าธรรมเนียมหรือไม่?
                        <svg class="w-4 h-4 ml-1 transition-transform duration-300"
                            :class="{ 'rotate-180': openFaqId === 'f3' }" fill="none" stroke="currentColor"
                            viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7">
                            </path>
                        </svg>
                    </button>
                    <div class="faq-content mt-3 text-gray-600 text-sm" :class="{ 'show': openFaqId === 'f3' }">
                        <p>ไม่มีค่าใช้บริการพื้นฐาน อาจมีค่าธรรมเนียมบางส่วนขึ้นกับการชำระเงินในอนาคต</p>
                    </div>
                </div>
            </div>
        </section>

        <!-- FINAL CTA -->
        <section class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pb-16">
            <div
                class="bg-blue-600 text-white rounded-2xl p-8 lg:p-10 flex flex-col lg:flex-row items-start lg:items-center justify-between gap-6">
                <div>
                    <h3 class="text-2xl font-bold">พร้อมออกเดินทางร่วมกันอย่างปลอดภัยแล้วหรือยัง?</h3>
                    <p class="text-blue-100 mt-1">เข้าร่วมชุมชนไปนำแหน่วันนี้</p>
                </div>
                <div class="flex gap-3 w-full sm:w-auto">
                    <a href="#action-find"
                        class="flex-1 sm:flex-none inline-flex justify-center items-center bg-white text-blue-600 px-6 py-3 rounded-md hover:bg-blue-50 focus:outline-none focus:ring-2 focus:ring-white focus:ring-offset-2 focus:ring-offset-blue-600">เริ่มค้นหาเส้นทาง</a>
                    <a href="#"
                        class="flex-1 sm:flex-none inline-flex justify-center items-center bg-blue-700 text-white px-6 py-3 rounded-md hover:bg-blue-800 focus:outline-none focus:ring-2 focus:ring-white focus:ring-offset-2 focus:ring-offset-blue-700">เริ่มเสนอเส้นทาง</a>
                </div>
            </div>
        </section>

        <!-- FOOTER -->
        <footer class="border-t border-gray-200 bg-white">
            <div
                class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6 text-sm text-gray-600 flex flex-col sm:flex-row items-center sm:items-center justify-between gap-3">
                <p>© <span id="y"></span> Pai Nam Nae. สงวนลิขสิทธิ์.</p>

            </div>
        </footer>

    </div>
</template>

<script setup>
import { ref } from 'vue';

// สร้าง State เพื่อเก็บ ID ของคำถามที่กำลังเปิดอยู่
const openFaqId = ref(null);

// ฟังก์ชันสำหรับเปิด/ปิด FAQ
const toggleFaq = (id) => {
    if (openFaqId.value === id) {
        // ถ้าคลิกคำถามที่เปิดอยู่แล้ว ให้ปิดมัน
        openFaqId.value = null;
    } else {
        // ถ้าคลิกคำถามใหม่ ให้เปิดอันนั้น
        openFaqId.value = id;
    }
};
</script>

<style scoped>
.card {
    transition: all 0.3s ease;
}

.card:hover {
    transform: translateY(-2px);
    box-shadow: 0 10px 25px rgba(59, 130, 246, 0.15);
}

.badge {
    display: inline-flex;
    align-items: center;
    padding: 0.25rem 0.5rem;
    border-radius: 9999px;
    font-size: 0.75rem;
    font-weight: 600;
}

.faq-content {
    max-height: 0;
    overflow: hidden;
    transition: max-height 0.4s ease-out;
}

.faq-content.show {
    max-height: 200px;
    /* สามารถปรับความสูงได้ตามความเหมาะสม */
    transition: max-height 0.4s ease-in;
}

.rotate-180 {
    transform: rotate(180deg);
}
</style>