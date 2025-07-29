<template>
    <div class="bg-gray-50 min-h-screen">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
            <div class="bg-white rounded-lg shadow-md p-6 mb-8">
                <h2 class="text-xl font-semibold text-gray-900 mb-6">ค้นหาการเดินทาง</h2>
                <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-4">
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-2">จุดเริ่มต้น</label>
                        <input v-model="searchForm.origin" type="text" placeholder="เช่น กรุงเทพฯ"
                            class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent">
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-2">จุดปลายทาง</label>
                        <input v-model="searchForm.destination" type="text" placeholder="เช่น เชียงใหม่"
                            class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent">
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-2">วันที่</label>
                        <input v-model="searchForm.date" type="date"
                            class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent">
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-2">จำนวนที่นั่ง</label>
                        <select v-model="searchForm.seats"
                            class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent">
                            <option value="1">1 ที่นั่ง</option>
                            <option value="2">2 ที่นั่ง</option>
                            <option value="3">3 ที่นั่ง</option>
                            <option value="4">4 ที่นั่ง</option>
                        </select>
                    </div>
                    <div class="flex items-end">
                        <button
                            class="w-full bg-blue-600 text-white py-2 px-4 rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 transition duration-200">
                            ค้นหา
                        </button>
                    </div>
                </div>
            </div>

            <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
                <div class="lg:col-span-2">
                    <div class="bg-white rounded-lg shadow-md">
                        <div class="p-6 border-b border-gray-200">
                            <h3 class="text-lg font-semibold text-gray-900">ผลการค้นหา ({{ routes.length }} รายการ)</h3>
                        </div>
                        <div class="divide-y divide-gray-200">
                            <div v-for="route in routes" :key="route.id" :class="['route-card p-6 cursor-pointer transition-all duration-300 hover:shadow-lg',
                                { 'border-2 border-blue-500 bg-blue-50': selectedRoute === route.id }]"
                                @click="toggleDetails(route.id)">
                                <div class="flex items-start space-x-4">
                                    <img :src="route.driver.image" :alt="route.driver.name"
                                        class="w-12 h-12 rounded-full object-cover">
                                    <div class="flex-1">
                                        <div class="flex justify-between items-start">
                                            <div>
                                                <h4 class="font-semibold text-gray-900">{{ route.driver.name }}</h4>
                                                <div class="flex items-center mt-1">
                                                    <div class="flex text-yellow-400">
                                                        <span v-for="star in 5" :key="star">
                                                            {{ star <= route.driver.rating ? '★' : '☆' }} </span>
                                                    </div>
                                                    <span class="ml-2 text-sm text-gray-600">
                                                        {{ route.driver.rating }} ({{ route.driver.reviews }} รีวิว)
                                                    </span>
                                                </div>
                                            </div>
                                            <div class="text-right">
                                                <div class="text-lg font-bold text-blue-600">{{ route.price }} บาท</div>
                                                <div class="text-sm text-gray-600">ต่อที่นั่ง</div>
                                            </div>
                                        </div>
                                        <div class="mt-3">
                                            <div class="flex items-center text-sm text-gray-600">
                                                <span class="font-medium">เวลาออก:</span>
                                                <span class="ml-2">{{ route.departureTime }}</span>
                                                <span class="ml-4 font-medium">ระยะเวลา:</span>
                                                <span class="ml-2">{{ route.duration }}</span>
                                            </div>
                                            <div class="flex items-center mt-2 text-sm text-gray-600">
                                                <span :class="[
                                                    'px-2 py-1 rounded-full text-xs font-medium',
                                                    route.availableSeats > 2 ? 'bg-green-100 text-green-800' : route.availableSeats > 0 ? 'bg-yellow-100 text-yellow-800' : 'bg-red-100 text-red-800'
                                                ]">
                                                    {{ route.availableSeats > 0 ? `เหลือ ${route.availableSeats}
                                                    ที่นั่ง` : 'เต็มแล้ว' }}
                                                </span>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <div v-if="selectedRoute === route.id"
                                    class="mt-4 pt-4 border-t border-gray-200 animate-in slide-in-from-top duration-300">
                                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                                        <div>
                                            <h5 class="font-medium text-gray-900 mb-2">รายละเอียดเส้นทาง</h5>
                                            <ul class="text-sm text-gray-600 space-y-1">
                                                <li v-for="stop in route.stops" :key="stop">• {{ stop }}</li>
                                            </ul>
                                        </div>
                                        <div>
                                            <h5 class="font-medium text-gray-900 mb-2">รายละเอียดรถ</h5>
                                            <ul class="text-sm text-gray-600 space-y-1">
                                                <li v-for="detail in route.carDetails" :key="detail">• {{ detail }}</li>
                                            </ul>
                                        </div>
                                    </div>
                                    <div class="mt-4 flex justify-end">
                                        <button @click="openModal" :disabled="route.availableSeats === 0"
                                            class="bg-blue-600 text-white px-6 py-2 rounded-md hover:bg-blue-700 transition duration-200 disabled:bg-gray-400 disabled:cursor-not-allowed">
                                            จองที่นั่ง
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="lg:col-span-1">
                    <div class="bg-white rounded-lg shadow-md overflow-hidden sticky top-8">
                        <div class="p-6 border-b border-gray-200">
                            <h3 class="text-lg font-semibold text-gray-900">แผนที่เส้นทาง</h3>
                        </div>
                        <div ref="mapContainer" class="h-96"></div>
                    </div>
                </div>
            </div>
        </div>

        <transition name="modal-fade">
            <div v-if="showModal && bookingRoute" class="modal-overlay" @click.self="closeModal">
                <div class="modal-content">
                    <div class="flex justify-between items-center p-6 border-b border-gray-200">
                        <h3 class="text-xl font-semibold text-gray-900">ยืนยันการจอง</h3>
                        <button @click="closeModal" class="text-gray-400 hover:text-gray-600">
                            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                    d="M6 18L18 6M6 6l12 12"></path>
                            </svg>
                        </button>
                    </div>

                    <div class="p-6">
                        <div class="mb-6">
                            <h4 class="font-semibold text-gray-900 mb-3">เดินทางกับ</h4>
                            <div class="flex items-center space-x-3 p-3 bg-gray-50 rounded-lg">
                                <img :src="bookingRoute.driver.image" :alt="bookingRoute.driver.name"
                                    class="w-12 h-12 rounded-full object-cover">
                                <div>
                                    <div class="font-medium text-gray-900">{{ bookingRoute.driver.name }}</div>
                                    <div class="flex items-center">
                                        <div class="flex text-yellow-400 text-sm">
                                            <span v-for="star in 5" :key="star">{{ star <= bookingRoute.driver.rating
                                                ? '★' : '☆' }}</span>
                                        </div>
                                        <span class="ml-2 text-sm text-gray-600">{{ bookingRoute.driver.rating }} ({{
                                            bookingRoute.driver.reviews }} รีวิว)</span>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-2">วันที่เดินทาง</label>
                                <div class="p-3 bg-gray-50 rounded-lg text-gray-900">
                                    อังคารที่ 29 กรกฎาคม 2568
                                </div>
                            </div>
                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-2">เวลาออก</label>
                                <div class="p-3 bg-gray-50 rounded-lg text-gray-900">
                                    {{ bookingRoute.departureTime }}
                                </div>
                            </div>
                        </div>

                        <div class="mb-6">
                            <h4 class="font-semibold text-gray-900 mb-3">เส้นทางการเดินทาง</h4>
                            <div class="flex items-center space-x-4 p-3 bg-gray-50 rounded-lg">
                                <div class="flex-1">
                                    <div class="font-medium text-gray-900">กรุงเทพมหานคร</div>
                                    <div class="text-sm text-gray-600">จุดเริ่มต้น</div>
                                </div>
                                <div class="text-blue-600">
                                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                            d="M9 5l7 7-7 7"></path>
                                    </svg>
                                </div>
                                <div class="flex-1 text-right">
                                    <div class="font-medium text-gray-900">เชียงใหม่</div>
                                    <div class="text-sm text-gray-600">จุดปลายทาง</div>
                                </div>
                            </div>
                        </div>

                        <div class="space-y-4 mb-6">
                            <div>
                                <label
                                    class="block text-sm font-medium text-gray-700 mb-2">จำนวนที่นั่งที่ต้องการจอง</label>
                                <select v-model="bookingSeats"
                                    class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent">
                                    <option v-for="seat in bookingRoute.availableSeats" :key="seat" :value="seat">
                                        {{ seat }} ที่นั่ง
                                    </option>
                                </select>
                            </div>

                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-2">เลือกจุดขึ้นรถ</label>
                                <input type="text" v-model="pickupPoint" placeholder="กรอกเพื่อค้นหาจุดขึ้นรถ..."
                                    class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent" />
                            </div>

                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-2">เลือกจุดลงรถ</label>
                                <input type="text" v-model="dropoffPoint" placeholder="กรอกเพื่อค้นหาจุดลงรถ..."
                                    class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent" />
                            </div>
                        </div>

                        <div class="bg-blue-50 p-4 rounded-lg mb-6">
                            <div class="flex justify-between items-center mb-2">
                                <span class="text-gray-700">ราคาต่อที่นั่ง</span>
                                <span class="text-gray-900 font-medium">{{ bookingRoute.price }} บาท</span>
                            </div>
                            <div class="flex justify-between items-center mb-2">
                                <span class="text-gray-700">จำนวนที่นั่ง</span>
                                <span class="text-gray-900 font-medium">{{ bookingSeats }} ที่นั่ง</span>
                            </div>
                            <div class="border-t pt-2 mt-2  border-gray-200">
                                <div class="flex justify-between items-center">
                                    <span class="font-semibold text-gray-900">ยอดรวม</span>
                                    <span class="font-bold text-blue-600 text-lg">{{ bookingTotalPrice }} บาท</span>
                                </div>
                            </div>
                        </div>

                        <div class="flex space-x-4">
                            <button @click="closeModal"
                                class="flex-1 bg-gray-200 text-gray-800 py-3 px-4 rounded-md hover:bg-gray-300 transition duration-200 font-semibold">
                                ยกเลิก
                            </button>
                            <button @click="confirmBooking"
                                class="flex-1 bg-blue-600 text-white py-3 px-4 rounded-md hover:bg-blue-700 transition duration-200 font-semibold">
                                ยืนยันการจอง
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </transition>
    </div>
