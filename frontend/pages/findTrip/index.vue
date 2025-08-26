<template>
    <div>
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
            <div class="bg-white  border border-gray-300 rounded-lg shadow-md p-6 mb-8">
                <h2 class="text-xl font-semibold text-gray-900 mb-6">ค้นหาการเดินทาง</h2>
                <form @submit.prevent="handleSearch" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-4">
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
                        <button type="submit"
                            class="w-full bg-blue-600 text-white py-2 px-4 rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 transition duration-200">
                            ค้นหา
                        </button>
                    </div>
                </form>
            </div>

            <div class="grid grid-cols-1 lg:grid-cols-3 gap-6 ">
                <div class="lg:col-span-2 ">
                    <div class="bg-white rounded-lg shadow-md border border-gray-300">
                        <div class="p-6 border-b border-gray-300">
                            <h3 class="text-lg font-semibold text-gray-900">ผลการค้นหา ({{ routes.length }} รายการ)</h3>
                        </div>
                        <div v-if="isLoading" class="p-6 text-center text-gray-500">
                            กำลังค้นหาเส้นทาง...
                        </div>
                        <div v-else class="divide-y divide-gray-200">
                            <div v-if="routes.length === 0" class="p-6 text-center text-gray-500">
                                ไม่พบเส้นทางที่ค้นหา
                            </div>
                            <div v-for="route in routes" :key="route.id"
                                class="route-card p-6 cursor-pointer transition-all duration-300 hover:shadow-lg"
                                @click="toggleDetails(route)">
                                <div class="flex items-start space-x-4">
                                    <img :src="route.driver.image" :alt="route.driver.name"
                                        class="w-12 h-12 rounded-full object-cover">
                                    <div class="flex-1">
                                        <div class="flex justify-between items-start">
                                            <div>
                                                <h3 class="font-semibold text-gray-900">จาก Lat: 16.39, Lng: 102.83 → ถึง Lat: 13.76, Lng: 100.50</h3>
                                                <h4 class="font-semibold text-gray-900">{{ route.driver.name }}</h4>
                                                <div class="flex items-center mt-1">
                                                    <div class="flex text-yellow-400">
                                                        <span v-for="star in 5" :key="star">{{ star <=
                                                            route.driver.rating ? '★' : '☆' }}</span>
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
                                            <div class="flex flex-wrap items-center text-sm text-gray-600">
                                                <span class="font-medium">{{ route.date }}</span>
                                                <span class="text-gray-300 mx-2">|</span>
                                                <span class="font-medium">เวลาออก:</span>
                                                <span class="ml-1">{{ route.departureTime }}</span>
                                                <span class="text-gray-300 mx-2">|</span>
                                                <span class="font-medium">ระยะเวลา:</span>
                                                <span class="ml-1">{{ route.duration }}</span>
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

                                <div v-if="selectedRoute && selectedRoute.id === route.id"
                                    class="mt-4 pt-4 border-t border-gray-300 animate-in slide-in-from-top duration-300">
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
                                    <div class="mt-4 space-y-4">
                                        <div v-if="route.conditions">
                                            <h5 class="font-medium text-gray-900 mb-2">เงื่อนไขการเดินทาง</h5>
                                            <p
                                                class="text-sm text-gray-700 bg-gray-50 p-3 rounded-md border border-gray-300">
                                                {{ route.conditions }}
                                            </p>
                                        </div>
                                        <div v-if="route.photos && route.photos.length > 0">
                                            <h5 class="font-medium text-gray-900 mb-2">รูปภาพรถยนต์</h5>
                                            <div class="grid grid-cols-3 gap-2 mt-2 ">
                                                <div v-for="(photo, index) in route.photos.slice(0, 3)" :key="index"
                                                    class="">
                                                    <img :src="photo" alt="Vehicle photo"
                                                        class="w-full aspect-video object-cover border border-gray-300 rounded-lg shadow-sm cursor-pointer hover:opacity-90 transition-opacity">
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="mt-4 flex justify-end">
                                        <button @click.stop="openModal(route)" :disabled="route.availableSeats === 0"
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
                    <div class="bg-white rounded-lg shadow-md overflow-hidden sticky top-8 border border-gray-300">
                        <div class="p-6 border-b border-gray-300">
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
                    <div class="flex justify-between items-center p-6 border-b border-gray-300">
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
                                    {{ bookingRoute.date }}
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
                                    <div class="font-medium text-gray-900">{{ bookingRoute.origin }}</div>
                                    <div class="text-sm text-gray-600">จุดเริ่มต้น</div>
                                </div>
                                <div class="text-blue-600">
                                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                            d="M9 5l7 7-7 7"></path>
                                    </svg>
                                </div>
                                <div class="flex-1 text-right">
                                    <div class="font-medium text-gray-900">{{ bookingRoute.destination }}</div>
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
                            <div class="border-t pt-2 mt-2 border-gray-300">
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
import dayjs from 'dayjs'
import 'dayjs/locale/th'
import buddhistEra from 'dayjs/plugin/buddhistEra'
import { useToast } from '~/composables/useToast';
import { useAuth } from '~/composables/useAuth';
import { navigateTo } from '#app';

dayjs.locale('th')
dayjs.extend(buddhistEra)

const { $api } = useNuxtApp()
const { toast } = useToast();
const { token } = useAuth();

useHead({
    title: 'ค้นหาเส้นทาง - Car Pool',
    link: [
        { rel: 'stylesheet', href: 'https://fonts.googleapis.com/css2?family=Kanit:wght@300;400;500;600;700&display=swap' },
        { rel: 'stylesheet', href: 'https://unpkg.com/leaflet@1.7.1/dist/leaflet.css' }
    ],
    script: [
        {
            src: 'https://unpkg.com/leaflet@1.7.1/dist/leaflet.js',
            defer: true,
            onload: () => {
                nextTick(() => {
                    initializeMap()
                })
            }
        }
    ]
})

