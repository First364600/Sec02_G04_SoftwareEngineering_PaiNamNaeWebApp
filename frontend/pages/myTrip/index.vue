<template>
    <div class="bg-gray-50">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
            <!-- Page Title -->
            <div class="mb-8">
                <h2 class="text-2xl font-bold text-gray-900">การเดินทางของฉัน</h2>
                <p class="mt-2 text-gray-600">จัดการและติดตามการเดินทางทั้งหมดของคุณ</p>
            </div>

            <!-- Tabs Filter -->
            <div class="bg-white rounded-lg shadow-md p-6 mb-8">
                <div class="flex flex-wrap gap-2">
                    <button v-for="tab in tabs" :key="tab.status" @click="activeTab = tab.status"
                        :class="['tab-button px-4 py-2 rounded-md font-medium', { 'active': activeTab === tab.status }]">
                        {{ tab.label }} ({{ getTripCount(tab.status) }})
                    </button>
                </div>
            </div>

            <!-- Main Content Grid -->
            <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
                <!-- Left Side - Trips List (2/3) -->
                <div class="lg:col-span-2">
                    <div class="bg-white rounded-lg shadow-md">
                        <div class="p-6 border-b border-gray-200">
                            <h3 class="text-lg font-semibold text-gray-900">รายการการเดินทาง</h3>
                        </div>
                        <div class="divide-y divide-gray-200">
                            <!-- Trip Items -->
                            <div v-for="trip in filteredTrips" :key="trip.id" @click="selectTrip(trip.id)"
                                :class="['trip-card p-6', { 'selected': selectedTripId === trip.id }]">

                                <div class="flex items-start justify-between mb-4">
                                    <div class="flex-1">
                                        <div class="flex items-center justify-between">
                                            <h4 class="font-semibold text-gray-900 text-lg">{{ trip.origin }} → {{
                                                trip.destination }}</h4>
                                            <!-- 📍 แก้ไข: เปลี่ยนมาใช้ v-if เพื่อแสดงสถานะ -->
                                            <span v-if="trip.status === 'pending'"
                                                class="status-badge status-pending">รอดำเนินการ</span>
                                            <span v-else-if="trip.status === 'confirmed'"
                                                class="status-badge status-confirmed">ยืนยันแล้ว</span>
                                            <span v-else-if="trip.status === 'rejected'"
                                                class="status-badge status-rejected">ปฏิเสธ</span>
                                            <span v-else-if="trip.status === 'cancelled'"
                                                class="status-badge status-cancelled">ยกเลิก</span>
                                        </div>
                                        <p class="text-sm text-gray-600 mt-1">จุดนัดพบ: {{ trip.pickupPoint }}</p>
                                        <p class="text-sm text-gray-600">วันที่: {{ trip.date }} เวลา: {{ trip.time }}
                                        </p>
                                    </div>
                                </div>

                                <!-- Driver Info -->
                                <div class="flex items-center space-x-4 mb-4">
                                    <img :src="trip.driver.image" :alt="trip.driver.name"
                                        class="w-12 h-12 rounded-full object-cover">
                                    <div class="flex-1">
                                        <h5 class="font-medium text-gray-900">{{ trip.driver.name }}</h5>
                                        <div class="flex items-center">
                                            <div class="flex text-yellow-400 text-sm">
                                                <span>{{ '★'.repeat(Math.round(trip.driver.rating)) }}{{ '☆'.repeat(5 -
                                                    Math.round(trip.driver.rating)) }}</span>
                                            </div>
                                            <span class="ml-2 text-sm text-gray-600">{{ trip.driver.rating }} ({{
                                                trip.driver.reviews }} รีวิว)</span>
                                        </div>
                                    </div>
                                    <div class="text-right">
                                        <div class="text-lg font-bold text-blue-600">{{ trip.price }} บาท</div>
                                        <div class="text-sm text-gray-600">จำนวน {{ trip.seats }} ที่นั่ง</div>
                                    </div>
                                </div>

                                <!-- Action Buttons -->
                                <div class="flex justify-end space-x-3">
                                    <button v-if="trip.status === 'pending'"
                                        class="px-4 py-2 border border-red-300 text-red-600 rounded-md hover:bg-red-50 transition duration-200 text-sm">
                                        ยกเลิกการจอง
                                    </button>
                                    <button v-if="trip.status === 'confirmed'"
                                        class="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 transition duration-200 text-sm">
                                        แชทกับผู้ขับ
                                    </button>
                                    <button v-if="['rejected', 'cancelled'].includes(trip.status)"
                                        class="px-4 py-2 border border-gray-300 text-gray-600 rounded-md hover:bg-gray-50 transition duration-200 text-sm">
                                        ลบรายการ
                                    </button>
                                </div>
                            </div>

                            <!-- Empty State -->
                            <div v-if="filteredTrips.length === 0" class="p-12 text-center text-gray-500">
                                <p>ไม่พบรายการเดินทางในหมวดหมู่นี้</p>
                            </div>

                        </div>
                    </div>
                </div>

                <!-- Right Side - Map (1/3) -->
                <div class="lg:col-span-1">
                    <div class="bg-white rounded-lg shadow-md overflow-hidden sticky top-8">
                        <div class="p-4 border-b border-gray-200">
                            <h3 class="text-lg font-semibold text-gray-900">แผนที่เส้นทาง</h3>
                            <p class="text-sm text-gray-600 mt-1">{{ selectedTrip ? selectedTrip.origin + ' → ' +
                                selectedTrip.destination : 'คลิกที่รายการเพื่อดูเส้นทาง' }}</p>
                        </div>
                        <div ref="mapContainer" id="map"></div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<script setup>