</template>

<script setup>
import { ref, computed, onMounted, nextTick } from 'vue'

// Head configuration for Nuxt
useHead({
    title: 'ค้นหาเส้นทาง - Car Pool',
    link: [
        { rel: 'stylesheet', href: 'https://fonts.googleapis.com/css2?family=Kanit:wght@300;400;500;600;700&display=swap' },
        { rel: 'stylesheet', href: 'https://unpkg.com/leaflet@1.7.1/dist/leaflet.css' }
    ],
    script: [
        {
            src: 'https://unpkg.com/leaflet@1.7.1/dist/leaflet.js',
            defer: true, // Use defer for better loading performance
            onload: () => {
                // Ensure map initializes after DOM is ready
                nextTick(() => {
                    initializeMap()
                })
            }
        }
    ]
})

// --- Reactive Data ---
const searchForm = ref({
    origin: '',
    destination: '',
    date: '',
    seats: '1'
})

const selectedRoute = ref(null)
const mapContainer = ref(null)
let map = null

const routes = ref([
    {
        id: 1, driver: { name: 'สมชาย ใจดี', image: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=60&h=60&fit=crop&crop=face', rating: 4.8, reviews: 25 }, price: 250, departureTime: '08:00 น.', duration: '6 ชั่วโมง 30 นาที', availableSeats: 2, stops: ['จุดแวะ: ปั้มบางปะอิน', 'จุดแวะ: ร้านอาหารสระบุรี', 'จุดแวะ: ปั้มโคราช'], carDetails: ['Toyota Camry สีดำ', 'ทะเบียน: กก 1234', 'เครื่องปรับอากาศ', 'ไม่สูบบุหรี่']
    },
    {
        id: 2, driver: { name: 'วรรณา สุขใจ', image: 'https://images.unsplash.com/photo-1494790108755-2616b2dc0a48?w=60&h=60&fit=crop&crop=face', rating: 4.5, reviews: 18 }, price: 280, departureTime: '10:30 น.', duration: '6 ชั่วโมง', availableSeats: 3, stops: ['จุดแวะ: ปั้มบางปะอิน', 'จุดแวะ: ห้างสระบุรี'], carDetails: ['Honda Civic สีขาว', 'ทะเบียน: ขข 5678', 'เครื่องปรับอากาศ', 'อนุญาตสูบบุหรี่']
    },
    {
        id: 3, driver: { name: 'อนุชา รักเดินทาง', image: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=60&h=60&fit=crop&crop=face', rating: 4.9, reviews: 42 }, price: 300, departureTime: '14:00 น.', duration: '5 ชั่วโมง 45 นาที', availableSeats: 0, stops: ['จุดแวะ: ร้านกาแฟอยุธยา', 'จุดแวะ: ตลาดโบราณลพบุรี', 'จุดแวะ: วิวจุดพักร้อย'], carDetails: ['BMW 320i สีเทา', 'ทะเบียน: คค 9999', 'เครื่องปรับอากาศ', 'ไม่สูบบุหรี่', 'มี Wi-Fi']
    }
])

// --- Modal State ---
const showModal = ref(false)
const bookingRoute = ref(null) // To store the data of the route being booked
const bookingSeats = ref(1)   // To store the number of seats selected in the modal

const pickupPoint = ref('') 
const dropoffPoint = ref('')

const bookingTotalPrice = computed(() => {
    if (!bookingRoute.value) return 0
    return bookingSeats.value * bookingRoute.value.price
})

function openModal() {
    const routeData = routes.value.find(r => r.id === selectedRoute.value)
    if (routeData && routeData.availableSeats > 0) {
        bookingRoute.value = routeData
        bookingSeats.value = 1
        
        // ✨ เพิ่ม 2 บรรทัดนี้เพื่อเคลียร์ค่าเก่าทุกครั้งที่เปิด Modal
        pickupPoint.value = ''
        dropoffPoint.value = ''

        showModal.value = true
    }
}

// --- Methods ---
const toggleDetails = (routeId) => {
    if (selectedRoute.value === routeId) {
        selectedRoute.value = null
    } else {
        selectedRoute.value = routeId
        updateMapForRoute(routeId)
    }
}

const initializeMap = () => {
    if (typeof L === 'undefined' || !mapContainer.value || map) return

    try {
        map = L.map(mapContainer.value).setView([16.0, 101.0], 6) // Centered on Thailand

        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            attribution: '© OpenStreetMap contributors'
        }).addTo(map)

        // Initial markers (optional)
        L.marker([13.7563, 100.5018]).addTo(map).bindPopup('กรุงเทพมหานคร')
        L.marker([18.7883, 98.9853]).addTo(map).bindPopup('เชียงใหม่')
    } catch (error) {
        console.error('Error initializing map:', error)
    }
}

