<template>
    <div>
        <div class="px-4 py-8 mx-auto max-w-7xl sm:px-6 lg:px-8">
            <div class="mb-8">
                <h2 class="text-2xl font-bold text-gray-900">การเดินทางของฉัน</h2>
                <p class="mt-2 text-gray-600">จัดการและติดตามการเดินทางทั้งหมดของคุณ</p>
            </div>

            <div class="p-6 mb-8 bg-white border border-gray-300 rounded-lg shadow-md">
                <div class="flex flex-wrap gap-2">
                    <button v-for="tab in tabs" :key="tab.status" @click="activeTab = tab.status"
                        :class="['tab-button px-4 py-2 rounded-md font-medium', { 'active': activeTab === tab.status }]">
                        {{ tab.label }} ({{ getTripCount(tab.status) }})
                    </button>
                </div>
            </div>

            <div class="grid grid-cols-1 gap-6 lg:grid-cols-3">
                <div class="lg:col-span-2">
                    <div class="bg-white border border-gray-300 rounded-lg shadow-md">
                        <div class="p-6 border-b border-gray-300">
                            <h3 class="text-lg font-semibold text-gray-900">รายการการเดินทาง</h3>
                        </div>

                        <div v-if="isLoading" class="p-12 text-center text-gray-500">
                            <p>กำลังโหลดข้อมูลการเดินทาง...</p>
                        </div>

                        <div v-else class="divide-y divide-gray-200">
                            <div v-if="filteredTrips.length === 0" class="p-12 text-center text-gray-500">
                                <p>ไม่พบรายการเดินทางในหมวดหมู่นี้</p>
                            </div>

                            <div v-for="trip in filteredTrips" :key="trip.id"
                                class="p-6 transition-colors duration-200 cursor-pointer trip-card"
                                :class="[
                                    (trip.passengerStatus === 'ARRIVED' || trip.tripStatus === 'COMPLETED' || ['rejected','cancelled'].includes(trip.status))
                                        ? 'bg-gray-50 hover:bg-gray-100 opacity-80'
                                        : 'bg-white hover:bg-gray-50'
                                ]"
                                @click="toggleTripDetails(trip.id)">

                                <!-- หัวการ์ด -->
                                <div class="flex items-start justify-between mb-4">
                                    <div class="flex-1">
                                        <div class="flex items-center justify-between">
                                            <h4 class="text-lg font-semibold"
                                                :class="(trip.passengerStatus === 'ARRIVED' || trip.tripStatus === 'COMPLETED' || ['rejected','cancelled'].includes(trip.status)) ? 'text-gray-400' : 'text-gray-900'">
                                                {{ trip.origin }} → {{ trip.destination }}
                                            </h4>
                                            <span v-if="trip.status === 'pending'" class="status-badge status-pending">รอดำเนินการ</span>
                                            <span v-else-if="trip.status === 'confirmed'" class="status-badge status-confirmed">ยืนยันแล้ว</span>
                                            <span v-else-if="trip.status === 'rejected'" class="status-badge status-rejected">ปฏิเสธ</span>
                                            <span v-else-if="trip.status === 'cancelled'" class="status-badge status-cancelled">ยกเลิก</span>
                                        </div>
                                        <p class="mt-1 text-sm text-gray-600">จุดนัดพบ: {{ trip.pickupPoint }}</p>
                                        <p class="text-sm text-gray-600">
                                            วันที่: {{ trip.date }}
                                            <span class="mx-2 text-gray-300">|</span>
                                            เวลา: {{ trip.time }}
                                            <span class="mx-2 text-gray-300">|</span>
                                            ระยะเวลา: {{ trip.durationText }}
                                            <span class="mx-2 text-gray-300">|</span>
                                            ระยะทาง: {{ trip.distanceText }}
                                        </p>
                                    </div>
                                </div>

                                <!-- ข้อมูลคนขับ -->
                                <div class="flex items-center mb-4 space-x-4">
                                    <img :src="trip.driver.image" :alt="trip.driver.name" class="object-cover w-12 h-12 rounded-full" />
                                    <div class="flex-1">
                                        <h5 class="font-medium text-gray-900">{{ trip.driver.name }}</h5>
                                        <div class="flex items-center">
                                            <div class="flex text-sm text-yellow-400">
                                                <span>
                                                    {{ '★'.repeat(Math.round(trip.driver.rating)) }}{{ '☆'.repeat(5 - Math.round(trip.driver.rating)) }}
                                                </span>
                                            </div>
                                            <span class="ml-2 text-sm text-gray-600">{{ trip.driver.rating }} ({{ trip.driver.reviews }} รีวิว)</span>
                                        </div>
                                    </div>
                                    <div class="text-right">
                                        <div class="text-lg font-bold text-blue-600">{{ trip.price }} บาท</div>
                                        <div class="text-sm text-gray-600">จำนวน {{ trip.seats }} ที่นั่ง</div>
                                    </div>
                                </div>

                                <!-- รายละเอียดเส้นทาง (เปิดเมื่อกด) -->
                                <div v-if="selectedTripId === trip.id"
                                    class="pt-4 mt-4 mb-5 duration-300 border-t border-gray-300 animate-in slide-in-from-top">
                                    <div class="grid grid-cols-1 gap-4 md:grid-cols-2">
                                        <div>
                                            <h5 class="mb-2 font-medium text-gray-900">รายละเอียดรถ</h5>
                                            <ul class="space-y-1 text-sm text-gray-600">
                                                <li v-for="detail in trip.carDetails" :key="detail">• {{ detail }}</li>
                                            </ul>
                                        </div>

                                        <div>
                                            <h5 class="mb-4 font-medium text-gray-900 flex items-center gap-2">
                                                รายละเอียดเส้นทาง
                                                <span v-if="trip.tripStatus === 'IN_TRANSIT'" class="text-[10px] text-blue-600 bg-blue-50 px-2 py-0.5 rounded-full animate-pulse">
                                                    กำลังเดินทาง
                                                </span>
                                                <span v-if="trip.tripStatus === 'COMPLETED'" class="text-[10px] text-gray-500 bg-gray-100 px-2 py-0.5 rounded-full">
                                                    สิ้นสุดการเดินทาง
                                                </span>
                                                <span v-if="trip.tripStatus === 'AVAILABLE' || trip.tripStatus === 'FULL'" class="text-[10px] text-gray-500 bg-gray-50 px-2 py-0.5 rounded-full">
                                                    ยังไม่เริ่มต้นเดินทาง
                                                </span>
                                            </h5>

                                            <div class="relative pl-2">
                                                <div class="absolute left-[15px] top-2 bottom-4 w-0.5 bg-gray-200"></div>
                                                <div class="space-y-6 relative">
                                                    <div v-for="(point, index) in getRouteTimeline(trip)" :key="index" class="flex items-start group relative mb-6">
                                                        <div v-if="index < getRouteTimeline(trip).length - 1"
                                                            class="absolute left-[15px] top-8 w-0.5 h-full bg-gray-200 z-0"></div>

                                                        <div class="relative z-10 flex-shrink-0 w-8 h-8 flex items-center justify-center rounded-full border-2 bg-white transition-all shadow-sm"
                                                            :class="index <= trip.currentStep ? 'border-blue-500 text-blue-600 bg-blue-50' : 'border-gray-300 text-gray-400'">
                                                            <span v-if="index < trip.currentStep" class="font-bold text-sm">✓</span>
                                                            <span v-else class="text-[10px] font-bold">{{ index + 1 }}</span>
                                                        </div>

                                                        <div class="ml-4 flex-1 min-w-0">
                                                            <p class="text-sm font-bold truncate mb-0.5"
                                                                :class="index <= trip.currentStep ? 'text-gray-900' : 'text-gray-500'">
                                                                {{ point.name }}
                                                            </p>

                                                            <div v-if="point.isPassengerPoint" class="mt-1 flex flex-wrap gap-1">
                                                                <template v-if="point.passengerList && point.passengerList.length > 0">
                                                                    <span v-for="(psgr, pIdx) in point.passengerList" :key="pIdx"
                                                                        class="inline-flex items-center px-2 py-0.5 rounded text-[10px] font-semibold shadow-sm bg-blue-100 text-blue-700">
                                                                        <span class="mr-1">{{ psgr.action === 'pickup' ? '↑' : '↓' }}</span>
                                                                        {{ psgr.action === 'pickup' ? 'รับ' : 'ส่ง' }}คุณ {{ psgr.name }}
                                                                    </span>
                                                                </template>
                                                            </div>

                                                            <p v-if="point.address" class="text-[10px] text-gray-400 truncate leading-tight mt-1">
                                                                {{ point.address }}
                                                            </p>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>

                                            <div v-if="trip.tripStatus === 'COMPLETED'" class="mt-4 p-3 bg-gray-50 border border-gray-200 rounded-md text-center text-sm text-gray-600 font-medium">
                                                การเดินทางนี้เสร็จสิ้นสมบูรณ์แล้ว
                                            </div>
                                        </div>
                                    </div>

                                    <div class="mt-4 space-y-4"></div>
                                </div>

                                <!-- ปุ่ม Actions + Notifications -->
                                <div class="flex flex-col gap-2" :class="{ 'mt-4': selectedTripId !== trip.id }">

                                    <!-- แจ้งเตือน: คนขับขอยกเลิก -->
                                    <div v-if="trip.driverCancelRequest && !['CANCELLED', 'ARRIVED'].includes(trip.passengerStatus)"
                                        class="p-3 bg-orange-50 border border-orange-200 rounded-md text-sm text-orange-700 flex items-start gap-2">
                                        <div>
                                            <p class="font-semibold">คนขับขอยกเลิกการเดินทางของคุณ</p>
                                            <p class="text-xs mt-0.5">กรุณาติดต่อคนขับ และเลือกยืนยันหรือปฏิเสธการยกเลิก</p>
                                        </div>
                                    </div>

                                    <!-- แจ้งเตือน: คนขับมาถึงจุดรับ -->
                                    <div v-if="trip.passengerStatus === 'WAITING_PICKUP'"
                                        class="p-3 bg-blue-50 border border-blue-200 rounded-md text-sm text-blue-700 flex items-start gap-2">
                                        <div>
                                            <p class="font-semibold">คนขับมาถึงจุดรับของคุณแล้ว!</p>
                                            <p class="text-xs mt-0.5">กรุณากดเริ่มต้นการเดินทางเพื่อยืนยันการขึ้นรถ</p>
                                        </div>
                                    </div>

                                    <!-- แจ้งเตือน: ปฏิเสธการรับ -->
                                    <div v-if="trip.passengerStatus === 'REJECTED_PICKUP'"
                                        class="p-3 bg-red-50 border border-red-200 rounded-md text-sm text-red-700">
                                        คุณได้ปฏิเสธการรับของคนขับแล้ว กรุณาติดต่อคนขับ
                                    </div>

                                    <!-- แจ้งเตือน: เสร็จสิ้น -->
                                    <div v-if="trip.passengerStatus === 'ARRIVED' || trip.tripStatus === 'COMPLETED'"
                                        class="p-3 bg-gray-50 border border-gray-200 rounded-md text-sm text-gray-600 text-center font-medium">
                                        การเดินทางเสร็จสิ้นสมบูรณ์แล้ว
                                    </div>

                                    <!-- ปุ่ม actions -->
                                    <div class="flex justify-end items-center gap-2 flex-wrap">

                                        <!-- กำลังเดินทาง -->
                                        <template v-if="trip.status === 'confirmed' && trip.tripStatus === 'IN_TRANSIT'">

                                            <!-- คนขับขอยกเลิก -->
                                            <template v-if="trip.driverCancelRequest">
                                                <button @click.stop="handlePassengerConfirmCancel(trip)"
                                                    :disabled="isProcessing"
                                                    class="px-4 py-2 text-sm font-semibold text-white bg-red-600 rounded-md hover:bg-red-700 shadow-sm transition disabled:opacity-50">
                                                    ยืนยันยกเลิกการเดินทาง
                                                </button>
                                                <button @click.stop="handlePassengerRejectCancel(trip)"
                                                    :disabled="isProcessing"
                                                    class="px-4 py-2 text-sm font-medium text-orange-600 border border-orange-300 rounded-md hover:bg-orange-50 transition disabled:opacity-50">
                                                    ปฏิเสธการยกเลิก
                                                </button>
                                            </template>

                                            <!-- ยังไม่ขึ้นรถ -->
                                            <template v-else-if="!trip.passengerStatus || trip.passengerStatus === 'WAITING_PICKUP' || trip.passengerStatus === 'REJECTED_PICKUP'">
                                                <button
                                                    v-if="trip.passengerStatus === 'WAITING_PICKUP'"
                                                    @click.stop="handlePassengerStart(trip)"
                                                    :disabled="isProcessing"
                                                    class="px-4 py-2 text-sm font-semibold text-white bg-blue-600 rounded-md hover:bg-blue-700 shadow-sm transition disabled:opacity-50">
                                                    เริ่มต้นการเดินทาง
                                                </button>
                                                <button
                                                    v-if="trip.passengerStatus === 'WAITING_PICKUP'"
                                                    @click.stop="handlePassengerRejectPickup(trip)"
                                                    :disabled="isProcessing"
                                                    class="px-4 py-2 text-sm font-medium text-red-600 border border-red-200 rounded-md hover:bg-red-50 transition disabled:opacity-50">
                                                    ปฏิเสธการเดินทาง
                                                </button>
                                            </template>

                                            <!-- กำลังเดินทางอยู่ -->
                                            <template v-else-if="trip.passengerStatus === 'IN_TRANSIT'">
                                                <!-- dropoff ≠ destination: ต้องกดเองเมื่อถึงจุดส่ง -->
                                                <template v-if="!trip.dropoffIsDestination">
                                                    <div v-if="!trip.reachedDropoff"
                                                        class="px-4 py-2 text-sm text-gray-500 bg-gray-100 rounded-md border border-gray-200">
                                                        รอคนขับถึงจุดส่งของคุณ...
                                                    </div>
                                                    <button
                                                        v-else
                                                        @click.stop="handlePassengerEndTrip(trip)"
                                                        :disabled="isProcessing"
                                                        class="px-4 py-2 text-sm font-semibold text-white bg-blue-600 rounded-md hover:bg-blue-700 shadow-sm transition disabled:opacity-50">
                                                        สิ้นสุดการเดินทาง
                                                    </button>
                                                </template>

                                                <!-- dropoff = destination: รอคนขับกด complete ระบบจบให้เลย -->
                                                <template v-else>
                                                    <div class="px-4 py-2 text-sm text-gray-500 bg-gray-100 rounded-md border border-gray-200">
                                                        รอคนขับถึงปลายทาง...
                                                    </div>
                                                </template>
                                            </template>

                                            <!-- ปุ่มข้อความจากคนขับ (แสดงเสมอตอน IN_TRANSIT) -->
                                            <button
                                                @click.stop="openMessagePanel(trip)"
                                                class="px-4 py-2 text-sm font-medium text-purple-600 border border-purple-200 rounded-md hover:bg-purple-50 transition relative">
                                                ข้อความจากคนขับ
                                                <span v-if="unreadMessages[trip.id] > 0"
                                                    class="absolute -top-1.5 -right-1.5 bg-red-500 text-white text-[10px] rounded-full w-4 h-4 flex items-center justify-center">
                                                    {{ unreadMessages[trip.id] }}
                                                </span>
                                            </button>
                                        </template>

                                        <!-- ยังไม่เริ่มเดินทาง -->
                                        <template v-else-if="trip.status === 'pending' || (trip.status === 'confirmed' && trip.tripStatus !== 'IN_TRANSIT' && trip.tripStatus !== 'COMPLETED')">
                                            <button @click.stop="openCancelModal(trip)"
                                                class="px-4 py-2 text-sm text-red-600 border border-red-200 rounded-md hover:bg-red-50 transition">
                                                ยกเลิกการจอง
                                            </button>
                                            <button v-if="trip.status === 'confirmed'"
                                                class="px-4 py-2 text-sm font-medium text-white bg-blue-600 rounded-md hover:bg-blue-700 shadow-sm transition">
                                                แชทกับผู้ขับ
                                            </button>
                                        </template>

                                        <!-- ยกเลิก/ปฏิเสธ -->
                                        <template v-else-if="['rejected', 'cancelled'].includes(trip.status)">
                                            <button @click.stop="openConfirmModal(trip, 'delete')"
                                                class="px-4 py-2 text-sm text-gray-600 border border-gray-300 rounded-md hover:bg-gray-50 transition">
                                                ลบรายการ
                                            </button>
                                        </template>
                                    </div>
                                </div>

                                <!-- Panel ข้อความจากคนขับ -->
                                <div v-if="msgPanelOpen === trip.id && bookingMessages[trip.id]"
                                    class="mt-3 border border-purple-100 rounded-xl bg-purple-50/50 p-4 space-y-3">

                                    <div v-if="bookingMessages[trip.id].length === 0" class="text-center text-xs text-gray-400">
                                        ยังไม่มีข้อความจากคนขับ
                                    </div>

                                    <div v-for="msg in bookingMessages[trip.id]" :key="msg.id" class="space-y-2">
                                        <div class="flex items-start gap-2">
                                            <img :src="trip.driver.image" class="w-7 h-7 rounded-full object-cover flex-shrink-0 mt-0.5" />
                                            <div class="flex-1 bg-white border border-purple-200 rounded-xl px-3 py-2 shadow-sm">
                                                <p class="text-xs font-semibold text-purple-600 mb-0.5">{{ trip.driver.name }}</p>
                                                <p class="text-sm text-gray-800">{{ msg.content }}</p>
                                                <p class="text-[10px] text-gray-400 mt-1">
                                                    {{ new Date(msg.createdAt).toLocaleTimeString('th-TH', { hour: '2-digit', minute: '2-digit' }) }}
                                                </p>
                                            </div>
                                        </div>

                                        <div v-for="reply in msg.replies" :key="reply.id" class="ml-9 flex justify-end">
                                            <div class="bg-purple-600 text-white rounded-xl px-3 py-2 max-w-[80%] shadow-sm">
                                                <p class="text-sm">{{ reply.content }}</p>
                                                <p class="text-[10px] text-purple-200 mt-1 text-right">
                                                    {{ new Date(reply.createdAt).toLocaleTimeString('th-TH', { hour: '2-digit', minute: '2-digit' }) }}
                                                </p>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="flex gap-2 pt-2 border-t border-purple-100">
                                        <input
                                            v-model="replyContent"
                                            type="text"
                                            placeholder="พิมพ์ข้อความตอบกลับ..."
                                            class="flex-1 text-sm border border-gray-200 rounded-full px-4 py-2 focus:outline-none focus:border-purple-400 bg-white"
                                            @keyup.enter="sendReply(trip, bookingMessages[trip.id]?.at(-1)?.id)" />
                                        <button
                                            @click="sendReply(trip, bookingMessages[trip.id]?.at(-1)?.id)"
                                            :disabled="isReplying || !replyContent.trim()"
                                            class="px-4 py-2 text-xs font-semibold text-white bg-purple-600 rounded-full hover:bg-purple-700 disabled:opacity-50 transition">
                                            ส่ง
                                        </button>
                                    </div>
                                </div>

                            </div>
                        </div>
                    </div>
                </div>

                <!-- แผนที่ -->
                <div class="lg:col-span-1">
                    <div class="sticky overflow-hidden bg-white border border-gray-300 rounded-lg shadow-md top-8">
                        <div class="p-6 border-b border-gray-300">
                            <h3 class="text-lg font-semibold text-gray-900">แผนที่เส้นทาง</h3>
                        </div>
                        <div ref="mapContainer" id="map" class="h-96"></div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Modal: เลือกเหตุผลการยกเลิก -->
        <div v-if="isCancelModalVisible" class="fixed inset-0 z-50 flex items-center justify-center bg-black/40"
            @click.self="closeCancelModal">
            <div class="w-full max-w-md p-6 bg-white rounded-lg shadow-xl">
                <h3 class="text-lg font-semibold text-gray-900">เลือกเหตุผลการยกเลิก</h3>
                <p class="mt-1 text-sm text-gray-600">โปรดเลือกเหตุผลตามตัวเลือกที่กำหนด</p>
                <div class="mt-4">
                    <label class="block mb-1 text-sm text-gray-700">เหตุผล</label>
                    <select v-model="selectedCancelReason" class="w-full px-3 py-2 border border-gray-300 rounded-md">
                        <option value="" disabled>-- เลือกเหตุผล --</option>
                        <option v-for="r in cancelReasonOptions" :key="r.value" :value="r.value">
                            {{ r.label }}
                        </option>
                    </select>
                    <p v-if="cancelReasonError" class="mt-2 text-sm text-red-600">{{ cancelReasonError }}</p>
                </div>
                <div class="flex justify-end gap-2 mt-6">
                    <button @click="closeCancelModal" class="px-4 py-2 text-sm text-gray-700 bg-gray-100 rounded-md hover:bg-gray-200">
                        ปิด
                    </button>
                    <button @click="submitCancel" :disabled="!selectedCancelReason || isSubmittingCancel"
                        class="px-4 py-2 text-sm text-white bg-red-600 rounded-md hover:bg-red-700 disabled:opacity-50">
                        {{ isSubmittingCancel ? 'กำลังส่ง...' : 'ยืนยันการยกเลิก' }}
                    </button>
                </div>
            </div>
        </div>

        <ConfirmModal :show="isModalVisible" :title="modalContent.title" :message="modalContent.message"
            :confirmText="modalContent.confirmText" :variant="modalContent.variant" @confirm="handleConfirmAction"
            @cancel="closeConfirmModal" />
    </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted, watch } from 'vue'