const searchForm = ref({
    origin: '',
    destination: '',
    date: '',
    seats: '1'
})

const routes = ref([])
const selectedRoute = ref(null)
const isLoading = ref(false)

const mapContainer = ref(null)
let map = null

const showModal = ref(false)
const bookingRoute = ref(null)
const bookingSeats = ref(1)
const pickupPoint = ref('')
const dropoffPoint = ref('')

const bookingTotalPrice = computed(() => {
    if (!bookingRoute.value) return 0
    return bookingSeats.value * bookingRoute.value.price
})

async function handleSearch() {
    isLoading.value = true
    selectedRoute.value = null

    try {
        const apiResponse = await $api('/routes', {
            // params: searchForm.value 
        })

        const formattedRoutes = apiResponse
            .filter(route => route.status === 'AVAILABLE')
            .map(route => {

                const driverData = {
                    name: `${route.driver.firstName} ${route.driver.lastName}`,
                    image: route.driver.profilePicture || `https://ui-avatars.com/api/?name=${route.driver.firstName}&background=random&size=64`,
                    rating: 4.5,
                    reviews: Math.floor(Math.random() * 50) + 5,
                };

                const carDetailsList = [];
                if (route.vehicle) {
                    carDetailsList.push(`${route.vehicle.vehicleModel} (${route.vehicle.vehicleType})`);
                    if (route.vehicle.amenities && route.vehicle.amenities.length > 0) {
                        carDetailsList.push(...route.vehicle.amenities);
                    }
                } else {
                    carDetailsList.push('ไม่มีข้อมูลรถ');
                }

                return {
                    id: route.id,
                    availableSeats: route.availableSeats,
                    price: route.pricePerSeat,
                    departureTime: dayjs(route.departureTime).format('HH:mm น.'),
                    date: dayjs(route.departureTime).format('D MMMM BBBB'),
                    origin: `จาก Lat: ${route.startLocation.lat.toFixed(2)}, Lng: ${route.startLocation.lng.toFixed(2)}`,
                    destination: `ถึง Lat: ${route.endLocation.lat.toFixed(2)}, Lng: ${route.endLocation.lng.toFixed(2)}`,
                    driver: driverData,
                    carDetails: carDetailsList,
                    conditions: route.conditions,
                    photos: route.vehicle?.photos,
                    stops: ['จุดแวะพัก (รอข้อมูล)'],
                    duration: route.duration || 'ประมาณ 8 ชั่วโมง',
                    coordinates: [
                        [route.startLocation.lat, route.startLocation.lng],
                        [route.endLocation.lat, route.endLocation.lng]
                    ]
                }
            })

        routes.value = formattedRoutes

    } catch (error) {
        console.error("Failed to fetch routes:", error)
        routes.value = []
    } finally {
        isLoading.value = false
    }
}

// [UPDATED] Removed the call to updateMapForRoute
const toggleDetails = (route) => {
    if (selectedRoute.value && selectedRoute.value.id === route.id) {
        selectedRoute.value = null
    } else {
        selectedRoute.value = route
        // updateMapForRoute(route) // <-- We don't call this anymore
    }
}

function openModal(route) {
    if (!token.value) {
        return navigateTo('/login');
    }
    
    if (route && route.availableSeats > 0) {
        bookingRoute.value = route
        bookingSeats.value = 1
        pickupPoint.value = ''
        dropoffPoint.value = ''
        showModal.value = true
    }
}

function closeModal() {
    showModal.value = false
    setTimeout(() => {
        bookingRoute.value = null
    }, 300);
}

async function confirmBooking() {
    if (!bookingRoute.value) return;

    if (!pickupPoint.value.trim() || !dropoffPoint.value.trim()) {
        toast.warning('ข้อมูลไม่ครบถ้วน', 'กรุณากรอกข้อมูลจุดรับและจุดส่งให้ครบถ้วน');
        return;
    }

    const payload = {
        routeId: bookingRoute.value.id,
        numberOfSeats: bookingSeats.value,
        pickupLocation: {
            name: pickupPoint.value,
            lat: 16.432, // TODO: Replace with actual Lat
            lng: 102.833  // TODO: Replace with actual Lng
        },
        dropoffLocation: {
            name: dropoffPoint.value,
            lat: 16.456, // TODO: Replace with actual Lat
            lng: 102.876  // TODO: Replace with actual Lng
        }
    };

    try {
        await $api('/bookings', {
            method: 'POST',
            body: payload
        });

        closeModal();

        toast.success(
            'ส่งคำขอจองสำเร็จ!',
            'คำขอของคุณถูกส่งไปให้ผู้ขับแล้ว โปรดรอการยืนยัน'
        );

        // Redirect to My Trips page after a short delay
        setTimeout(() => {
            navigateTo('/myTrip');
        }, 1500);

    } catch (error) {
        console.error("Failed to create booking:", error);
        toast.error(
            'เกิดข้อผิดพลาดในการจอง',
            error.data?.message || 'โปรดลองใหม่อีกครั้งในภายหลัง'
        );
    }
}

const initializeMap = () => {
    if (typeof L === 'undefined' || !mapContainer.value || map) return

    try {
        map = L.map(mapContainer.value).setView([13.7563, 100.5018], 6) // Centered on Bangkok, zoomed out
        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            attribution: '© OpenStreetMap contributors'
        }).addTo(map)
    } catch (error) {
        console.error('Error initializing map:', error)
    }
}

onMounted(() => {
    if (window.L) {
        initializeMap();
    }
    handleSearch();
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