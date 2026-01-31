importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-messaging.js");

firebase.initializeApp({
    apiKey: "AIzaSyDsZl_J0bQ4CtkRQ4K4hzLvLKusX4g8HPE",
    authDomain: "betalab-beta-lab-store.firebaseapp.com",
    projectId: "betalab-beta-lab-store",
    storageBucket: "betalab-beta-lab-store.firebasestorage.app",
    messagingSenderId: "960357270163",
    appId: "1:960357270163:web:placeholder",
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage(function (payload) {
    console.log('[firebase-messaging-sw.js] Received background message ', payload);
    const notificationTitle = payload.notification.title;
    const notificationOptions = {
        body: payload.notification.body,
        icon: '/icons/icon-192.png'
    };

    self.registration.showNotification(notificationTitle,
        notificationOptions);
});