import dayjs from 'dayjs'
import 'dayjs/locale/th'
import buddhistEra from 'dayjs/plugin/buddhistEra'
import ConfirmModal from '~/components/ConfirmModal.vue'
import { useToast } from '~/composables/useToast'
import { usePushNotification } from '~/composables/usePushNotification'

dayjs.locale('th')
dayjs.extend(buddhistEra)

const { $api } = useNuxtApp()
const { toast } = useToast()

// --- State ---
const activeTab = ref('pending')
const selectedTripId = ref(null)
const isLoading = ref(false)
const mapContainer = ref(null)
const allTrips = ref([])
const isProcessing = ref(false)

let gmap = null
let activePolyline = null
let activePolylines = []
let startMarker = null
let endMarker = null
let geocoder = null
let placesService = null
let directionsService = null
let infoWindow = null
let stopMarkers = []
const mapReady = ref(false)
const GMAPS_CB = '__gmapsReady__'
let pollingInterval = null

// --- Messaging ---
const bookingMessages = ref({})
const msgPanelOpen = ref(null)
const replyContent = ref('')
const isReplying = ref(false)

// --- Cancel ---
const isCancelModalVisible = ref(false)
const isSubmittingCancel = ref(false)
const selectedCancelReason = ref('')
const cancelReasonError = ref('')
const tripToCancel = ref(null)