const updateMapForRoute = (routeId) => {
    if (!map) return

    map.eachLayer(layer => {
        if (layer instanceof L.Polyline) {
            map.removeLayer(layer)
        }
    })

    const routeCoords = [[13.7563, 100.5018], [14.3532, 100.5691], [18.7883, 98.9853]]
    const polyline = L.polyline(routeCoords, { color: '#3b82f6', weight: 5 }).addTo(map)
    map.fitBounds(polyline.getBounds(), { padding: [30, 30] })
}



function closeModal() {
    showModal.value = false
    // Optional: delay resetting data for smoother closing animation
    setTimeout(() => {
        bookingRoute.value = null
    }, 300);
}



// Ensure map is initialized on mount if Leaflet is already loaded
onMounted(() => {
    if (window.L) {
        initializeMap();
    }
});
</script>

<style scoped>
body,
* {
    font-family: 'Kanit', sans-serif;
}

.route-card:hover {
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
    transform: translateY(-2px);
}

@keyframes slide-in-from-top {
    from {
        opacity: 0;
        transform: translateY(-10px);
    }

    to {
        opacity: 1;
        transform: translateY(0);
    }
}

.animate-in {
    animation-fill-mode: both;
}

.slide-in-from-top {
    animation-name: slide-in-from-top;
}

