<template>
    <div>
        <div class="px-4 py-8 mx-auto max-w-7xl sm:px-6 lg:px-8">
            <div class="mb-8">
                <h2 class="text-2xl font-bold text-gray-900">คำขอจองเส้นทางของฉัน</h2>
                <p class="mt-2 text-gray-600">ดูและจัดการคำขอจองจากผู้โดยสารในเส้นทางที่คุณสร้าง</p>
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
                            <h3 class="text-lg font-semibold text-gray-900">
                                {{ activeTab === 'myRoutes' ? 'เส้นทางของฉัน' : 'รายการคำขอจอง' }}
                            </h3>
                        </div>

                        <div v-if="isLoading" class="p-12 text-center text-gray-500">
                            <p>กำลังโหลดข้อมูล...</p>
                        </div>

                        <!-- ===== แท็บ: เส้นทางของฉัน ===== -->
                        <div v-else-if="activeTab === 'myRoutes'" class="divide-y divide-gray-200">
                            <div v-if="myRoutes.length === 0" class="p-12 text-center text-gray-500">
                                <p>ยังไม่มีเส้นทางที่คุณสร้าง</p>
                            </div>

                            <div v-for="route in sortedMyRoutes" :key="route.id"
                                :class="['p-6 trip-card', getTripState(route.id).completed ? 'opacity-75 bg-gray-50' : 'hover:bg-gray-50']"
                                @click="toggleTripDetails(route.id)">
                                <div class="flex items-start justify-between mb-4">
                                    <div class="flex-1">
                                        <div class="flex items-center justify-between">
                                            <h4 class="text-lg font-semibold text-gray-900">
                                                {{ route.origin }} → {{ route.destination }}
                                            </h4>
                                            <span class="status-badge" :class="{
                                                'status-confirmed': route.status === 'available',
                                                'status-pending': route.status === 'full',
                                            }">
                                                {{ route.status === 'available' ? 'เปิดรับผู้โดยสาร' : 'เต็ม' }}
                                            </span>
                                        </div>
                                        <p class="mt-1 text-sm text-gray-600">
                                            วันที่: {{ route.date }}
                                            <span class="mx-2 text-gray-300">|</span>
                                            เวลา: {{ route.time }}
                                            <span class="mx-2 text-gray-300">|</span>
                                            ระยะเวลา: {{ route.durationText }}
                                            <span class="mx-2 text-gray-300">|</span>
                                            ระยะทาง: {{ route.distanceText }}
                                        </p>
                                        <div class="mt-1 text-sm text-gray-600">
                                            <span class="font-medium">ที่นั่งว่าง:</span>
                                            <span class="ml-1">{{ route.availableSeats }}</span>
                                            <span class="mx-2 text-gray-300">|</span>
                                            <span class="font-medium">ราคาต่อที่นั่ง:</span>
                                            <span class="ml-1">{{ route.pricePerSeat }} บาท</span>
                                        </div>
                                    </div>
                                </div>

                                <!-- รายละเอียดเมื่อเปิด --> <!--เพิ่มการสลับตำแหน่งและการแสดงรายละเอียดเส้นทางแบบใหม่-->
                                <div v-if="selectedTripId === route.id"
                                    class="pt-4 mt-4 mb-5 duration-300 border-t border-gray-300 animate-in slide-in-from-top">
                                    <div class="grid grid-cols-1 gap-4 md:grid-cols-2">
                                        
                                        <div>
                                            <h5 class="mb-2 font-medium text-gray-900">รายละเอียดรถ</h5>
                                            <ul class="space-y-1 text-sm text-gray-600">
                                                <li v-for="detail in route.carDetails" :key="detail">• {{ detail }}</li>
                                            </ul>
                                        </div>
                                        <div>
                                            <h5 class="mb-4 font-medium text-gray-900 flex items-center gap-2">
                                                รายละเอียดเส้นทาง
                                                <span v-if="getTripState(route.id).started" class="text-[10px] text-blue-600 bg-blue-50 px-2 py-0.5 rounded-full animate-pulse">
                                                    กำลังเดินทาง
                                                </span>
                                                <span v-if="getTripState(route.id).completed" class="text-[10px] text-green-600 bg-green-50 px-2 py-0.5 rounded-full">
                                                   สิ้นสุดการเดินทาง
                                                </span>
                                            </h5>

                                            <div class="relative pl-2">
                                                <div class="absolute left-[15px] top-2 bottom-4 w-0.5 bg-gray-200"></div>
                                                <div class="space-y-6 relative">
                                                    <div v-for="(point, index) in getRouteTimeline(route)" :key="index" class="flex items-start group relative mb-6">
                                                            <div v-if="index < getRouteTimeline(route).length - 1" 
                                                                class="absolute left-[15px] top-8 w-0.5 h-full bg-gray-200 z-0"></div>

                                                            <div class="relative z-10 flex-shrink-0 w-8 h-8 flex items-center justify-center rounded-full border-2 bg-white transition-all shadow-sm"
                                                                :class="[
                                                                    index <= getTripState(route.id).currentIndex 
                                                                        ? 'border-green-500 text-green-600 bg-green-50' 
                                                                        : 'border-gray-300 text-gray-400'
                                                                ]">
                                                                <span v-if="index < getTripState(route.id).currentIndex" class="font-bold text-sm">✓</span>
                                                                <span v-else class="text-[10px] font-bold">{{ index + 1 }}</span>
                                                            </div>

                                                            <div class="ml-4 flex-1 min-w-0">
                                                                <div class="flex flex-col">
                                                                    <p class="text-sm font-bold truncate mb-0.5" 
                                                                    :class="index <= getTripState(route.id).currentIndex ? 'text-gray-900' : 'text-gray-500'">
                                                                        {{ point.name }}
                                                                    </p>

                                                                    <div v-if="point.isPassengerPoint" class="mt-1 flex flex-wrap gap-1">
                                                                        <template v-for="(psgr, pIdx) in point.passengerList" :key="pIdx">
                                                                            <span :class="[
                                                                                'inline-flex items-center px-2 py-0.5 rounded text-[10px] font-semibold shadow-sm',
                                                                                'bg-blue-100 text-blue-700'
                                                                            ]">
                                                                                <span class="mr-1">{{ psgr.action === 'pickup' ? '↑' : '↓' }}</span>
                                                                                {{ psgr.action === 'pickup' ? 'รับ' : 'ส่ง' }}คุณ {{ psgr.name }}
                                                                            </span>
                                                                        </template>
                                                                        
                                                                        <span v-if="!point.passengerList" class="inline-flex items-center px-2 py-0.5 rounded text-[10px] font-semibold bg-blue-100 text-blue-700">
                                                                            {{ point.actionType === 'pickup' ? '↑ รับ' : '↓ ส่ง' }}คุณ {{ point.passengerName }}
                                                                        </span>
                                                                    </div>
                                                                    <p v-if="point.address && !point.address.includes('จุดแวะ')" 
                                                                    class="text-[10px] text-gray-400 truncate leading-tight mt-1">
                                                                        {{ point.address }}
                                                                    </p>
                                                                </div>
                                                            </div>
                                                        </div>
                                                </div>
                                            </div>

                                            <button 
                                                    v-if="getTripState(route.id).started && !getTripState(route.id).completed" 
                                                    @click.stop="handleCheckPoint(route.id, route)"
                                                    :disabled="isProcessing"
                                                    class="mt-4 w-full py-2 text-xs font-medium text-white bg-indigo-600 rounded-md hover:bg-indigo-700 shadow-md transition-all flex justify-center items-center gap-2"
                                                >
                                                    <span v-if="isProcessing" class="animate-spin inline-block w-3 h-3 border-2 border-white border-t-transparent rounded-full"></span>
                                                     {{ getTripState(route.id).currentIndex === getRouteTimeline(route).length - 2 ? 'ยืนยันการถึงปลายทาง' : 'Checkpoint' }}
                                                </button>

                                                <div v-if="getTripState(route.id).completed" class="mt-4 p-3 bg-green-50 border border-green-200 rounded-md text-center text-sm text-green-700 font-medium">
                                                     การเดินทางนี้เสร็จสิ้นสมบูรณ์แล้ว
                                                </div>
                                        </div>
                                    </div>

                                    <div class="mt-4 space-y-4">
                                        <div v-if="route.conditions">
                                            <h5 class="mb-2 font-medium text-gray-900">เงื่อนไขการเดินทาง</h5>
                                            <p
                                                class="p-3 text-sm text-gray-700 border border-gray-300 rounded-md bg-gray-50">
                                                {{ route.conditions }}
                                            </p>
                                        </div>

                                        <div v-if="route.photos && route.photos.length > 0">
                                            <h5 class="mb-2 font-medium text-gray-900">รูปภาพรถยนต์</h5>
                                            <div class="grid grid-cols-3 gap-2 mt-2">
                                                <div v-for="(photo, index) in route.photos.slice(0, 3)" :key="index">
                                                    <img :src="photo" alt="Vehicle photo"
                                                        class="object-cover w-full transition-opacity rounded-lg shadow-sm cursor-pointer aspect-video hover:opacity-90" />
                                                </div>
                                            </div>
                                        </div>

                                        <!-- ผู้โดยสารของเส้นทางนี้ -->
                                        <div v-if="route.passengers && route.passengers.length">
                                            <h5 class="mb-4 font-medium text-gray-900">ผู้โดยสาร ({{ route.passengers.length }} คน)</h5>
                                            <div class="space-y-6">
                                                <div v-for="p in route.passengers" :key="p.id" 
                                                    class="flex flex-col md:flex-row md:items-center justify-between p-4 border border-gray-100 rounded-xl bg-gray-50/50">
                                                    
                                                    <div class="flex items-start space-x-4">
                                                        <img :src="p.image" :alt="p.name" class="object-cover w-14 h-14 rounded-full shadow-sm" />
                                                        
                                                        <div class="flex-1">
                                                            <div class="flex items-center gap-2">
                                                                <span class="font-bold text-gray-900">{{ p.name }}</span>
                                                                <span v-if="p.isVerified" class="text-blue-600">
                                                                    <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 24 24"><path d="M8.603 3.799A4.49 4.49 0 0112 2.25c1.357 0 2.573.6 3.397 1.549a4.49 4.49 0 013.498 1.307 4.491 4.491 0 011.307 3.497A4.49 4.49 0 0121.75 12c0 1.357-.6 2.573-1.549 3.397a4.49 4.49 0 01-1.307 3.498 4.491 4.491 0 01-3.497 1.307A4.49 4.49 0 0112 21.75a4.49 4.49 0 01-3.397-1.549a4.49 4.49 0 01-3.498-1.306 4.491 4.491 0 01-1.307-3.498A4.49 4.49 0 012.25 12c0-1.357.6-2.573 1.549-3.397a4.49 4.49 0 011.307-3.497a4.49 4.49 0 013.497-1.307zm7.007 6.387a.75.75 0 10-1.22-.872l-3.236 4.53L9.53 12.22a.75.75 0 00-1.06 1.06l2.25 2.25a.75.75 0 001.07-.01l3.5-4.875z" /></svg>
                                                                </span>
                                                            </div>
                                                            
                                                            <div class="mt-2 space-y-1 text-xs text-gray-600">
                                                                <p class="flex items-center gap-1">
                                                                    <span class="font-semibold text-blue-600">↑ จุดรับ:</span> {{ p.pickupName || 'ไม่มีข้อมูล' }}
                                                                </p>
                                                                <p class="flex items-center gap-1">
                                                                    <span class="font-semibold text-orange-600">↓ จุดส่ง:</span> {{ p.dropoffName || 'ไม่มีข้อมูล' }}
                                                                </p>
                                                                <p class="mt-2 font-medium">ที่นั่ง: {{ p.seats }} </p>
                                                            </div>
                                                        </div>
                                                    </div>

                                                    <div class="mt-3 md:mt-0 flex flex-col gap-2 items-end">
                                                        <!-- สถานะผู้โดยสาร -->
                                                        <span v-if="p.passengerStatus === 'IN_TRANSIT'" 
                                                            class="text-xs font-semibold text-blue-600 bg-blue-50 px-3 py-1 rounded-full">
                                                             กำลังเดินทาง
                                                        </span>
                                                        <span v-else-if="p.passengerStatus === 'WAITING_PICKUP'" 
                                                            class="text-xs font-semibold text-yellow-600 bg-yellow-50 px-3 py-1 rounded-full animate-pulse">
                                                             รอผู้โดยสารยืนยัน
                                                        </span>
                                                        <span v-else-if="p.passengerStatus === 'REJECTED_PICKUP'" 
                                                            class="text-xs font-semibold text-red-600 bg-red-50 px-3 py-1 rounded-full">
                                                             ผู้โดยสารปฏิเสธการรับ กรุณาติดต่อผู้โดยสาร
                                                        </span>
                                                        <span v-else-if="p.passengerStatus === 'ARRIVED'" 
                                                            class="text-xs font-semibold text-green-600 bg-green-50 px-3 py-1 rounded-full">
                                                             ส่งถึงจุดหมายแล้ว
                                                        </span>
                                                        <span v-else-if="p.driverCancelRequest && p.passengerStatus !== 'CANCELLED'" 
                                                            class="text-xs font-semibold text-orange-600 bg-orange-50 px-3 py-1 rounded-full">
                                                             รอผู้โดยสารตอบรับการยกเลิก
                                                        </span>
                                                        <span v-else-if="p.status === 'cancelled' || p.passengerStatus === 'CANCELLED'" 
                                                            class="text-xs font-semibold text-gray-500 bg-gray-100 px-3 py-1 rounded-full">
                                                             ยกเลิกการเดินทาง
                                                        </span>

                                                        <!-- ปุ่ม action -->
                                                        <div v-if="getTripState(route.id).started && p.status !== 'cancelled' && p.passengerStatus !== 'CANCELLED'" 
                                                            class="flex gap-2">
                                                            
                                                            <button v-if="!p.passengerStatus || p.passengerStatus === 'REJECTED_PICKUP'"
                                                                @click.stop="handlePassengerPickup(route.id, p)"
                                                                class="px-3 py-1.5 text-xs font-bold text-white bg-blue-600 rounded-lg hover:bg-blue-700 transition shadow-sm">
                                                                รับผู้โดยสาร
                                                            </button>

                                                            <button v-if="p.passengerStatus !== 'IN_TRANSIT' && p.passengerStatus !== 'ARRIVED' && !p.driverCancelRequest" 
                                                                @click.stop="handleDriverCancelRequest(route.id, p)"
                                                                class="px-3 py-1.5 text-xs font-medium text-red-600 border border-red-200 rounded-lg hover:bg-red-50 transition">
                                                                ยกเลิกการเดินทาง
                                                            </button>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <!-- ปุ่มขวาล่าง --> <!--เพิ่มปุ่มเริ่มต้นการเดินทางและprocessการทำงานใหม่-->
                                <div class="flex justify-end gap-2" :class="{ 'mt-4': selectedTripId !== route.id }">
                                   <button
                                        type="button"
                                        @click.stop="triggerStartTrip(route.id)"
                                        :disabled="getTripState(route.id).started || isProcessing || getTripState(route.id).completed"
                                        class="px-4 py-2 text-sm text-white rounded-md transition duration-200 flex items-center gap-2 shadow-sm"
                                        :class="[
                                            getTripState(route.id).completed 
                                                ? 'bg-gray-400 cursor-not-allowed' 
                                                : (getTripState(route.id).started ? 'bg-green-600 cursor-default' : 'bg-blue-600 hover:bg-blue-700')
                                        ]">
                                        <span v-if="isProcessing && pendingRouteId === route.id" class="animate-spin inline-block w-4 h-4 border-2 border-white border-t-transparent rounded-full"></span>
                                        <span v-if="getTripState(route.id).completed">สิ้นสุดการเดินทางแล้ว</span>
                                        <span v-else-if="getTripState(route.id).started">กำลังเดินทาง...</span>
                                        <span v-else>เริ่มต้นการเดินทาง</span>
                                    </button>
                                    <NuxtLink v-if="!getTripState(route.id).started && !getTripState(route.id).completed"
                                        :to="`/myRoute/${route.id}/edit`" 
                                        class="px-4 py-2 text-sm text-blue-600 border border-blue-600 rounded-md hover:bg-gray-50">
                                        แก้ไขเส้นทาง
                                    </NuxtLink>
                                </div>
                            </div>
                        </div>

                        <!-- ===== แท็บ: คำขอจอง (เดิม) ===== -->
                        <div v-else class="divide-y divide-gray-200">
                            <div v-if="filteredTrips.length === 0" class="p-12 text-center text-gray-500">
                                <p>ไม่พบรายการในหมวดหมู่นี้</p>
                            </div>

                            <div v-for="trip in filteredTrips" :key="trip.id"
                                class="p-6 transition-colors duration-200 cursor-pointer trip-card hover:bg-gray-50"
                                @click="toggleTripDetails(trip.id)">
                                <div class="flex items-start justify-between mb-4">
                                    <div class="flex-1">
                                        <div class="flex items-center justify-between">
                                            <h4 class="text-lg font-semibold text-gray-900">
                                                {{ trip.origin }} → {{ trip.destination }}
                                            </h4>
                                            <span v-if="trip.status === 'pending'"
                                                class="status-badge status-pending">รอดำเนินการ</span>
                                            <span v-else-if="trip.status === 'confirmed'"
                                                class="status-badge status-confirmed">ยืนยันแล้ว</span>
                                            <span v-else-if="trip.status === 'rejected'"
                                                class="status-badge status-rejected">ปฏิเสธ</span>
                                            <span v-else-if="trip.status === 'cancelled'"
                                                class="status-badge status-cancelled">ยกเลิก</span>
                                        </div>
                                        <p class="mt-1 text-sm text-gray-600">
                                            <span class="font-medium text-blue-600">จุดรับ:</span> {{ trip.pickupPoint }} 
                                            <span class="mx-2 text-gray-300">|</span>
                                            <span class="font-medium text-orange-600">จุดส่ง:</span> {{ trip.dropoffPoint }}
                                        </p>
                                        <p class="text-sm text-gray-600">
                                            วันที่: {{ trip.date }}
                                            <span class="mx-2 text-gray-300">|</span>
                                            เวลา: {{ trip.time }}
                                            <span class="mx-2 text-gray-300">|</span>
                                            ระยะเวลา: {{ trip.durationText }}
                                            <span class="mx-2 text-gray-300">|</span>
                                            ระยะทาง: {{ trip.distanceText }}
                                        </p>
                                        <div v-if="activeTab === 'cancelled' && trip.status === 'cancelled' && trip.cancelReason"
                                            class="p-2 mt-2 border border-gray-200 rounded-md bg-gray-50">
                                            <span class="text-sm text-gray-700">
                                                เหตุผลการยกเลิกของผู้โดยสาร:
                                                <span class="font-medium">{{ reasonLabel(trip.cancelReason) }}</span>
                                            </span>
                                        </div>
                                    </div>
                                </div>

                                <div class="flex items-center mb-4 space-x-4">
                                    <img :src="trip.passenger.image" :alt="trip.passenger.name"
                                        class="object-cover rounded-full w-15 h-15" />
                                    <div class="flex-1">
                                        <div class="flex items-center">
                                            <h5 class="font-medium text-gray-900">{{ trip.passenger.name }}</h5>

                                            <div v-if="trip.passenger.isVerified"
                                                class="relative group ml-1.5 flex items-center">
                                                <svg class="w-5 h-5 text-blue-600" viewBox="0 0 24 24"
                                                    fill="currentColor">
                                                    <path fill-rule="evenodd"
                                                        d="M8.603 3.799A4.49 4.49 0 0112 2.25c1.357 0 2.573.6 3.397 1.549a4.49 4.49 0 013.498 1.307 4.491 4.491 0 011.307 3.497A4.49 4.49 0 0121.75 12c0 1.357-.6 2.573-1.549 3.397a4.49 4.49 0 01-1.307 3.498 4.491 4.491 0 01-3.497 1.307A4.49 4.49 0 0112 21.75a4.49 4.49 0 01-3.397-1.549 4.49 4.49 0 01-3.498-1.306 4.491 4.491 0 01-1.307-3.498A4.49 4.49 0 012.25 12c0-1.357.6-2.573 1.549-3.397a4.49 4.49 0 011.307-3.497 4.49 4.49 0 013.497-1.307zm7.007 6.387a.75.75 0 10-1.22-.872l-3.236 4.53L9.53 12.22a.75.75 0 00-1.06 1.06l2.25 2.25a.75.75 0 001.07-.01l3.5-4.875z"
                                                        clip-rule="evenodd" />
                                                </svg>
                                                <span
                                                    class="absolute px-2 py-1 mb-2 text-xs text-white transition-opacity -translate-x-1/2 bg-gray-800 rounded-md opacity-0 pointer-events-none bottom-full left-1/2 w-max group-hover:opacity-100">
                                                    ผู้โดยสารยืนยันตัวตนแล้ว
                                                </span>
                                            </div>
                                        </div>

                                        <div class="flex">
                                            <p v-if="trip.passenger.email" class="text-xs text-gray-500 mt-0.5">
                                                อีเมล:
                                                <a :href="`mailto:${trip.passenger.email}`"
                                                    class="text-blue-600 hover:underline" @click.stop>
                                                    {{ trip.passenger.email }}
                                                </a>
                                            </p>
                                            <button v-if="trip.passenger.email"
                                                class="inline-flex items-center ml-1 text-gray-500 rounded hover:text-gray-700 hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-blue-500"
                                                title="คัดลอกอีเมล" aria-label="คัดลอกอีเมล"
                                                @click.stop="copyEmail(trip.passenger.email)">
                                                <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none"
                                                    stroke="currentColor">
                                                    <path stroke-linecap="round" stroke-linejoin="round"
                                                        stroke-width="2"
                                                        d="M8 7h8a2 2 0 012 2v8a2 2 0 01-2 2H8a2 2 0 01-2-2V9a2 2 0 012-2z" />
                                                    <path stroke-linecap="round" stroke-linejoin="round"
                                                        stroke-width="2" d="M16 7V5a2 2 0 00-2-2H8a2 2 0 00-2 2v2" />
                                                </svg>
                                            </button>
                                        </div>
                                    </div>
                                    <div class="text-right">
                                        <div class="text-lg font-bold text-blue-600">{{ trip.price }} บาท</div>
                                        <div class="text-sm text-gray-600">จำนวน {{ trip.seats }} ที่นั่ง</div>
                                    </div>
                                </div>

                                <!-- รายละเอียดเส้นทาง + จุดแวะ --> <!--เพิ่มการสลับตำแหน่งและการแสดงรายละเอียดเส้นทางแบบใหม่-->
                                <div v-if="selectedTripId === trip.id"
                                    class="pt-4 mt-4 mb-5 duration-300 border-t border-gray-300 animate-in slide-in-from-top">
                                    <div class="grid grid-cols-1 gap-4 md:grid-cols-2">
                                        
                                        <div>
                                            <h5 class="mb-2 font-medium text-gray-900">รายละเอียดรถ</h5>
                                            <ul class="space-y-1 text-sm text-gray-600">
                                                <li v-for="detail in route.carDetails" :key="detail">• {{ detail }}</li>
                                            </ul>
                                        </div>
                                        <div>
                                            <h5 class="mb-4 font-medium text-gray-900 flex items-center gap-2">
                                                รายละเอียดเส้นทาง
                                                <span v-if="getTripState(route.id).started" class="text-[10px] text-blue-600 bg-blue-50 px-2 py-0.5 rounded-full animate-pulse">
                                                    กำลังเดินทาง
                                                </span>
                                                <span v-if="getTripState(route.id).completed" class="text-[10px] text-green-600 bg-green-50 px-2 py-0.5 rounded-full">
                                                   สิ้นสุดการเดินทาง
                                                </span>
                                            </h5>

                                            <div class="relative pl-2">
                                                <div class="absolute left-[15px] top-2 bottom-4 w-0.5 bg-gray-200"></div>
                                                <div class="space-y-6 relative">
                                                    <div v-for="(point, index) in getRouteTimeline(route)" :key="index" class="flex items-start group relative mb-6">
                                                            <div v-if="index < getRouteTimeline(route).length - 1" 
                                                                class="absolute left-[15px] top-8 w-0.5 h-full bg-gray-200 z-0"></div>

                                                            <div class="relative z-10 flex-shrink-0 w-8 h-8 flex items-center justify-center rounded-full border-2 bg-white transition-all shadow-sm"
                                                                :class="[
                                                                    index <= getTripState(route.id).currentIndex 
                                                                        ? 'border-green-500 text-green-600 bg-green-50' 
                                                                        : 'border-gray-300 text-gray-400'
                                                                ]">
                                                                <span v-if="index < getTripState(route.id).currentIndex" class="font-bold text-sm">✓</span>
                                                                <span v-else class="text-[10px] font-bold">{{ index + 1 }}</span>
                                                            </div>

                                                            <div class="ml-4 flex-1 min-w-0">
                                                                <div class="flex flex-col">
                                                                    <p class="text-sm font-bold truncate mb-0.5" 
                                                                    :class="index <= getTripState(route.id).currentIndex ? 'text-gray-900' : 'text-gray-500'">
                                                                        {{ point.name }}
                                                                    </p>

                                                                    <div v-if="point.isPassengerPoint" class="mt-1 flex flex-wrap gap-1">
                                                                        <template v-for="(psgr, pIdx) in point.passengerList" :key="pIdx">
                                                                            <span :class="[
                                                                                'inline-flex items-center px-2 py-0.5 rounded text-[10px] font-semibold shadow-sm',
                                                                                'bg-blue-100 text-blue-700'
                                                                            ]">
                                                                                <span class="mr-1">{{ psgr.action === 'pickup' ? '↑' : '↓' }}</span>
                                                                                {{ psgr.action === 'pickup' ? 'รับ' : 'ส่ง' }}คุณ {{ psgr.name }}
                                                                            </span>
                                                                        </template>
                                                                        
                                                                        <span v-if="!point.passengerList" class="inline-flex items-center px-2 py-0.5 rounded text-[10px] font-semibold bg-blue-100 text-blue-700">
                                                                            {{ point.actionType === 'pickup' ? '↑ รับ' : '↓ ส่ง' }}คุณ {{ point.passengerName }}
                                                                        </span>
                                                                    </div>

                                                                    <p v-if="point.address && !point.address.includes('จุดแวะ')" 
                                                                    class="text-[10px] text-gray-400 truncate leading-tight mt-1">
                                                                        {{ point.address }}
                                                                    </p>
                                                                </div>
                                                            </div>
                                                        </div>
                                                                                                        </div>
                                            </div>

                                            <button 
                                                    v-if="getTripState(route.id).started && !getTripState(route.id).completed" 
                                                    @click.stop="handleCheckPoint(route.id, route)"
                                                    :disabled="isProcessing"
                                                    class="mt-4 w-full py-2 text-xs font-medium text-white bg-indigo-600 rounded-md hover:bg-indigo-700 shadow-md transition-all flex justify-center items-center gap-2"
                                                >
                                                    <span v-if="isProcessing" class="animate-spin inline-block w-3 h-3 border-2 border-white border-t-transparent rounded-full"></span>
                                                     {{ getTripState(route.id).currentIndex === getRouteTimeline(route).length - 2 ? 'ยืนยันการถึงปลายทาง' : 'Checkpoint' }}
                                                </button>

                                                <div v-if="getTripState(route.id).completed" class="mt-4 p-3 bg-green-50 border border-green-200 rounded-md text-center text-sm text-green-700 font-medium">
                                                    การเดินทางนี้เสร็จสิ้นสมบูรณ์แล้ว
                                                </div>
                                        </div>
                                    </div>
                                    <div class="mt-4 space-y-4">
                                        <div v-if="trip.conditions">
                                            <h5 class="mb-2 font-medium text-gray-900">เงื่อนไขการเดินทาง</h5>
                                            <p
                                                class="p-3 text-sm text-gray-700 border border-gray-300 rounded-md bg-gray-50">
                                                {{ trip.conditions }}
                                            </p>
                                        </div>
                                        <div v-if="trip.photos && trip.photos.length > 0">
                                            <h5 class="mb-2 font-medium text-gray-900">รูปภาพรถยนต์</h5>
                                            <div class="grid grid-cols-3 gap-2 mt-2">
                                                <div v-for="(photo, index) in trip.photos.slice(0, 3)" :key="index">
                                                    <img :src="photo" alt="Vehicle photo"
                                                        class="object-cover w-full transition-opacity rounded-lg shadow-sm cursor-pointer aspect-video hover:opacity-90" />
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <div class="flex justify-end space-x-3" :class="{ 'mt-4': selectedTripId !== trip.id }">
                                    <template v-if="trip.status === 'pending'">
                                        <button @click.stop="openConfirmModal(trip, 'confirm')"
                                            class="px-4 py-2 text-sm text-white transition duration-200 bg-blue-600 rounded-md hover:bg-blue-700">
                                            ยืนยันคำขอ
                                        </button>
                                        <button @click.stop="openConfirmModal(trip, 'reject')"
                                            class="px-4 py-2 text-sm text-red-600 transition duration-200 border border-red-300 rounded-md hover:bg-red-50">
                                            ปฏิเสธ
                                        </button>
                                    </template>

                                    <button v-else-if="trip.status === 'confirmed'"
                                        class="px-4 py-2 text-sm text-white transition duration-200 bg-blue-600 rounded-md hover:bg-blue-700">
                                        แชทกับผู้โดยสาร
                                    </button>

                                    <button v-else-if="['rejected', 'cancelled'].includes(trip.status)"
                                        @click.stop="openConfirmModal(trip, 'delete')"
                                        class="px-4 py-2 text-sm text-gray-600 transition duration-200 border border-gray-300 rounded-md hover:bg-gray-50">
                                        ลบรายการ
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- แผนที่ -->
                <div class="lg:col-span-1">
                    <div class="sticky overflow-hidden bg-white border border-gray-300 rounded-lg shadow-md top-8">
                        <div class="p-3 border-gray-300">
                            <h3 class="text-lg font-semibold text-gray-900">แผนที่เส้นทาง</h3>
                            <p class="mt-1 text-sm text-gray-600">
                                {{ selectedLabel ? selectedLabel : 'คลิกที่รายการเพื่อดูเส้นทาง' }}
                            </p>
                        </div>
                        <div ref="mapContainer" id="map"></div>
                    </div>
                </div>
            </div>
        </div>

                        <ConfirmModal 
                    :show="isModalVisible" 
                    :title="modalContent.title" 
                    :message="modalContent.message"
                    :confirmText="modalContent.confirmText" 
                    :variant="modalContent.variant" 
                    @confirm="handleConfirmAction"
                    
                    @cancel="closeConfirmModal" 
                />

                    <ConfirmModal 
                :show="isConfirmModalVisible" 
                :title="modalMode === 'start' ? 'ยืนยันการเริ่มเดินทาง' : 'การเดินทางเสร็จสิ้น'" 
                :message="modalMode === 'start' 
                    ? 'คุณพร้อมที่จะเริ่มต้นการเดินทางในเส้นทางนี้ใช่หรือไม่?' 
                    : 'คุณได้เดินทางถึงจุดหมายปลายทางเรียบร้อยแล้ว ขอบคุณที่ใช้บริการ'"
                :confirmText="isProcessing ? 'กำลังบันทึก...' : (modalMode === 'start' ? 'เริ่มเดินทาง' : 'ตกลง')" 
                :variant="modalMode === 'start' ? 'primary' : 'primary'"
                :cancelText="modalMode === 'start' ? 'ยกเลิก' : null " 
                @confirm="handleConfirmModal" 
                @cancel="closeTripActionModal" 
            />
    </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted, watch } from 'vue'