const { subscribe } = usePushNotification()

const tabs = [
    { status: 'pending', label: 'รอดำเนินการ' },
    { status: 'confirmed', label: 'ยืนยันแล้ว' },
    { status: 'rejected', label: 'ปฏิเสธ' },
    { status: 'cancelled', label: 'ยกเลิก' },
    { status: 'all', label: 'ทั้งหมด' }
]

definePageMeta({ middleware: 'auth' })

const cancelReasonOptions = [
    { value: 'CHANGE_OF_PLAN', label: 'เปลี่ยนแผน/มีธุระกะทันหัน' },
    { value: 'FOUND_ALTERNATIVE', label: 'พบวิธีเดินทางอื่นแล้ว' },
    { value: 'DRIVER_DELAY', label: 'คนขับล่าช้าหรือเลื่อนเวลา' },
    { value: 'PRICE_ISSUE', label: 'ราคาหรือค่าใช้จ่ายไม่เหมาะสม' },
    { value: 'WRONG_LOCATION', label: 'เลือกจุดรับ–ส่งผิด' },
    { value: 'DUPLICATE_OR_WRONG_DATE', label: 'จองซ้ำหรือจองผิดวัน' },
    { value: 'SAFETY_CONCERN', label: 'กังวลด้านความปลอดภัย' },
    { value: 'WEATHER_OR_FORCE_MAJEURE', label: 'สภาพอากาศ/เหตุสุดวิสัย' },
    { value: 'COMMUNICATION_ISSUE', label: 'สื่อสารไม่สะดวก/ติดต่อไม่ได้' }
]

