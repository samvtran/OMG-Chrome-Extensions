import Articles from './Components/Articles';
import MenuBar from './Components/MenuBar';
import Messenger from './Utils/Messenger';
import Notifier from './Utils/Notifier';
import Storage from './Utils/Storage';

const FETCH_ALARM = 'FETCH_ALARM';

chrome.alarms.get(FETCH_ALARM, (alarm) => {
  const intervalInMillis = Storage.getPollInterval();
  if (!alarm) {
    chrome.alarms.create(FETCH_ALARM, { when: Date.now(), periodInMinutes: intervalInMillis / 1000 / 60 });
  } else if (alarm.periodInMinutes !== intervalInMillis / 1000 / 60) { // Update periodicity if it changed
    chrome.alarms.create(FETCH_ALARM, { when: Date.now(), periodInMinutes: intervalInMillis / 1000 / 60 });
  } else {
  }
});

chrome.runtime.onStartup.addListener(() => {
  MenuBar.updateIcon(Articles.getArticles());
})

chrome.runtime.onInstalled.addListener(() => {
  MenuBar.updateIcon(Articles.getArticles());
});

chrome.alarms.onAlarm.addListener((alarm) => {
  if (alarm.name === FETCH_ALARM) {
    console.log("GOT ALARM!!!")
    Articles.fetchArticles(() => {
      Notifier.notifyUnread();
      Messenger.updateUI();
    });
  }
});