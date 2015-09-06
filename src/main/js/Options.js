import Storage from './Utils/Storage';
import Config from 'config!./Config';
import Notifier from './Utils/Notifier';

(() => {
  const notificationsEnabled = document.querySelector('#notificationsEnabled');
  notificationsEnabled.checked = Storage.areNotificationsEnabled();
  notificationsEnabled.addEventListener('change', (e) => Storage.setNotificationsEnabled(e.target.checked));
  document.querySelector('#testNotification').addEventListener('click', Notifier.testNotification);
})()