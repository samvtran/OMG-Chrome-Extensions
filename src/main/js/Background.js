import * as Articles from './Components/Articles';
import * as MenuBar from './Components/MenuBar';
import * as Messenger from './Utils/Messenger';
import * as Notifier from './Utils/Notifier';
import * as Storage from './Utils/Storage';

const FETCH_ALARM = 'FETCH_ALARM';

Notifier.init();

function onStart() {
  Articles.fetchArticles(() => {
    Notifier.notifyUnread();
    Messenger.updateUI();
    MenuBar.updateIcon(Articles.getArticles());
  });
}

chrome.alarms.get(FETCH_ALARM, (alarm) => {
  const intervalInMillis = Storage.getPollInterval();
  if (!alarm) {
    chrome.alarms.create(FETCH_ALARM, { when: Date.now(), periodInMinutes: intervalInMillis / 1000 / 60 });
  } else if (alarm.periodInMinutes !== intervalInMillis / 1000 / 60) { // Update periodicity if it changed
    chrome.alarms.create(FETCH_ALARM, { when: Date.now(), periodInMinutes: intervalInMillis / 1000 / 60 });
  } else {
  }
});

chrome.runtime.onStartup.addListener(onStart);
chrome.runtime.onInstalled.addListener(onStart);

chrome.alarms.onAlarm.addListener((alarm) => {
  if (alarm.name === FETCH_ALARM) {
    onStart();
  }
});