// --- Helpers ---
const calculateDistance = (lat1, lon1, lat2, lon2) => {
    const R = 6371e3
    const dLat = (lat2 - lat1) * Math.PI / 180
    const dLon = (lon2 - lon1) * Math.PI / 180
    const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
        Math.sin(dLon / 2) * Math.sin(dLon / 2)
    return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
}

function cleanAddr(a) {
    return (a || '').replace(/,?\s*(Thailand|ไทย|ประเทศ)\s*$/i, '').replace(/\s{2,}/g, ' ').trim()
}

// --- Computed ---
const filteredTrips = computed(() => {
    if (activeTab.value === 'all') return allTrips.value
    return allTrips.value.filter(t => t.status === activeTab.value)
})

// นับจำนวนข้อความที่ยังไม่ได้อ่านสำหรับแต่ละทริป
const unreadMessages = computed(() => {
    const result = {}
    allTrips.value.forEach(trip => {
        const msgs = bookingMessages.value[trip.id] || []
        result[trip.id] = msgs.filter(m => !m.isRead).length
    })
    return result
})

// --- Timeline ---
const getRouteTimeline = (t) => {
    if (!t) return []
    const timeline = []
    timeline.push({ name: t.origin, address: t.originAddress, type: 'origin', isPassengerPoint: false })
    if (t.stopsCoords && Array.isArray(t.stopsCoords)) {
        t.stopsCoords.forEach(stop => {
            timeline.push({
                name: stop.name,
                address: stop.address,
                type: 'stop',
                isPassengerPoint: !!stop.isPassengerPoint,
                passengerName: stop.passengerName,
                actionType: stop.actionType,
                passengerList: stop.passengerList || []
            })
        })
    }
    timeline.push({ name: t.destination, address: t.destinationAddress, type: 'destination', isPassengerPoint: false })
    return timeline
}

// --- Messaging ---
// รับข้อความแจ้งเตือนจากคนขับ
onMounted(() => { subscribe() })

const openMessagePanel = async (trip) => {
    msgPanelOpen.value = msgPanelOpen.value === trip.id ? null : trip.id
    if (msgPanelOpen.value) {
        try {
            const res = await $api(`/messages/booking/${trip.id}`)
            bookingMessages.value = {
                ...bookingMessages.value,
                [trip.id]: Array.isArray(res) ? res : (res.data || [])
            }
        } catch (e) {
            console.error('โหลดข้อความไม่สำเร็จ:', e)
            toast.error('ไม่สามารถโหลดข้อความได้')
        }
    }
}

// ส่งข้อความตอบกลับคนขับ
const sendReply = async (trip, messageId) => {
    if (!replyContent.value.trim()) return
    isReplying.value = true
    try {
        await $api(`/messages/${messageId}/reply`, {
            method: 'POST',
            body: { content: replyContent.value }
        })
        replyContent.value = ''
        const res = await $api(`/messages/booking/${trip.id}`)
        bookingMessages.value = {
            ...bookingMessages.value,
            [trip.id]: Array.isArray(res) ? res : (res.data || [])
        }
        toast.success('ส่งข้อความแล้ว')
    } catch (e) {
        toast.error('เกิดข้อผิดพลาด')
    } finally {
        isReplying.value = false
    }
}

// --- Trip Actions ---
const handlePassengerStart = (trip) => {
    tripToAction.value = trip
    modalContent.value = {
        title: 'ยืนยันการเดินทาง',
        message: 'คุณขึ้นรถและพร้อมเดินทางแล้วใช่หรือไม่?',
        confirmText: 'ยืนยัน เริ่มต้นเดินทาง',
        action: 'passenger-start',
        variant: 'primary'
    }
    isModalVisible.value = true
}

const handlePassengerRejectPickup = (trip) => {
    tripToAction.value = trip
    modalContent.value = {
        title: 'ปฏิเสธการรับ',
        message: 'คุณต้องการปฏิเสธการรับจากคนขับใช่หรือไม่? คนขับจะได้รับแจ้งเตือน',
        confirmText: 'ยืนยัน ปฏิเสธการรับ',
        action: 'passenger-reject-pickup',
        variant: 'danger'
    }
    isModalVisible.value = true
}

const handlePassengerEndTrip = (trip) => {
    if (!trip.reachedDropoff) {
        toast.error('ยังไม่ถึงจุดหมาย', 'คนขับยังไม่ได้ถึงจุดหมายของคุณ กรุณารอสักครู่')
        return
    }
    tripToAction.value = trip
    modalContent.value = {
        title: 'สิ้นสุดการเดินทาง',
        message: 'คุณถึงจุดหมายและต้องการสิ้นสุดการเดินทางนี้ใช่หรือไม่?',
        confirmText: 'ยืนยัน สิ้นสุดการเดินทาง',
        action: 'passenger-end',
        variant: 'primary'
    }
    isModalVisible.value = true
}

