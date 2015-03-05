'use strict';

import Storage from './Utils/Storage';
import Config from 'flavor/config';

(function() {
  var notificationsEnabled = document.querySelector('#notifications-enabled');
  var handleShowNotification = function() {
    chrome.notifications.create(Config.tag + 'ExampleNotification', {
      type: 'basic',
      title: 'This is an example notification',
      message: 'The article title will show up here.',
      iconUrl: 'images/icon_logo128.png',
      buttons: [
        {
          title: 'Dismiss',
          iconUrl: 'images/read.png'
        }
      ]
    }, function() {});
    var timeout = setTimeout(function() {
      chrome.notifications.clear(Config.tag + 'ExampleNotification', function() {})
    }, 5000);
    var clearNotification = (notificationId) => {
      if (notificationId === Config.tag + 'ExampleNotification') {
        clearTimeout(timeout);
        chrome.notifications.clear(Config.tag + 'ExampleNotification', function() {})
      }
    }
    chrome.notifications.onButtonClicked.addListener(clearNotification);
    chrome.notifications.onClicked.addListener(clearNotification);
  };
  var handleChange = function(e) {
    console.log(e.target.checked);
    Storage.setNotificationsEnabled(e.target.checked);
  };

  notificationsEnabled.checked = Storage.notificationsEnabled();

  document.querySelector('#testNotification').addEventListener('click', handleShowNotification);
  notificationsEnabled.addEventListener('change', handleChange);
}())