export const usePushNotification = () => {
  const { $api } = useNuxtApp();

  const subscribe = async () => {
  if (!('serviceWorker' in navigator) || !('PushManager' in window)) return;

  try {
    const reg = await navigator.serviceWorker.register('/sw.js');
    const permission = await Notification.requestPermission();
    if (permission !== 'granted') return;

    const config = useRuntimeConfig();
    const publicVapidKey = config.public.vapidPublicKey;

    // // --- เพิ่มการเช็คตรงนี้ ---
    // console.log('Original Key from config:', publicVapidKey);
    
    // if (!publicVapidKey) {
    //   console.error('VAPID Public Key is missing from config!');
    //   return;
    // }
    // // -----------------------

    const sub = await reg.pushManager.subscribe({
      userVisibleOnly: true,
      applicationServerKey: urlBase64ToUint8Array(publicVapidKey)
    });

    await $api('/messages/push/subscribe', {
      method: 'POST',
      body: sub.toJSON()
    });
    
    // console.log('Successfully subscribed to Push!');
  } catch (e) {
    console.error('Push subscription failed:', e); // ใช้ console.error เพื่อให้เห็นรายละเอียด Error ชัดเจนขึ้น
  }
};

  return { subscribe };
};

function urlBase64ToUint8Array(base64String) {
  const padding = '='.repeat((4 - base64String.length % 4) % 4);
  const base64 = (base64String + padding).replace(/-/g, '+').replace(/_/g, '/');
  const rawData = atob(base64);
  return Uint8Array.from([...rawData].map(c => c.charCodeAt(0)));
}