const handlePassengerConfirmCancel = (trip) => {
    tripToAction.value = trip
    modalContent.value = {
        title: 'ยืนยันการยกเลิก',
        message: 'คุณยืนยันการยกเลิกการเดินทางนี้ใช่หรือไม่?',
        confirmText: 'ยืนยัน ยกเลิกการเดินทาง',
        action: 'passenger-confirm-cancel',
        variant: 'danger'
    }
    isModalVisible.value = true
}

const handlePassengerRejectCancel = (trip) => {
    tripToAction.value = trip
    modalContent.value = {
        title: 'ปฏิเสธการยกเลิก',
        message: 'คุณต้องการปฏิเสธคำขอยกเลิกจากคนขับใช่หรือไม่?',
        confirmText: 'ปฏิเสธการยกเลิก',
        action: 'passenger-reject-cancel',
        variant: 'primary'
    }
    isModalVisible.value = true
}

// --- Polling ---
const startPolling = () => {
    stopPolling()
    pollingInterval = setInterval(async () => {
        const hasActiveTrip = allTrips.value.some(t =>
            (t.tripStatus === 'IN_TRANSIT' || t.tripStatus === 'AVAILABLE' || t.tripStatus === 'FULL')
            && t.status === 'confirmed'
        )
        if (!hasActiveTrip) return

        try {
            const response = await $api('/bookings/trip-status')
            const data = response?.data || response
            if (!Array.isArray(data)) return

            let needFullRefresh = false

            data.forEach(b => {
                const trip = allTrips.value.find(t => t.id === b.id)
                if (!trip) return

                const hasChanged =
                    trip.passengerStatus !== b.passengerStatus ||
                    trip.driverCancelRequest !== b.driverCancelRequest ||
                    trip.reachedDropoff !== b.reachedDropoff ||
                    trip.currentStep !== (b.route?.currentStep ?? trip.currentStep) ||
                    trip.tripStatus !== (b.route?.status ?? trip.tripStatus)

                if (hasChanged) {
                    const oldStep = trip.currentStep

                    trip.passengerStatus = b.passengerStatus
                    trip.driverCancelRequest = b.driverCancelRequest
                    trip.reachedDropoff = b.reachedDropoff
                    trip.currentStep = b.route?.currentStep ?? trip.currentStep
                    trip.tripStatus = b.route?.status ?? trip.tripStatus

                    // ถ้า route COMPLETED และ dropoff ตรง destination → อัปเดต status เป็น ARRIVED
                    if (trip.tripStatus === 'COMPLETED' && trip.dropoffIsDestination) {
                        trip.passengerStatus = 'ARRIVED'
                    }

                    if (oldStep !== trip.currentStep && selectedTripId.value === trip.id) {
                        updateMap(trip)
                    }

                    if (['COMPLETED', 'CANCELLED'].includes(b.route?.status?.toUpperCase())) {
                        needFullRefresh = true
                    }
                }
            })

            if (needFullRefresh) await fetchMyTrips()

        } catch (e) {
            console.warn('Polling status sync failed:', e.message)
        }
    }, 15000)
}

const stopPolling = () => {
    if (pollingInterval) { clearInterval(pollingInterval); pollingInterval = null }
}