import dayjs from 'dayjs'
import 'dayjs/locale/th'
import buddhistEra from 'dayjs/plugin/buddhistEra'
import ConfirmModal from '~/components/ConfirmModal.vue'
import { useToast } from '~/composables/useToast'

dayjs.locale('th')
dayjs.extend(buddhistEra)

const { $api } = useNuxtApp()
const { toast } = useToast()

let directionsService = null;
let activePolylines = []; // เก็บเส้น Polyline ที่วาดบนแผนที่ (เพื่อลบออกเมื่อเปลี่ยนสเตป)
let infoWindow = null; // สำหรับแสดงป้ายเวลาเมื่อกดที่เส้น

// --- State Management ---
const activeTab = ref('pending')
const selectedTripId = ref(null)
const isLoading = ref(false)
const mapContainer = ref(null)
const allTrips = ref([])
const myRoutes = ref([])

// --- ต่อท้าย State Management เดิม ---

const tripStates = ref({}); 
const isProcessing = ref(false);
let pollingInterval = null

// --- State Trip---
const getTripState = (routeId) => {
    if (!tripStates.value[routeId]) {
        tripStates.value[routeId] = { started: false, currentIndex: 0 };
    }
    return tripStates.value[routeId];
};
// --- Route timeline---
const getRouteTimeline = (t) => {
    if (!t) return [];
    let timeline = [];

    // 1. จุดเริ่มต้น (Origin)
    timeline.push({ 
        name: t.origin, 
        address: t.originAddress, 
        type: 'origin',
        isPassengerPoint: false 
    });

    // 2. จุดแวะพัก และ จุดรับ-ส่ง (Stops & Passenger Points)
    if (t.stopsCoords && Array.isArray(t.stopsCoords)) {
        t.stopsCoords.forEach((stop) => {
            timeline.push({
                name: stop.name,
                address: stop.address,
                type: 'stop',
                // ส่งต่อ Flag และข้อมูลผู้โดยสาร
                isPassengerPoint: !!stop.isPassengerPoint,
                passengerName: stop.passengerName, // สำหรับกรณีคนเดียว (Fallback)
                actionType: stop.actionType,       // สำหรับกรณีคนเดียว (Fallback)
                passengerList: stop.passengerList || [] // ข้อมูลผู้โดยสารแบบกลุ่ม (สำคัญมาก!)
            });
        });
    }

    // จุดปลายทาง (Destination)
    timeline.push({ 
        name: t.destination, 
        address: t.destinationAddress, 
        type: 'destination',
        isPassengerPoint: false 
    });

    return timeline;
};



