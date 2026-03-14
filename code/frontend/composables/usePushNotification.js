export const usePushNotification = () => {
  const { $api } = useNuxtApp();

  const subscribe = async () => {
    if (!('serviceWorker' in navigator) || !('PushManager' in window)) return;

    try {
      const reg = await navigator.serviceWorker.register('/sw.js');
      const permission = await Notification.requestPermission();
      if (permission !== 'granted') return;

      const config = useRuntimeConfig();
      const sub = await reg.pushManager.subscribe({
        userVisibleOnly: true,
        applicationServerKey: urlBase64ToUint8Array(config.public.vapidPublicKey)
      });

      await $api('/messages/push/subscribe', {
        method: 'POST',
        body: sub.toJSON()
      });
    } catch (e) {
      console.warn('Push subscription failed:', e);
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