// --- Fetch ---
async function fetchMyTrips() {
    isLoading.value = true
    try {
        const bookings = await $api('/bookings/me')

        const formatted = (await Promise.all(bookings.map(async (b) => {
            const r = b.route
            if (!r) return null

            const start = r.startLocation
            const end = r.endLocation
            const originLatLng = { lat: Number(start.lat), lng: Number(start.lng) }

            const driverData = {
                name: `${r.driver?.firstName || ''} ${r.driver?.lastName || ''}`.trim(),
                image: r.driver?.profilePicture || `https://ui-avatars.com/api/?name=${encodeURIComponent(r.driver?.firstName || 'U')}&background=random&size=64`,
                rating: 4.5,
                reviews: Math.floor(Math.random() * 50) + 5
            }

            const carDetails = []
            if (r.vehicle) {
                carDetails.push(`${r.vehicle.vehicleModel} (${r.vehicle.vehicleType})`)
                if (Array.isArray(r.vehicle.amenities)) carDetails.push(...r.vehicle.amenities)
            } else {
                carDetails.push('ไม่มีข้อมูลรถ')
            }

            const wp = r.waypoints || {}
            const baseList = (Array.isArray(wp.used) && wp.used.length
                ? wp.used
                : Array.isArray(wp.requested) ? wp.requested : []) || []

            let allPotentialStops = [...baseList.map(p => ({ ...p, isOriginal: true }))]

            const myName = b.passenger?.firstName || b.user?.firstName || b.firstName || 'ฉัน'

            if (b.pickupLocation) {
                allPotentialStops.push({
                    lat: Number(b.pickupLocation.lat), lng: Number(b.pickupLocation.lng),
                    name: b.pickupLocation.name, address: b.pickupLocation.address,
                    isPassengerPoint: true, passengerName: myName, actionType: 'pickup'
                })
            }
            if (b.dropoffLocation) {
                allPotentialStops.push({
                    lat: Number(b.dropoffLocation.lat), lng: Number(b.dropoffLocation.lng),
                    name: b.dropoffLocation.name, address: b.dropoffLocation.address,
                    isPassengerPoint: true, passengerName: myName, actionType: 'dropoff'
                })
            }

            try {
                const routeDetail = await $api(`/routes/${r.id}`)
                const otherBookings = (routeDetail.bookings || []).filter(
                    bk => bk.status === 'CONFIRMED' && bk.id !== b.id
                )
                otherBookings.forEach(bk => {
                    const pName = bk.passenger?.firstName || 'ผู้โดยสาร'
                    if (bk.pickupLocation) {
                        allPotentialStops.push({
                            lat: Number(bk.pickupLocation.lat), lng: Number(bk.pickupLocation.lng),
                            name: bk.pickupLocation.name, address: bk.pickupLocation.address,
                            isPassengerPoint: true, passengerName: pName, actionType: 'pickup'
                        })
                    }
                    if (bk.dropoffLocation) {
                        allPotentialStops.push({
                            lat: Number(bk.dropoffLocation.lat), lng: Number(bk.dropoffLocation.lng),
                            name: bk.dropoffLocation.name, address: bk.dropoffLocation.address,
                            isPassengerPoint: true, passengerName: pName, actionType: 'dropoff'
                        })
                    }
                })
                r.currentStep = routeDetail.currentStep ?? r.currentStep ?? 0
                r.status = routeDetail.status ?? r.status
            } catch (e) {
                console.warn(`ไม่สามารถดึงข้อมูล route ${r.id}:`, e)
            }

            const filteredStops = []
            allPotentialStops.forEach(current => {
                const isAtStartOrEnd =
                    calculateDistance(current.lat, current.lng, start.lat, start.lng) < 15 ||
                    calculateDistance(current.lat, current.lng, end.lat, end.lng) < 15

                const existingIdx = filteredStops.findIndex(ex =>
                    calculateDistance(current.lat, current.lng, ex.lat, ex.lng) < 15
                )

                if (existingIdx > -1) {
                    if (current.isPassengerPoint) {
                        if (!filteredStops[existingIdx].passengerList) {
                            filteredStops[existingIdx].passengerList = []
                            if (filteredStops[existingIdx].passengerName) {
                                filteredStops[existingIdx].passengerList.push({
                                    name: filteredStops[existingIdx].passengerName,
                                    action: filteredStops[existingIdx].actionType
                                })
                            }
                        }
                        const alreadyIn = filteredStops[existingIdx].passengerList.some(
                            pl => pl.name === current.passengerName && pl.action === current.actionType
                        )
                        if (!alreadyIn) {
                            filteredStops[existingIdx].passengerList.push({
                                name: current.passengerName, action: current.actionType
                            })
                        }
                    }
                } else if (!isAtStartOrEnd) {
                    filteredStops.push({
                        ...current,
                        passengerList: current.isPassengerPoint
                            ? [{ name: current.passengerName, action: current.actionType }]
                            : null
                    })
                }
            })

            const sortedStops = filteredStops.sort((a, b) => {
                if (a.bookingId === b.bookingId && a.bookingId !== undefined) {
                    if (a.actionType === 'pickup' && b.actionType === 'dropoff') return -1
                    if (a.actionType === 'dropoff' && b.actionType === 'pickup') return 1
                }
                const distA = calculateDistance(originLatLng.lat, originLatLng.lng, a.lat, a.lng)
                const distB = calculateDistance(originLatLng.lat, originLatLng.lng, b.lat, b.lng)
                return distA - distB
            })

            const finalStopsNames = sortedStops.map(p => {
                if (p.passengerList && p.passengerList.length > 0) {
                    const names = p.passengerList
                        .map(pl => `${pl.action === 'pickup' ? 'รับ' : 'ส่ง'}คุณ ${pl.name}`)
                        .join(' และ ')
                    return `${p.name} (${names})`
                }
                return p.name || ''
            }).filter(Boolean)

            // เช็คว่า dropoff ของผู้โดยสารอยู่ที่ destination หรือเปล่า
            const dropoffLat = b.dropoffLocation ? Number(b.dropoffLocation.lat) : null
            const dropoffLng = b.dropoffLocation ? Number(b.dropoffLocation.lng) : null
            const destLat = Number(end.lat)
            const destLng = Number(end.lng)
            const dropoffIsDestination = dropoffLat !== null
                ? calculateDistance(dropoffLat, dropoffLng, destLat, destLng) < 15
                : true

            return {
                id: b.id,
                status: String(b.status || '').toLowerCase(),
                tripStatus: r.status,
                currentStep: r.currentStep || 0,
                passengerStatus: b.passengerStatus || null,
                driverCancelRequest: b.driverCancelRequest || false,
                reachedDropoff: b.reachedDropoff || false,
                dropoffIsDestination,
                origin: start?.name || 'ต้นทาง',
                destination: end?.name || 'ปลายทาง',
                originAddress: cleanAddr(start?.address),
                destinationAddress: cleanAddr(end?.address),
                originHasName: !!start?.name,
                destinationHasName: !!end?.name,
                pickupPoint: b.pickupLocation?.name || '-',
                date: dayjs(r.departureTime).format('D MMMM BBBB'),
                time: dayjs(r.departureTime).format('HH:mm น.'),
                seats: b.numberOfSeats || 1,
                price: (r.pricePerSeat || 0) * (b.numberOfSeats || 1),
                driver: driverData,
                coords: [[start.lat, start.lng], [end.lat, end.lng]],
                stops: finalStopsNames,
                stopsCoords: sortedStops,
                carDetails,
                conditions: r.conditions,
                photos: r.vehicle?.photos || [],
                durationText: (typeof r.duration === 'string' ? formatDuration(r.duration) : r.duration) || '-',
                distanceText: (typeof r.distance === 'string' ? formatDistance(r.distance) : r.distance) || '-'
            }
        }))).filter(Boolean)

        allTrips.value = formatted

        await waitMapReady()
        const jobs = allTrips.value.map(async (t, idx) => {
            if (!t.originHasName || !t.destinationHasName) {
                const [o, d] = await Promise.all([
                    reverseGeocode(t.coords[0][0], t.coords[0][1]),
                    reverseGeocode(t.coords[1][0], t.coords[1][1])
                ])
                const oParts = await extractNameParts(o)
                const dParts = await extractNameParts(d)
                if (!allTrips.value[idx].originHasName && oParts.name) allTrips.value[idx].origin = oParts.name
                if (!allTrips.value[idx].destinationHasName && dParts.name) allTrips.value[idx].destination = dParts.name
            }
        })
        await Promise.allSettled(jobs)

    } catch (error) {
        console.error('Failed to fetch my trips:', error)
        allTrips.value = []
    } finally {
        isLoading.value = false
    }
}

// --- Map ---
function waitMapReady() {
    return new Promise(resolve => {
        if (mapReady.value) return resolve(true)
        let count = 0
        const t = setInterval(() => {
            count++
            if (mapReady.value || count > 200) { clearInterval(t); resolve(true) }
        }, 50)
    })
}

function reverseGeocode(lat, lng) {
    return new Promise(resolve => {
        if (!geocoder) return resolve(null)
        geocoder.geocode({ location: { lat, lng } }, (results, status) => {
            if (status !== 'OK' || !results?.length) return resolve(null)
            resolve(results[0])
        })
    })
}

async function extractNameParts(geocodeResult) {
    if (!geocodeResult) return { name: null }
    const comps = geocodeResult.address_components || []
    const byType = t => comps.find(c => c.types.includes(t))?.long_name
    const types = geocodeResult.types || []
    const isPoi = types.includes('point_of_interest') || types.includes('establishment') || types.includes('premise')

    let name = null
    if (isPoi && geocodeResult.place_id) {
        const poiName = await getPlaceName(geocodeResult.place_id)
        if (poiName) name = poiName
    }
    if (!name) {
        const streetNumber = byType('street_number')
        const route = byType('route')
        name = streetNumber && route ? `${streetNumber} ${route}` : route || geocodeResult.formatted_address || null
    }
    if (name) name = name.replace(/,?\s*(Thailand|ไทย)\s*$/i, '')
    return { name }
}

function getPlaceName(placeId) {
    return new Promise(resolve => {
        if (!placesService || !placeId) return resolve(null)
        placesService.getDetails({ placeId, fields: ['name'] }, (place, status) => {
            if (status === google.maps.places.PlacesServiceStatus.OK && place?.name) resolve(place.name)
            else resolve(null)
        })
    })
}

const getTripCount = (status) => {
    if (status === 'all') return allTrips.value.length
    return allTrips.value.filter(t => t.status === status).length
}

const toggleTripDetails = (tripId) => {
    const tripForMap = allTrips.value.find(t => t.id === tripId)
    if (tripForMap) updateMap(tripForMap)
    selectedTripId.value = selectedTripId.value === tripId ? null : tripId
}

