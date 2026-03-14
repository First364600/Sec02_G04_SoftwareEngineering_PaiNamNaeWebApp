self.addEventListener('push', (event) => {
  const data = event.data?.json() || {};
  const title = data.title || 'แจ้งเตือนใหม่';
  const options = {
    body: data.body || '',
    // icon: '/icon-192.png',   // comment ไว้ก่อนยังไม่มีไฟล์
    data: data.data || {},
    vibrate: [200, 100, 200],
    actions: data.data?.type === 'TRIP_MESSAGE' ? [
      { action: 'reply', title: 'ตอบกลับ' },
      { action: 'view', title: 'ดู' }
    ] : [
      { action: 'view', title: 'ดูรายละเอียด' }
    ]
  };
  event.waitUntil(self.registration.showNotification(title, options));
});

self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  const action = event.action;
  const data = event.notification.data;
  
  let url = '/';
  if (data?.type === 'TRIP_MESSAGE') url = '/myTrip';
  else if (data?.type === 'TRIP_REPLY') url = '/myRoute';

  event.waitUntil(
    clients.matchAll({ type: 'window' }).then((clientList) => {
      if (clientList.length > 0) {
        clientList[0].focus();
        clientList[0].postMessage({ action, data });
      } else {
        clients.openWindow(url);
      }
    })
  );
});