// แก้ไขฟังก์ชัน Checkpoint ให้รองรับการจบการเดินทาง
// สูตรคำนวณระยะห่างระหว่างพิกัด 2 จุด (คืนค่าเป็นเมตรเพราะระยะห่างไม่่เกิน500เมตร)
const calculateDistance = (lat1, lon1, lat2, lon2) => {
    const R = 6371e3; // รัศมีโลก(เมตร)
    const dLat = (lat2 - lat1) * Math.PI / 180;
    const dLon = (lon2 - lon1) * Math.PI / 180;
    const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
              Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
              Math.sin(dLon / 2) * Math.sin(dLon / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c; 
};

const handleCheckPoint = async (routeId, routeData) => {
    const state = getTripState(routeId);
    const timeline = getRouteTimeline(routeData);

    const currentPoint = timeline[state.currentIndex];
    const nextIndex = state.currentIndex + 1;
    const nextPoint = timeline[nextIndex];

    if (!currentPoint || !nextPoint) return;

    const route = myRoutes.value.find(r => r.id === routeId);
    const pickupsHere = (currentPoint.passengerList || []).filter(pl => pl.action === 'pickup');

    if (pickupsHere.length > 0) {
        const pendingPickups = pickupsHere.filter(pl => {
            const passenger = route?.passengers?.find(p => p.name === pl.name);
            if (!passenger) return true;


            const st = (passenger.passengerStatus || '').toLowerCase().replace(/_/g, '');
            const accepted = ['waitingpickup', 'intransit', 'arrived'];
            return !accepted.includes(st);
        });

        if (pendingPickups.length > 0) {
            toast.error(
                'ยังรับผู้โดยสารไม่ครบ',
                `กรุณากดรับผู้โดยสารก่อนเดินทางต่อ:\n${pendingPickups.map(p => `• ${p.name}`).join('\n')}`
            );
            return; 
        }
    }

    let currentLat, currentLng;

    if (currentPoint.type === 'origin') {
        currentLat = Number(routeData.coords[0][0]);
        currentLng = Number(routeData.coords[0][1]);
    } else if (currentPoint.type === 'destination') {
        currentLat = Number(routeData.coords[1][0]);
        currentLng = Number(routeData.coords[1][1]);
    } else {
        const stopIndex = state.currentIndex - 1;
        currentLat = Number(routeData.stopsCoords[stopIndex]?.lat);
        currentLng = Number(routeData.stopsCoords[stopIndex]?.lng);
    }

    try {
        isProcessing.value = true;

        const position = await new Promise((resolve, reject) => {
            navigator.geolocation.getCurrentPosition(resolve, reject, {
                enableHighAccuracy: true,
                timeout: 10000
            });
        });
        const { latitude, longitude } = position.coords;

        const distance = calculateDistance(latitude, longitude, currentLat, currentLng);
        if (distance > 500) {
            toast.error(
                'คุณไม่อยู่ในพื้นที่',
                `ต้องเช็คอินที่ [${currentPoint.name}] ในรัศมี 500 ม.\n(ปัจจุบันห่าง ${Math.round(distance)} ม.)`
            );
            return;
        }

        const dropoffsAtNext = (nextPoint.passengerList || []).filter(pl => pl.action === 'dropoff');
        for (const pl of dropoffsAtNext) {
            // ดึง route ใหม่อีกครั้งให้ได้ข้อมูลสด
            const freshRoute = myRoutes.value.find(r => r.id === routeId);
            const passenger = freshRoute?.passengers?.find(p => p.name === pl.name);
            const st = (passenger?.passengerStatus || '').toLowerCase().replace(/_/g, '');
            if (st === 'intransit') {
                try {
                    await $api(`/bookings/${passenger.id}/driver-reached-dropoff`, { method: 'PATCH' });
                } catch (e) {
                    console.warn(`driver-reached-dropoff failed for ${pl.name}:`, e);
                }
            }
        }
        const isLastStep = nextIndex >= timeline.length - 1;
        const nextStatus = isLastStep ? 'COMPLETED' : 'IN_TRANSIT';

        await $api(`/routes/${routeId}/progress`, {
            method: 'PATCH',
            body: { currentStep: nextIndex, status: nextStatus }
        });

        if (!isLastStep) {
            state.currentIndex = nextIndex;
            state.status = 'IN_TRANSIT';
            toast.success('Check-in สำเร็จ', `ออกจาก ${currentPoint.name} → มุ่งหน้า ${nextPoint.name}`);
            updateMap(routeData);
        } else {
            state.completed = true;
            state.started = false;
            state.currentIndex = nextIndex;
            state.status = 'COMPLETED';
            updateMap(routeData);
            modalMode.value = 'complete';
            pendingRouteId.value = routeId;
            isConfirmModalVisible.value = true;
            toast.success('ถึงจุดหมายปลายทางแล้ว', `สิ้นสุดการเดินทางที่: ${nextPoint.name}`);
        }

    } catch (error) {
        console.error('Checkpoint error:', error);
        const errorMsg = error.code === 1
            ? 'กรุณาอนุญาตการเข้าถึงพิกัด GPS'
            : 'ไม่สามารถเชื่อมต่อ Server ได้';
        toast.error('เกิดข้อผิดพลาด', errorMsg);
    } finally {
        isProcessing.value = false;
    }
};

// --- ส่วนจัดการ Modal ---
const isConfirmModalVisible = ref(false);
const pendingRouteId = ref(null);
const modalMode = ref('start'); 

// ฟังก์ชันModal สำหรับเริ่มเดินทาง
const triggerStartTrip = (routeId) => {
    modalMode.value = 'start';
    pendingRouteId.value = routeId;
    isConfirmModalVisible.value = true;
};

// ฟังก์ชันเมื่อกดยืนยันใน Modal
const handleConfirmModal = async () => {
    if (!pendingRouteId.value) return;

    try {
        isProcessing.value = true;
        const state = getTripState(pendingRouteId.value);

        // --- เริ่มต้นการเดินทาง (Start Trip) ---
        if (modalMode.value === 'start') {
            // เริ่ม0
            await $api(`/routes/${pendingRouteId.value}/progress`, { 
                method: 'PATCH',
                body: {
                    currentStep: 0,
                    status: 'IN_TRANSIT'
                }
            });

            // อัปเดต UI State
            state.started = true;
            state.completed = false;
            state.currentIndex = 0;
            state.status = 'IN_TRANSIT';
            
            toast.success('สำเร็จ', 'เริ่มต้นการเดินทางแล้ว! ขอให้เดินทางโดยสวัสดิภาพ');
        } 
        
        // --- สิ้นสุดการเดินทาง--
        else if (modalMode.value === 'complete') { 
            // อัปเดตสถานะใน Backend เป็น COMPLETED เตรียมทำreviewได้
            await $api(`/routes/${pendingRouteId.value}/progress`, { 
                method: 'PATCH',
                body: {
                    currentStep: state.currentIndex,
                    status: 'COMPLETED'
                }
            });

           
            state.started = false;
            state.completed = true;
            state.status = 'COMPLETED';

            toast.success('สำเร็จ', 'ระบบบันทึกการสิ้นสุดการเดินทางเรียบร้อยแล้ว');
        }

        
        closeTripActionModal(); 
        
    } catch (error) {
        console.error('Modal Action Error:', error);
        const action = modalMode.value === 'start' ? 'เริ่มเดินทาง' : 'บันทึกการสิ้นสุดการเดินทาง';
        toast.error('เกิดข้อผิดพลาด', `ไม่สามารถ ${action} ได้ในขณะนี้`);
    } finally {
        isProcessing.value = false;
    }
};

// ฟังก์ชันปิด Modal
const closeTripActionModal = () => {
    isConfirmModalVisible.value = false;
    pendingRouteId.value = null;
};

//  เพิ่ม Computed สำหรับจัดลำดับ My Routes ลำดับการแสดงผล ลำดับการ source
const sortedMyRoutes = computed(() => {
  return [...myRoutes.value].sort((a, b) => {
    const stateA = getTripState(a.id);
    const stateB = getTripState(b.id);


    if (stateA.completed && !stateB.completed) return 1;

    if (!stateA.completed && stateB.completed) return -1;
    
    return 0;
  });
});

// ---------- Google Maps states ----------
let gmap = null
let activePolyline = null
let startMarker = null
let endMarker = null
let geocoder = null
let placesService = null
const mapReady = ref(false)
const GMAPS_CB = '__gmapsReady__'
// NEW: เก็บหมุดจุดแวะ
let stopMarkers = []

const tabs = [
    { status: 'pending', label: 'รอดำเนินการ' },
    { status: 'confirmed', label: 'ยืนยันแล้ว' },
    { status: 'rejected', label: 'ปฏิเสธ' },
    { status: 'cancelled', label: 'ยกเลิก' },
    { status: 'all', label: 'ทั้งหมด' },
    { status: 'myRoutes', label: 'เส้นทางของฉัน' },
]

definePageMeta({ middleware: 'auth' })

// --- Helpers ---
function cleanAddr(a) {
    return (a || '')
        .replace(/,?\s*(Thailand|ไทย|ประเทศ)\s*$/i, '')
        .replace(/\s{2,}/g, ' ')
        .trim()
}

const reasonLabelMap = {
    CHANGE_OF_PLAN: 'เปลี่ยนแผน/มีธุระกะทันหัน',
    FOUND_ALTERNATIVE: 'พบวิธีเดินทางอื่นแล้ว',
    DRIVER_DELAY: 'คนขับล่าช้าหรือเลื่อนเวลา',
    PRICE_ISSUE: 'ราคาหรือค่าใช้จ่ายไม่เหมาะสม',
    WRONG_LOCATION: 'เลือกจุดรับ–ส่งผิด',
    DUPLICATE_OR_WRONG_DATE: 'จองซ้ำหรือจองผิดวัน',
    SAFETY_CONCERN: 'กังวลด้านความปลอดภัย',
    WEATHER_OR_FORCE_MAJEURE: 'สภาพอากาศ/เหตุสุดวิสัย',
    COMMUNICATION_ISSUE: 'สื่อสารไม่สะดวก/ติดต่อไม่ได้',
}
function reasonLabel(v) { return reasonLabelMap[v] || v }

// --- Computed ---
const filteredTrips = computed(() => {
    if (activeTab.value === 'all') return allTrips.value
    return allTrips.value.filter(trip => trip.status === activeTab.value)
})

// สำหรับหัวข้อบนแผนที่
const selectedLabel = computed(() => {
    if (activeTab.value === 'myRoutes') {
        const r = myRoutes.value.find(x => x.id === selectedTripId.value)
        return r ? `${r.origin} → ${r.destination}` : null
    }
    const t = allTrips.value.find(x => x.id === selectedTripId.value)
    return t ? `${t.origin} → ${t.destination}` : null
})

// --- Methods ---
async function fetchMyRoutes() {
    isLoading.value = true
    try {
        const routes = await $api('/routes/me')
        const allowedRouteStatuses = new Set(['AVAILABLE', 'FULL', 'IN_TRANSIT', 'COMPLETED'])
        const formatted = []
        const ownRoutes = []

        for (const r of routes) {
            const carDetailsList = []
            const routeStatus = String(r.status || '').toUpperCase()
            
            if (!allowedRouteStatuses.has(routeStatus)) continue

            tripStates.value[r.id] = {
                started: routeStatus === 'IN_TRANSIT',
                completed: routeStatus === 'COMPLETED',
                currentIndex: r.currentStep || 0, 
                status: routeStatus
            }

            if (r.vehicle) {
                carDetailsList.push(`${r.vehicle.vehicleModel} (${r.vehicle.vehicleType})`)
                if (Array.isArray(r.vehicle.amenities) && r.vehicle.amenities.length > 0) {
                    carDetailsList.push(...r.vehicle.amenities)
                }
            } else {
                carDetailsList.push('ไม่มีข้อมูลรถ')
            }

            const start = r.startLocation
            const end = r.endLocation
            const coords = [[start.lat, start.lng], [end.lat, end.lng]]

            const wp = r.waypoints || {}
            const baseList = (Array.isArray(wp.used) && wp.used.length ? wp.used : Array.isArray(wp.requested) ? wp.requested : [])
            const orderedList = (Array.isArray(wp.optimizedOrder) && wp.optimizedOrder.length === baseList.length)
                ? wp.optimizedOrder.map(i => baseList[i])
                : baseList

            // --- [1. เตรียมข้อมูลพิกัดและจุดจอด] ---
            const originLatLng = { lat: Number(start.lat), lng: Number(start.lng) };
            let allPotentialStops = [...orderedList.map(p => ({ ...p, isOriginal: true }))];

            const confirmedBookings = (r.bookings || []).filter(
                b => (b.status || '').toUpperCase() === 'CONFIRMED'
            );

            confirmedBookings.forEach(b => {
                const pName = `${b.passenger?.firstName || ''} ${b.passenger?.lastName || ''}`.trim() || 'ผู้โดยสาร';
                if (b.pickupLocation) {
                    allPotentialStops.push({ 
                        lat: Number(b.pickupLocation.lat), 
                        lng: Number(b.pickupLocation.lng), 
                        name: b.pickupLocation.name, 
                        address: b.pickupLocation.address,
                        isPassengerPoint: true,
                        passengerName: pName,
                        actionType: 'pickup'
                    });
                }
                if (b.dropoffLocation) {
                    allPotentialStops.push({ 
                        lat: Number(b.dropoffLocation.lat), 
                        lng: Number(b.dropoffLocation.lng), 
                        name: b.dropoffLocation.name, 
                        address: b.dropoffLocation.address,
                        isPassengerPoint: true,
                        passengerName: pName,
                        actionType: 'dropoff'
                    });
                }
            });

            // --- [2. กรองจุดซ้ำและรวมกลุ่มรายชื่อผู้โดยสาร] ---
            const filteredStops = [];
            allPotentialStops.forEach(current => {
                const isAtStartOrEnd = 
                    calculateDistance(current.lat, current.lng, start.lat, start.lng) < 15 ||
                    calculateDistance(current.lat, current.lng, end.lat, end.lng) < 15;
                
                const existingStopIndex = filteredStops.findIndex(existing => 
                    calculateDistance(current.lat, current.lng, existing.lat, existing.lng) < 15
                );

                if (existingStopIndex > -1) {
                    if (current.isPassengerPoint) {
                        if (!filteredStops[existingStopIndex].passengerList) {
                            filteredStops[existingStopIndex].passengerList = [
                                { name: filteredStops[existingStopIndex].passengerName, action: filteredStops[existingStopIndex].actionType }
                            ];
                        }
                        filteredStops[existingStopIndex].passengerList.push({ name: current.passengerName, action: current.actionType });
                    }
                } else if (!isAtStartOrEnd) {
                    filteredStops.push({
                        ...current,
                        passengerList: current.isPassengerPoint ? [{ name: current.passengerName, action: current.actionType }] : null
                    });
                }
            });

                            
                                const sortedStops = filteredStops.sort((a, b) => {
                    // 1. ถ้าเป็นผู้โดยสารจองเดียวกัน (Booking เดียวกัน)
                    // บังคับให้ Pickup ต้องมาก่อน Dropoff เสมอ โดยไม่สนระยะทาง
                    if (a.bookingId === b.bookingId && a.bookingId !== undefined) {
                        if (a.actionType === 'pickup' && b.actionType === 'dropoff') return -1;
                        if (a.actionType === 'dropoff' && b.actionType === 'pickup') return 1;
                    }

                    // 2. ถ้าเป็นคนละ Booking หรือเป็น Waypoint ทั่วไป
                    // ให้เรียงตามระยะทางจากจุดเริ่มต้น (Origin) ตามปกติ
                    const distA = calculateDistance(originLatLng.lat, originLatLng.lng, a.lat, a.lng);
                    const distB = calculateDistance(originLatLng.lat, originLatLng.lng, b.lat, b.lng);
                    return distA - distB;
                });
            const finalStopsCoords = sortedStops;
            const finalStopsNames = finalStopsCoords.map(p => {
                if (p.passengerList && p.passengerList.length > 0) {
                    const names = p.passengerList.map(pl => `${pl.action === 'pickup' ? 'รับ' : 'ส่ง'}คุณ ${pl.name}`).join(' และ ');
                    return `${p.name} (${names})`;
                }
                return p.name || '';
            }).filter(Boolean);

            // ข้อมูลสำหรับแท็บ รอดำเนินการ, ยืนยันแล้ว, ทั้งหมด
            for (const b of (r.bookings || [])) {
                    formatted.push({
                        id: b.id,
                        status: (b.status || '').toLowerCase(),
                        
                        // ข้อมูลสถานที่หลักของทริป
                        origin: start?.name || 'ต้นทาง',
                        destination: end?.name || 'ปลายทาง',
                        originAddress: cleanAddr(start?.address),
                        destinationAddress: cleanAddr(end?.address),
                        
                        //  จุดนัดพบและจุดส่งรายบุคคล 
                        pickupPoint: b.pickupLocation?.name || 'จุดรับตามตกลง',
                        dropoffPoint: b.dropoffLocation?.name || 'จุดส่งตามตกลง',
                        
                        // วันที่และเวลา
                        date: dayjs(r.departureTime).format('D MMMM BBBB'),
                        time: dayjs(r.departureTime).format('HH:mm น.'),
                        
                        // ราคาและที่นั่ง
                        price: (r.pricePerSeat || 0) * (b.numberOfSeats || 1),
                        seats: b.numberOfSeats || 1,
                        
                        //  ข้อมูลผู้โดยสาร
                        passenger: {
                            name: `${b.passenger?.firstName || ''} ${b.passenger?.lastName || ''}`.trim() || 'ผู้โดยสาร',
                            image: b.passenger?.profilePicture || `https://ui-avatars.com/api/?name=${encodeURIComponent(b.passenger?.firstName || 'P')}&background=random&size=64`,
                            isVerified: !!b.passenger?.isVerified,
                        },
                        
                        coords,
                        stops: finalStopsNames,
                        stopsCoords: finalStopsCoords,
                        carDetails: carDetailsList, // ใส่ไว้เพื่อกัน Error carDetails undefined
                        
                        durationText: (typeof r.duration === 'string' ? formatDuration(r.duration) : r.duration) || '-',
                        distanceText: (typeof r.distance === 'string' ? formatDistance(r.distance) : r.distance) || '-',
                        
                        tripStatus: r.status,
                        currentStep: r.currentStep || 0,
                        cancelReason: b.cancelReason || null
                    });
                }

            // --- [4. ข้อมูลสำหรับแท็บ "เส้นทางของฉัน" (ไม่แสดงราคารายคน)] ---
            ownRoutes.push({
                id: r.id,
                status: routeStatus.toLowerCase(),
                currentStep: r.currentStep || 0,
                origin: start?.name || 'ต้นทาง',
                destination: end?.name || 'ปลายทาง',
                originAddress: cleanAddr(start.address),
                destinationAddress: cleanAddr(end.address),
                date: dayjs(r.departureTime).format('D MMMM BBBB'),
                time: dayjs(r.departureTime).format('HH:mm น.'),
                pricePerSeat: r.pricePerSeat || 0,
                availableSeats: r.availableSeats ?? 0,
                coords,
                stops: finalStopsNames,
                stopsCoords: finalStopsCoords,
                carDetails: carDetailsList,
                passengers: confirmedBookings.map(b => ({
                id: b.id,
                seats: b.numberOfSeats || 1,
                status: (b.status || 'confirmed').toLowerCase(),
                //เพิ่ม field ใหม่
                passengerStatus: b.passengerStatus || null,
                driverCancelRequest: b.driverCancelRequest || false,
                reachedDropoff: b.reachedDropoff || false,
                name: `${b.passenger?.firstName || ''} ${b.passenger?.lastName || ''}`.trim(),
                image: b.passenger?.profilePicture || `https://ui-avatars.com/api/?name=${encodeURIComponent(b.passenger?.firstName || 'P')}&background=random&size=64`,
                pickupName: b.pickupLocation?.name || 'จุดรับตามตกลง',
                dropoffName: b.dropoffLocation?.name || 'จุดส่งตามตกลง',
                isVerified: !!b.passenger?.isVerified,
            })),
                durationText: (typeof r.duration === 'string' ? formatDuration(r.duration) : r.duration) || (r.durationSeconds ? `${Math.round(r.durationSeconds / 60)} นาที` : '-'),
                distanceText: (typeof r.distance === 'string' ? formatDistance(r.distance) : r.distance) || (r.distanceMeters ? `${(r.distanceMeters / 1000).toFixed(1)} กม.` : '-'),
            });
        }

        allTrips.value = formatted;
        myRoutes.value = ownRoutes;
        await waitMapReady();

    } catch (error) {
        console.error('Failed to fetch routes:', error)
        allTrips.value = []
        myRoutes.value = []
        toast.error('เกิดข้อผิดพลาด', error?.data?.message || 'ไม่สามารถโหลดข้อมูลได้')
    } finally {
        isLoading.value = false
    }
}

const getTripCount = (status) => {
    if (status === 'all') return allTrips.value.length
    if (status === 'myRoutes') return myRoutes.value.length
    return allTrips.value.filter(trip => trip.status === status).length
}

const toggleTripDetails = (id) => {
    const item = activeTab.value === 'myRoutes'
        ? myRoutes.value.find(r => r.id === id)
        : allTrips.value.find(t => t.id === id)
    if (item) updateMap(item)

    selectedTripId.value = (selectedTripId.value === id) ? null : id
}

async function updateMap(trip) {
    if (!trip) return;
    await waitMapReady();
    if (!gmap) return;

    //เคลียร์แผนที่เดิม
    if (activePolyline) { activePolyline.setMap(null); activePolyline = null; }
    if (activePolylines && activePolylines.length) {
        activePolylines.forEach(p => p.setMap(null));
        activePolylines = [];
    }
    if (startMarker) { startMarker.setMap(null); startMarker = null; }
    if (endMarker) { endMarker.setMap(null); endMarker = null; }
    if (stopMarkers.length) {
        stopMarkers.forEach(m => m.setMap(null));
        stopMarkers = [];
    }
    if (infoWindow) infoWindow.close();
    else infoWindow = new google.maps.InfoWindow();

    if (!directionsService) directionsService = new google.maps.DirectionsService();

    const state = getTripState(trip.id);
    const timeline = getRouteTimeline(trip);

    // กำหนดจุด Origin และ Destination 
    let originLatLng, destLatLng, prevIndex, targetIndex;

    // ภาพรวม
    if (!state.started || state.completed || state.currentIndex === 0) {
        originLatLng = { lat: Number(trip.coords[0][0]), lng: Number(trip.coords[0][1]) };
        destLatLng = { lat: Number(trip.coords[1][0]), lng: Number(trip.coords[1][1]) };
        prevIndex = 0; 
        targetIndex = timeline.length - 1; 
    } 
    // นำทางทีละช่วง
    else {
        prevIndex = state.currentIndex - 1;
        targetIndex = state.currentIndex;
        originLatLng = getLatLngFromTimeline(trip, prevIndex);
        destLatLng = getLatLngFromTimeline(trip, targetIndex);
    }

    if (!originLatLng || !destLatLng) return;

    // Marker A และ B
    startMarker = new google.maps.Marker({
        position: originLatLng,
        map: gmap,
        label: { text: 'A', color: 'white' },
        title: timeline[prevIndex].name,
        zIndex: 100
    });

    endMarker = new google.maps.Marker({
        position: destLatLng,
        map: gmap,
        label: { text: 'B', color: 'white' },
        title: timeline[targetIndex].name,
        zIndex: 100
    });
        if (!state.started || state.completed) {
    (trip.stopsCoords || []).forEach((s, idx) => {
        const m = new google.maps.Marker({
            position: { lat: Number(s.lat), lng: Number(s.lng) },
            map: gmap,
            icon: {
                url: 'https://maps.google.com/mapfiles/ms/icons/green-dot.png'
            },
            title: s.name,
            zIndex: 50
        });
        stopMarkers.push(m);
    });
}
    // Request 2 แบบ (ปกติ และเลี่ยงทางด่วน) เพื่อให้ได้เส้นทางที่หลากหลายมากขึ้น กว่าจะเจอ
    const stopWaypoints = (!state.started || state.completed)
    ? (trip.stopsCoords || []).map(s => ({
        location: { lat: Number(s.lat), lng: Number(s.lng) },
        stopover: true
    }))
    : [];

const baseRequest = {
    origin: originLatLng,
    destination: destLatLng,
    waypoints: stopWaypoints,
    optimizeWaypoints: false, // ไม่ให้สลับลำดับ เพราะเราเรียงเองแล้ว
    travelMode: google.maps.TravelMode.DRIVING,
    provideRouteAlternatives: stopWaypoints.length === 0, // ขอทางเลือกเฉพาะตอนไม่มี waypoints
};

    const requests = [
        //  ปกติ
        directionsService.route(baseRequest),
        // เลี่ยงทางด่วน 
        directionsService.route({ ...baseRequest, avoidHighways: true })
    ];

    try {
        // ยิง API พร้อมกัน 2 ตัว ปล.ใช้ Promise.allSettled เพื่อกัน error ตัวใดตัวหนึ่งทำให้อีกตัวพัง
        const results = await Promise.allSettled(requests);
        
        let mergedRoutes = [];
        
        // รวบรวมเส้นทางที่ได้ทั้งหมด
        results.forEach(res => {
            if (res.status === 'fulfilled' && res.value.status === 'OK') {
                mergedRoutes.push(...res.value.routes);
            }
        });

        // กรองเส้นทางที่ซ้ำกันออก เช็คจาก overview_polyline
        const uniqueRoutes = [];
        const seenPolylines = new Set();

        mergedRoutes.forEach(route => {
            if (!seenPolylines.has(route.overview_polyline)) {
                seenPolylines.add(route.overview_polyline);
                uniqueRoutes.push(route);
            }
        });

        if (uniqueRoutes.length === 0) {
            console.warn('ไม่พบเส้นทางใดๆ');
            // Fallback เส้นตรง
             activePolyline = new google.maps.Polyline({
                path: [originLatLng, destLatLng],
                map: gmap,
                strokeColor: '#ef4444',
                strokeWeight: 4
            });
            return;
        }

        // วาดเส้นทางทั้งหมดลงแผนที่
        const bounds = new google.maps.LatLngBounds();
        
        uniqueRoutes.forEach((route, index) => {
            // ลงสี
            const isPrimary = index === 0;
            
            const polyline = new google.maps.Polyline({
                path: route.overview_path,
                map: gmap,
                
                strokeColor: isPrimary ? '#2563eb' : (route.warnings && route.warnings.length ? '#d97706' : '#9ca3af'), 
                strokeOpacity: isPrimary ? 1.0 : 0.6,
                strokeWeight: isPrimary ? 7 : 5,
                zIndex: isPrimary ? 100 : (50 - index), //เส้นหลักอยู่บนสุด เห็นชัด
                cursor: 'pointer'
            });

            if (!activePolylines) activePolylines = [];
            activePolylines.push(polyline);

            
            google.maps.event.addListener(polyline, 'click', (e) => {
                const leg = route.legs[0];
                
                const warningMsg = (route.warnings && route.warnings.length) ? `<br><span class="text-xs text-orange-600">(${route.warnings.join(', ')})</span>` : '';
                
                const content = `
                    <div class="text-center p-2">
                        <p class="font-bold text-gray-800 text-sm mb-1">ทางเลือกที่ ${index + 1}</p>
                        <p class="font-bold text-indigo-600 text-lg">${leg.duration.text}</p>
                        <p class="text-gray-500 text-xs mb-2">${leg.distance.text}${warningMsg}</p>
                        <a href="https://www.google.com/maps/dir/?api=1&origin=${originLatLng.lat},${originLatLng.lng}&destination=${destLatLng.lat},${destLatLng.lng}&travelmode=driving" 
                           target="_blank"
                           class="inline-block px-3 py-1 bg-blue-600 text-white text-xs rounded shadow hover:bg-blue-700 transition">
                           เปิด Google Maps ↗
                        </a>
                    </div>`;
                infoWindow.setContent(content);
                infoWindow.setPosition(e.latLng);
                infoWindow.open(gmap);
                
                // ไฮไลท์เส้นที่ถูกคลิก
                activePolylines.forEach((p, i) => {
                    if (i === index) {
                        p.setOptions({ strokeColor: '#2563eb', zIndex: 100, strokeOpacity: 1.0 });
                    } else {
                        p.setOptions({ strokeColor: '#9ca3af', zIndex: 10, strokeOpacity: 0.5 });
                    }
                });
            });

            route.overview_path.forEach(p => bounds.extend(p));
        });

        gmap.fitBounds(bounds);

    } catch (error) {
        console.error('Error fetching routes:', error);
    }
}
const getLatLngFromTimeline = (trip, index) => {
    const timeline = getRouteTimeline(trip);
    const point = timeline[index];

    if (!point) return null;

    let lat, lng;

    if (point.type === 'origin') {
        lat = Number(trip.coords[0][0]);
        lng = Number(trip.coords[0][1]);
    } else if (point.type === 'destination') {
        lat = Number(trip.coords[1][0]);
        lng = Number(trip.coords[1][1]);
    } else if (point.type === 'stop') {
        const stopIndex = index - 1;
        if (trip.stopsCoords && trip.stopsCoords[stopIndex]) {
            lat = Number(trip.stopsCoords[stopIndex].lat);
            lng = Number(trip.stopsCoords[stopIndex].lng);
        }
    }

    if (lat && lng) return { lat, lng };
    return null;
};

//  คนขับกดรับผู้โดยสาร
const handlePassengerPickup = async (routeId, passenger) => {
    modalContent.value = {
        title: 'ยืนยันการรับผู้โดยสาร',
        message: `ยืนยันว่าคุณรับคุณ "${passenger.name}" ขึ้นรถแล้วใช่หรือไม่?`,
        confirmText: 'ยืนยัน รับผู้โดยสาร',
        action: 'driver-arrived',
        variant: 'primary',
        payload: { bookingId: passenger.id }
    }
    tripToAction.value = passenger
    isModalVisible.value = true
}

// คนขับขอยกเลิกการเดินทางของผู้โดยสารคนนั้น
const handleDriverCancelRequest = async (routeId, passenger) => {
    modalContent.value = {
        title: 'ยืนยันการยกเลิกการเดินทาง',
        message: `คุณต้องการยกเลิกการเดินทางของคุณ "${passenger.name}" ใช่หรือไม่?\nระบบจะแจ้งเตือนให้ผู้โดยสารยืนยันการยกเลิก`,
        confirmText: 'ยืนยัน ส่งคำขอยกเลิก',
        action: 'driver-cancel-request',
        variant: 'danger',
        payload: { bookingId: passenger.id }
    }
    tripToAction.value = passenger
    isModalVisible.value = true
}

//  Polling ดึงข้อมูลใหม่
const startPolling = () => {
    stopPolling()
    
    let lastUnreadCount = 0 

    pollingInterval = setInterval(async () => {
        //  ไม่ต้องยิง API ถ้าผู้ใช้ไม่ได้เปิดหน้าเว็บทิ้งไว้ (Visibility API)
        // ช่วยลด Requests ได้มหาศาลและป้องกัน 429
        if (document.visibilityState !== 'visible') return

        // ช็คว่ามีเส้นทางที่กำลังดำเนินการอยู่หรือไม่
        const activeTripStates = Object.values(tripStates.value)
        const hasActiveRoute = activeTripStates.some(s => s.started && !s.completed)
        
        if (!hasActiveRoute) return

        try {
            // ดึงจำนวนแจ้งเตือนที่ยังไม่ได้อ่าน
            const response = await $api('/notifications/unread-count')
            
            // ป้องกันโครงสร้างข้อมูลผิดพลาด 
            const currentCount = response?.data?.count ?? response?.count ?? 0

            
            // ถ้าแจ้งเตือนเพิ่มขึ้น แสดงว่ามี Event ใหม่ 
            if (currentCount > lastUnreadCount) {
                console.log('New event detected. Refreshing routes...')
                lastUnreadCount = currentCount
                await fetchMyRoutes() // โหลดข้อมูลใหม่ทั้งหมดเพื่อให้ UI อัปเดต
            } 
            // ถ้าจำนวนลดลง (ผู้ใช้กดอ่านแล้ว) ให้บันทึกค่าใหม่แต่ไม่ต้อง fetch ข้อมูลใหญ่
            else if (currentCount < lastUnreadCount) {
                lastUnreadCount = currentCount
            }

        } catch (error) {
            // 4. จัดการ Error เฉพาะจุด
            if (error.response?.status === 429) {
                console.error(' Rate limit hit. Stopping polling temporarily.')
                stopPolling() // หยุดชั่วคราวถ้าโดนบล็อก
            } else {
                console.warn('Syncing notifications failed:', error.message)
            }
        }
    }, 20000)
}

const stopPolling = () => {
    if (pollingInterval) {
        clearInterval(pollingInterval)
        pollingInterval = null
    }
}

// ---------- Google Maps helpers ----------
function waitMapReady() {
    return new Promise((resolve) => {
        if (mapReady.value) return resolve(true)
        const t = setInterval(() => {
            if (mapReady.value) { clearInterval(t); resolve(true) }
        }, 50)
    })
}

function reverseGeocode(lat, lng) {
    return new Promise((resolve) => {
        if (!geocoder) return resolve(null)
        geocoder.geocode({ location: { lat, lng } }, (results, status) => {
            if (status !== 'OK' || !results?.length) return resolve(null)
            resolve(results[0])
        })
    })
}

async function extractNameParts(geocodeResult) {
    if (!geocodeResult) return { name: null, area: null }
    const comps = geocodeResult.address_components || []
    const types = geocodeResult.types || []
    const isPoi = types.includes('point_of_interest') || types.includes('establishment') || types.includes('premise')

    let name = null
    if (isPoi && geocodeResult.place_id) {
        const poiName = await getPlaceName(geocodeResult.place_id)
        if (poiName) name = poiName
    }
    if (!name) {
        const streetNumber = comps.find(c => c.types.includes('street_number'))?.long_name
        const route = comps.find(c => c.types.includes('route'))?.long_name
        name = (streetNumber && route) ? `${streetNumber} ${route}` : (route || geocodeResult.formatted_address || null)
    }
    if (name) name = name.replace(/,?\s*(Thailand|ไทย)\s*$/i, '')
    return { name }
}

function getPlaceName(placeId) {
    return new Promise((resolve) => {
        if (!placesService || !placeId) return resolve(null)
        placesService.getDetails({ placeId, fields: ['name'] }, (place, status) => {
            if (status === google.maps.places.PlacesServiceStatus.OK && place?.name) resolve(place.name)
            else resolve(null)
        })
    })
}


// --- Modal ---
const isModalVisible = ref(false)
const tripToAction = ref(null)
const modalContent = ref({ title: '', message: '', confirmText: '', action: null, variant: 'danger' })

const openConfirmModal = (trip, action) => {
    tripToAction.value = trip
    if (action === 'confirm') {
        modalContent.value = {
            title: 'ยืนยันคำขอจอง',
            message: `ยืนยันคำขอของผู้โดยสาร "${trip.passenger.name}" ใช่หรือไม่?`,
            confirmText: 'ยืนยันคำขอ',
            action: 'confirm',
            variant: 'primary',
        }
    } else if (action === 'reject') {
        modalContent.value = {
            title: 'ปฏิเสธคำขอจอง',
            message: `ต้องการปฏิเสธคำขอของ "${trip.passenger.name}" ใช่หรือไม่?`,
            confirmText: 'ปฏิเสธ',
            action: 'reject',
            variant: 'danger',
        }
    } else if (action === 'delete') {
        modalContent.value = {
            title: 'ยืนยันการลบรายการ',
            message: `ต้องการลบคำขอนี้ออกจากรายการใช่หรือไม่?`,
            confirmText: 'ลบรายการ',
            action: 'delete',
            variant: 'danger',
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
    const bookingId = modalContent.value.payload?.bookingId || tripToAction.value.id
    try {
        if (action === 'confirm') {
            await $api(`/bookings/${bookingId}/status`, { method: 'PATCH', body: { status: 'CONFIRMED' } })
            toast.success('สำเร็จ', 'ยืนยันคำขอแล้ว')
        } else if (action === 'reject') {
            await $api(`/bookings/${bookingId}/status`, { method: 'PATCH', body: { status: 'REJECTED' } })
            toast.success('สำเร็จ', 'ปฏิเสธคำขอแล้ว')
        } else if (action === 'delete') {
            await $api(`/bookings/${bookingId}`, { method: 'DELETE' })
            toast.success('ลบรายการสำเร็จ', 'ลบคำขอออกจากรายการแล้ว')
        
        // เพิ่ม case ใหม่
        } else if (action === 'driver-arrived') {
            await $api(`/bookings/${bookingId}/driver-arrived`, { method: 'PATCH' })
            toast.success('สำเร็จ', `แจ้งเตือนผู้โดยสารแล้ว รอการยืนยัน`)
        } else if (action === 'driver-cancel-request') {
            await $api(`/bookings/${bookingId}/driver-cancel-request`, { method: 'PATCH' })
            toast.success('ส่งคำขอยกเลิกแล้ว', 'รอผู้โดยสารยืนยันการยกเลิก')
        }

        closeConfirmModal()
        await fetchMyRoutes()
    } catch (error) {
        console.error(`Failed to ${action} booking:`, error)
        toast.error('เกิดข้อผิดพลาด', error?.data?.message || 'ไม่สามารถดำเนินการได้')
        closeConfirmModal()
    }
}

const copyEmail = async (email) => {
    try {
        await navigator.clipboard.writeText(email)
        toast.success('คัดลอกแล้ว', email)
    } catch (e) {
        toast.error('คัดลอกไม่สำเร็จ', 'ลองใหม่อีกครั้ง')
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
        return `${(km % 1 === 0 ? km.toFixed(0) : km)} กม.`
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
    title: 'คำขอจองเส้นทางของฉัน - ไปนำแหน่',
    script: process.client && !window.google?.maps ? [{
        key: 'gmaps',
        src: `https://maps.googleapis.com/maps/api/js?key=${useRuntimeConfig().public.googleMapsApiKey}&libraries=places,geometry&callback=${GMAPS_CB}`,
        async: true,
        defer: true
    }] : []
})

onMounted(() => {
    if (window.google?.maps) {
        initializeMap()
        fetchMyRoutes().then(() => {
            if (activeTab.value === 'myRoutes') {
                if (myRoutes.value.length) updateMap(myRoutes.value[0])
            } else {
                if (filteredTrips.value.length) updateMap(filteredTrips.value[0])
            }
            startPolling() // เริ่ม polling
        })
        return
    }

    window[GMAPS_CB] = () => {
        try { delete window[GMAPS_CB] } catch { }
        initializeMap()
        fetchMyRoutes().then(() => {
            if (activeTab.value === 'myRoutes') {
                if (myRoutes.value.length) updateMap(myRoutes.value[0])
            } else {
                if (filteredTrips.value.length) updateMap(filteredTrips.value[0])
            }
            startPolling() // เริ่ม polling
        })
    }
})

//เพิ่ม onUnmounted
onUnmounted(() => {
    stopPolling()
})

function initializeMap() {
    if (!mapContainer.value || gmap) return
    gmap = new google.maps.Map(mapContainer.value, {
        center: { lat: 13.7563, lng: 100.5018 },
        zoom: 6,
        mapTypeControl: false,
        streetViewControl: false,
        fullscreenControl: true,
    })
    geocoder = new google.maps.Geocoder()
    placesService = new google.maps.places.PlacesService(gmap)
    mapReady.value = true
}

watch(activeTab, () => {
    selectedTripId.value = null
    if (activeTab.value === 'myRoutes') {
        if (myRoutes.value.length > 0) updateMap(myRoutes.value[0])
    } else {
        if (filteredTrips.value.length > 0) updateMap(filteredTrips.value[0])
    }
})
</script>

<style scoped>
.trip-card {
    transition: all 0.3s ease;
    cursor: pointer;
}

.trip-card:hover {
    /* transform: translateY(-2px); */
    box-shadow: 0 10px 25px rgba(59, 130, 246, 0.1);
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
</style>