async function updateMap(trip) {
    if (!trip || !gmap) return
    await waitMapReady()
    if (!mapContainer.value || !document.body.contains(mapContainer.value)) return

    if (activePolyline) { activePolyline.setMap(null); activePolyline = null }
    if (activePolylines?.length) { activePolylines.forEach(p => p.setMap(null)); activePolylines = [] }
    if (startMarker) { startMarker.setMap(null); startMarker = null }
    if (endMarker) { endMarker.setMap(null); endMarker = null }
    stopMarkers.forEach(m => m.setMap(null)); stopMarkers = []
    if (infoWindow) infoWindow.close()
    else infoWindow = new google.maps.InfoWindow()

    if (!directionsService) directionsService = new google.maps.DirectionsService()

    const timeline = getRouteTimeline(trip)
    let originLatLng, destLatLng, prevIndex, targetIndex

    if (trip.tripStatus === 'IN_TRANSIT' && trip.currentStep > 0) {
        prevIndex = trip.currentStep - 1
        targetIndex = trip.currentStep
        originLatLng = getLatLngFromTimeline(trip, prevIndex)
        destLatLng = getLatLngFromTimeline(trip, targetIndex)
    } else {
        originLatLng = { lat: Number(trip.coords[0][0]), lng: Number(trip.coords[0][1]) }
        destLatLng = { lat: Number(trip.coords[1][0]), lng: Number(trip.coords[1][1]) }
        prevIndex = 0
        targetIndex = timeline.length - 1
    }

    if (!originLatLng || !destLatLng) return

    startMarker = new google.maps.Marker({
        position: originLatLng, map: gmap,
        label: { text: 'A', color: 'white' },
        title: timeline[prevIndex]?.name, zIndex: 100
    })

    endMarker = new google.maps.Marker({
        position: destLatLng, map: gmap,
        label: { text: 'B', color: 'white' },
        title: timeline[targetIndex]?.name, zIndex: 100
    })

    ;(trip.stopsCoords || []).forEach(s => {
        const m = new google.maps.Marker({
            position: { lat: Number(s.lat), lng: Number(s.lng) },
            map: gmap,
            icon: { path: google.maps.SymbolPath.CIRCLE, scale: 5, fillColor: '#3b82f6', fillOpacity: 1, strokeWeight: 2, strokeColor: 'white' },
            title: s.name
        })
        stopMarkers.push(m)
    })

    const baseRequest = {
        origin: originLatLng, destination: destLatLng,
        travelMode: google.maps.TravelMode.DRIVING,
        provideRouteAlternatives: true
    }

    try {
        const results = await Promise.allSettled([
            directionsService.route(baseRequest),
            directionsService.route({ ...baseRequest, avoidHighways: true })
        ])

        let mergedRoutes = []
        results.forEach(res => {
            if (res.status === 'fulfilled' && res.value.status === 'OK') {
                mergedRoutes.push(...res.value.routes)
            }
        })

        const uniqueRoutes = []
        const seenPolylines = new Set()
        mergedRoutes.forEach(route => {
            if (!seenPolylines.has(route.overview_polyline)) {
                seenPolylines.add(route.overview_polyline)
                uniqueRoutes.push(route)
            }
        })

        if (uniqueRoutes.length === 0) {
            activePolyline = new google.maps.Polyline({ path: [originLatLng, destLatLng], map: gmap, strokeColor: '#ef4444', strokeWeight: 4 })
            const bounds = new google.maps.LatLngBounds()
            bounds.extend(originLatLng); bounds.extend(destLatLng)
            gmap.fitBounds(bounds)
            return
        }

        const bounds = new google.maps.LatLngBounds()

        uniqueRoutes.forEach((route, index) => {
            const isPrimary = index === 0
            const polyline = new google.maps.Polyline({
                path: route.overview_path, map: gmap,
                strokeColor: isPrimary ? '#2563eb' : (route.warnings?.length ? '#d97706' : '#9ca3af'),
                strokeOpacity: isPrimary ? 1.0 : 0.6,
                strokeWeight: isPrimary ? 7 : 5,
                zIndex: isPrimary ? 100 : (50 - index),
                cursor: 'pointer'
            })
            activePolylines.push(polyline)

            google.maps.event.addListener(polyline, 'click', (e) => {
                const leg = route.legs[0]
                const warningMsg = route.warnings?.length ? `<br><span style="font-size:11px;color:#d97706">(${route.warnings.join(', ')})</span>` : ''
                infoWindow.setContent(`
                    <div style="text-align:center;padding:8px">
                        <p style="font-weight:bold;margin:0 0 4px">ทางเลือกที่ ${index + 1}</p>
                        <p style="font-weight:bold;color:#4f46e5;font-size:18px;margin:0">${leg.duration.text}</p>
                        <p style="color:#6b7280;font-size:12px;margin:4px 0">${leg.distance.text}${warningMsg}</p>
                        <a href="https://www.google.com/maps/dir/?api=1&origin=${originLatLng.lat},${originLatLng.lng}&destination=${destLatLng.lat},${destLatLng.lng}&travelmode=driving"
                           target="_blank" style="display:inline-block;padding:4px 12px;background:#2563eb;color:white;border-radius:4px;font-size:12px;text-decoration:none">
                           เปิด Google Maps ↗
                        </a>
                    </div>`)
                infoWindow.setPosition(e.latLng)
                infoWindow.open(gmap)
                activePolylines.forEach((p, i) => {
                    p.setOptions(i === index
                        ? { strokeColor: '#2563eb', zIndex: 100, strokeOpacity: 1.0 }
                        : { strokeColor: '#9ca3af', zIndex: 10, strokeOpacity: 0.5 })
                })
            })

            route.overview_path.forEach(p => bounds.extend(p))
        })

        gmap.fitBounds(bounds)

    } catch (error) {
        console.error('updateMap error:', error)
    }
}

function getLatLngFromTimeline(trip, index) {
    const timeline = getRouteTimeline(trip)
    const point = timeline[index]
    if (!point) return null
    if (point.type === 'origin') return { lat: Number(trip.coords[0][0]), lng: Number(trip.coords[0][1]) }
    if (point.type === 'destination') return { lat: Number(trip.coords[1][0]), lng: Number(trip.coords[1][1]) }
    const stopIndex = index - 1
    if (trip.stopsCoords?.[stopIndex]) {
        return { lat: Number(trip.stopsCoords[stopIndex].lat), lng: Number(trip.stopsCoords[stopIndex].lng) }
    }
    return null
}

// --- Modal ---
const isModalVisible = ref(false)
const tripToAction = ref(null)
const modalContent = ref({ title: '', message: '', confirmText: '', action: null, variant: 'danger' })

const openConfirmModal = (trip, action) => {
    tripToAction.value = trip
    if (action === 'delete') {
        modalContent.value = {
            title: 'ยืนยันการลบรายการ',
            message: `คุณต้องการลบรายการเดินทางไปที่ "${trip.destination}" ออกจากประวัติใช่หรือไม่?`,
            confirmText: 'ใช่, ลบรายการ',
            action: 'delete',
            variant: 'danger'
        }
    }
    isModalVisible.value = true
}

const closeConfirmModal = () => {
    isModalVisible.value = false
    tripToAction.value = null
}