import { ref, computed, onMounted, watch, nextTick } from 'vue';

// --- State Management ---
const activeTab = ref('pending');
const selectedTripId = ref(null);
const mapContainer = ref(null);
let map = null;
let currentPolyline = null;
let currentMarkers = [];

// --- Data ---
const allTrips = ref([
    { id: 1, origin: 'กรุงเทพฯ', destination: 'เชียงใหม่', pickupPoint: 'หน้าสถานี BTS อนุสาวรีย์', date: '15 กรกฎาคม 2025', time: '08:00 น.', price: 250, seats: 2, status: 'pending', driver: { name: 'สมชาย ใจดี', image: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=60&h=60&fit=crop&crop=face', rating: 4.8, reviews: 25 }, coords: [[13.7563, 100.5018], [18.7883, 98.9853]] },
    { id: 2, origin: 'กรุงเทพฯ', destination: 'ภูเก็ต', pickupPoint: 'หน้าสถานี BTS สยาม', date: '20 กรกฎาคม 2025', time: '10:30 น.', price: 450, seats: 1, status: 'confirmed', driver: { name: 'วรรณา สุขใจ', image: 'https://images.unsplash.com/photo-1494790108755-2616b2dc0a48?w=60&h=60&fit=crop&crop=face', rating: 4.5, reviews: 18 }, coords: [[13.7563, 100.5018], [7.8804, 98.3923]] },
    { id: 3, origin: 'กรุงเทพฯ', destination: 'เชียงราย', pickupPoint: 'หน้าสถานี BTS มหาดไทย', date: '10 กรกฎาคม 2025', time: '14:00 น.', price: 320, seats: 1, status: 'rejected', driver: { name: 'อนุชา รักเดินทาง', image: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=60&h=60&fit=crop&crop=face', rating: 4.9, reviews: 42 }, coords: [[13.7563, 100.5018], [19.9105, 99.8406]] },
    { id: 4, origin: 'กรุงเทพฯ', destination: 'หาดใหญ่', pickupPoint: 'หน้าสถานี BTS อโศก', date: '5 กรกฎาคม 2025', time: '09:00 น.', price: 380, seats: 2, status: 'cancelled', driver: { name: 'ประยุทธ ดีใจ', image: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=60&h=60&fit=crop&crop=face', rating: 4.3, reviews: 12 }, coords: [[13.7563, 100.5018], [7.0123, 100.4681]] },
    { id: 5, origin: 'เชียงใหม่', destination: 'กรุงเทพฯ', pickupPoint: 'สนามบินเชียงใหม่', date: '18 กรกฎาคม 2025', time: '18:00 น.', price: 280, seats: 1, status: 'pending', driver: { name: 'สมชาย ใจดี', image: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=60&h=60&fit=crop&crop=face', rating: 4.8, reviews: 25 }, coords: [[18.7883, 98.9853], [13.7563, 100.5018]] },
    { id: 6, origin: 'พัทยา', destination: 'กรุงเทพฯ', pickupPoint: 'เซ็นทรัล พัทยา', date: '22 กรกฎาคม 2025', time: '15:00 น.', price: 150, seats: 3, status: 'confirmed', driver: { name: 'วรรณา สุขใจ', image: 'https://images.unsplash.com/photo-1494790108755-2616b2dc0a48?w=60&h=60&fit=crop&crop=face', rating: 4.5, reviews: 18 }, coords: [[12.9336, 100.8825], [13.7563, 100.5018]] },
    { id: 7, origin: 'ขอนแก่น', destination: 'กรุงเทพฯ', pickupPoint: 'ม.ขอนแก่น', date: '25 กรกฎาคม 2025', time: '07:00 น.', price: 300, seats: 1, status: 'pending', driver: { name: 'อนุชา รักเดินทาง', image: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=60&h=60&fit=crop&crop=face', rating: 4.9, reviews: 42 }, coords: [[16.4322, 102.8229], [13.7563, 100.5018]] },
]);

const tabs = [
    { status: 'pending', label: 'รอดำเนินการ' },
    { status: 'confirmed', label: 'ยืนยันแล้ว' },
    { status: 'rejected', label: 'ปฏิเสธ' },
    { status: 'cancelled', label: 'ยกเลิก' },
    { status: 'all', label: 'ทั้งหมด' },
];

// --- Computed Properties ---
const filteredTrips = computed(() => {
    if (activeTab.value === 'all') {
        return allTrips.value;
    }
    return allTrips.value.filter(trip => trip.status === activeTab.value);
});

const selectedTrip = computed(() => {
    return allTrips.value.find(trip => trip.id === selectedTripId.value) || null;
});

// --- Methods ---
const getTripCount = (status) => {
    if (status === 'all') return allTrips.value.length;
    return allTrips.value.filter(trip => trip.status === status).length;
};

const selectTrip = (tripId) => {
    selectedTripId.value = tripId;
};

const updateMap = (trip) => {
    if (!map || !trip) return;

    // Clear previous layers
    if (currentPolyline) map.removeLayer(currentPolyline);
    currentMarkers.forEach(marker => map.removeLayer(marker));
    currentMarkers = [];

    // Add new route
    currentPolyline = L.polyline(trip.coords, { color: '#3b82f6', weight: 4 }).addTo(map);

    // Add markers
    const startMarker = L.marker(trip.coords[0]).bindPopup('จุดเริ่มต้น').addTo(map);
    const endMarker = L.marker(trip.coords[trip.coords.length - 1]).bindPopup('จุดปลายทาง').addTo(map);
    currentMarkers.push(startMarker, endMarker);

    // Fit map to route
    map.fitBounds(currentPolyline.getBounds(), { padding: [40, 40] });
};

// --- Lifecycle and Watchers ---
useHead({
    link: [{ rel: 'stylesheet', href: 'https://unpkg.com/leaflet@1.7.1/dist/leaflet.css' }],
    script: [{ src: 'https://unpkg.com/leaflet@1.7.1/dist/leaflet.js', defer: true }]
});

onMounted(() => {
    // Wait for Leaflet script to load
    const checkLeaflet = setInterval(() => {
        if (typeof L !== 'undefined') {
            clearInterval(checkLeaflet);
            nextTick(() => {
                if (mapContainer.value) {
                    map = L.map(mapContainer.value).setView([13.7563, 100.5018], 6);
                    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                        attribution: '© OpenStreetMap contributors'
                    }).addTo(map);

                    if (filteredTrips.value.length > 0) {
                        selectTrip(filteredTrips.value[0].id);
                    }
                }
            });
        }
    }, 100);
});

watch(selectedTrip, (newTrip) => {
    if (newTrip) {
        updateMap(newTrip);
    }
});

watch(activeTab, () => {
    if (filteredTrips.value.length > 0) {
        selectTrip(filteredTrips.value[0].id);
    } else {
        selectTrip(null);
    }
});

</script>

<style scoped>
.trip-card {
    transition: all 0.3s ease;
    cursor: pointer;
}

.trip-card:hover {
    transform: translateY(-2px);
    box-shadow: 0 10px 25px rgba(59, 130, 246, 0.1);
}

.trip-card.selected {
    border: 2px solid #3b82f6;
    background-color: #eff6ff;
}

.tab-button {
    transition: all 0.3s ease;
}

.tab-button.active {
    background-color: #3b82f6;
    color: white;
    box-shadow: 0 4px 14px rgba(59, 130, 246, 0.3);
}

.tab-button:not(.active) {
    background-color: white;
    color: #6b7280;
    border: 1px solid #d1d5db;
}

.tab-button:not(.active):hover {
    background-color: #f9fafb;
    color: #374151;
}

#map {
    height: 100%;
    min-height: 600px;
    border-radius: 0 0 0.5rem 0.5rem;
}

.status-badge {
    display: inline-flex;
    align-items: center;
    padding: 0.25rem 0.75rem;
    border-radius: 9999px;
    font-size: 0.875rem;
    font-weight: 500;
}

.status-pending {
    background-color: #fef3c7;
    color: #d97706;
}

.status-confirmed {
    background-color: #d1fae5;
    color: #065f46;
}

.status-rejected {
    background-color: #fee2e2;
    color: #dc2626;
}

.status-cancelled {
    background-color: #f3f4f6;
    color: #6b7280;
}
</style>