.duration-300 {
    animation-duration: 300ms;
}

/* New Modal Styles */
.modal-overlay {
    position: fixed;
    z-index: 1000;
    left: 0;
    top: 0;
    width: 100%;
    height: 100%;
    background-color: rgba(0, 0, 0, 0.6);
    display: flex;
    align-items: center;
    justify-content: center;
}

.modal-content {
    background-color: white;
    border-radius: 0.75rem;
    max-width: 600px;
    width: 95%;
    max-height: 90vh;
    overflow-y: auto;
    box-shadow: 0 20px 25px -5px rgb(0 0 0 / 0.1), 0 8px 10px -6px rgb(0 0 0 / 0.1);
}

/* Transition classes */
.modal-fade-enter-active,
.modal-fade-leave-active {
    transition: opacity 0.3s cubic-bezier(0.52, 0.02, 0.19, 1.02);
}

.modal-fade-enter-active .modal-content,
.modal-fade-leave-active .modal-content {
    transition: all 0.3s cubic-bezier(0.52, 0.02, 0.19, 1.02);
}

.modal-fade-enter-from,
.modal-fade-leave-to {
    opacity: 0;
}

.modal-fade-enter-from .modal-content,
.modal-fade-leave-to .modal-content {
    transform: scale(0.9) translateY(1rem);
}
</style>