const handleConfirmAction = async () => {
    if (!tripToAction.value) return
    const action = modalContent.value.action
    const tripId = tripToAction.value.id
    try {
        if (action === 'passenger-start') {
            await $api(`/bookings/${tripId}/passenger-start`, { method: 'PATCH' })
            toast.success('เริ่มต้นการเดินทางแล้ว', 'ขอให้เดินทางโดยสวัสดิภาพ')
        } else if (action === 'passenger-reject-pickup') {
            await $api(`/bookings/${tripId}/passenger-reject-pickup`, { method: 'PATCH' })
            toast.success('ส่งข้อความแจ้งคนขับแล้ว', 'กรุณาติดต่อคนขับโดยตรง')
        } else if (action === 'passenger-end') {
            await $api(`/bookings/${tripId}/passenger-status`, { method: 'PATCH', body: { status: 'ARRIVED' } })
            toast.success('สิ้นสุดการเดินทางแล้ว', 'ขอบคุณที่ใช้บริการ')
        } else if (action === 'passenger-confirm-cancel') {
            await $api(`/bookings/${tripId}/passenger-confirm-cancel`, { method: 'PATCH' })
            toast.success('ยืนยันการยกเลิกแล้ว', 'การเดินทางนี้ถูกยกเลิกแล้ว')
        } else if (action === 'passenger-reject-cancel') {
            await $api(`/bookings/${tripId}/passenger-reject-cancel`, { method: 'PATCH' })
            toast.success('ส่งข้อความแจ้งคนขับแล้ว', 'คนขับจะได้รับแจ้งเตือน')
        } else if (action === 'delete') {
            await $api(`/bookings/${tripId}`, { method: 'DELETE' })
            toast.success('ลบรายการสำเร็จ', 'รายการได้ถูกลบออกจากประวัติแล้ว')
        }
        closeConfirmModal()
        await fetchMyTrips()
    } catch (error) {
        console.error(`Failed to ${action} booking:`, error)
        toast.error('เกิดข้อผิดพลาด', error.data?.message || 'ไม่สามารถดำเนินการได้')
        closeConfirmModal()
    }
}

function openCancelModal(trip) {
    tripToCancel.value = trip
    selectedCancelReason.value = ''
    cancelReasonError.value = ''
    isCancelModalVisible.value = true
}

function closeCancelModal() {
    isCancelModalVisible.value = false
    tripToCancel.value = null
}

async function submitCancel() {
    if (!selectedCancelReason.value) { cancelReasonError.value = 'กรุณาเลือกเหตุผล'; return }
    if (!tripToCancel.value) return
    isSubmittingCancel.value = true
    try {
        await $api(`/bookings/${tripToCancel.value.id}/cancel`, {
            method: 'PATCH',
            body: { reason: selectedCancelReason.value }
        })
        toast.success('ยกเลิกการจองสำเร็จ', 'ระบบบันทึกเหตุผลแล้ว')
        closeCancelModal()
        await fetchMyTrips()
    } catch (err) {
        toast.error('เกิดข้อผิดพลาด', err?.data?.message || 'ไม่สามารถยกเลิกได้')
    } finally {
        isSubmittingCancel.value = false
    }
}

function formatDistance(input) {
    if (typeof input !== 'string') return input
    const parts = input.split('+')
    if (parts.length <= 1) return input
    let meters = 0
    for (const seg of parts) {
        const n = parseFloat(seg.replace(/[^\d.]/g, ''))
        if (Number.isNaN(n)) continue
        if (/กม/.test(seg)) meters += n * 1000
        else if (/เมตร|ม\./.test(seg)) meters += n
        else meters += n
    }
    if (meters >= 1000) {
        const km = Math.round((meters / 1000) * 10) / 10
        return `${km % 1 === 0 ? km.toFixed(0) : km} กม.`
    }
    return `${Math.round(meters)} ม.`
}

function formatDuration(input) {
    if (typeof input !== 'string') return input
    const parts = input.split('+')
    if (parts.length <= 1) return input
    let minutes = 0
    for (const seg of parts) {
        const n = parseFloat(seg.replace(/[^\d.]/g, ''))
        if (Number.isNaN(n)) continue
        if (/ชม/.test(seg)) minutes += n * 60
        else minutes += n
    }
    const h = Math.floor(minutes / 60)
    const m = Math.round(minutes % 60)
    return h ? (m ? `${h} ชม. ${m} นาที` : `${h} ชม.`) : `${m} นาที`
}

// --- Lifecycle ---
useHead({
    title: 'การเดินทางของฉัน - ไปนำแหน่',
    script: process.client && !window.google?.maps
        ? [{ key: 'gmaps', src: `https://maps.googleapis.com/maps/api/js?key=${useRuntimeConfig().public.googleMapsApiKey}&libraries=places,geometry&callback=__gmapsReady__`, async: true, defer: true }]
        : []
})

onMounted(() => {
    if (window.google?.maps) {
        initializeMap()
        fetchMyTrips().then(() => {
            if (filteredTrips.value.length) updateMap(filteredTrips.value[0])
            startPolling()
        })
        return
    }
    window[GMAPS_CB] = () => {
        try { delete window[GMAPS_CB] } catch {}
        initializeMap()
        fetchMyTrips().then(() => {
            if (filteredTrips.value.length) updateMap(filteredTrips.value[0])
            startPolling()
        })
    }
})

onUnmounted(() => {
    stopPolling()
    if (startMarker) { startMarker.setMap(null); startMarker = null }
    if (endMarker) { endMarker.setMap(null); endMarker = null }
    stopMarkers.forEach(m => m.setMap(null)); stopMarkers = []
    if (activePolyline) { activePolyline.setMap(null); activePolyline = null }
    if (activePolylines?.length) { activePolylines.forEach(p => p.setMap(null)); activePolylines = [] }
    if (infoWindow) { infoWindow.close(); infoWindow = null }
    if (gmap) { google.maps.event.clearInstanceListeners(gmap); gmap = null }
    if (window[GMAPS_CB]) { try { delete window[GMAPS_CB] } catch {} }
    mapReady.value = false
})

function initializeMap() {
    if (!mapContainer.value || gmap || !document.body.contains(mapContainer.value)) return
    gmap = new google.maps.Map(mapContainer.value, {
        center: { lat: 13.7563, lng: 100.5018 },
        zoom: 6,
        mapTypeControl: false,
        streetViewControl: false,
        fullscreenControl: true
    })
    geocoder = new google.maps.Geocoder()
    placesService = new google.maps.places.PlacesService(gmap)
    mapReady.value = true
}

watch(activeTab, () => {
    selectedTripId.value = null
    if (filteredTrips.value.length > 0) updateMap(filteredTrips.value[0])
})
</script>

<style scoped>
.trip-card { transition: all 0.3s ease; cursor: pointer; }
.trip-card:hover { box-shadow: 0 10px 25px rgba(59, 130, 246, 0.1); }

.tab-button { transition: all 0.3s ease; }
.tab-button.active { background-color: #3b82f6; color: white; box-shadow: 0 4px 14px rgba(59, 130, 246, 0.3); }
.tab-button:not(.active) { background-color: white; color: #6b7280; border: 1px solid #d1d5db; }
.tab-button:not(.active):hover { background-color: #f9fafb; color: #374151; }

#map { height: 100%; min-height: 600px; border-radius: 0 0 0.5rem 0.5rem; }

.status-badge { display: inline-flex; align-items: center; padding: 0.25rem 0.75rem; border-radius: 9999px; font-size: 0.875rem; font-weight: 500; }
.status-pending { background-color: #fef3c7; color: #d97706; }
.status-confirmed { background-color: #dbeafe; color: #1d4ed8; }
.status-rejected { background-color: #fee2e2; color: #dc2626; }
.status-cancelled { background-color: #f3f4f6; color: #6b7280; }

@keyframes slide-in-from-top {
    from { opacity: 0; transform: translateY(-10px); }
    to { opacity: 1; transform: translateY(0); }
}
.animate-in { animation-fill-mode: both; }
.slide-in-from-top { animation-name: slide-in-from-top; }
.duration-300 { animation-duration: 300ms; }
</style>