import * as Storage from './Utils/Storage';
import Config from 'config!./Config';
import * as Notifier from './Utils/Notifier';

Notifier.init();

(() => {
  const notificationsEnabled = document.querySelector('#notificationsEnabled');
  notificationsEnabled.checked = Storage.areNotificationsEnabled();
  notificationsEnabled.addEventListener('change', (e) => Storage.setNotificationsEnabled(e.target.checked));
  document.querySelector('#testNotification').addEventListener('click', Notifier.testNotification);
})()