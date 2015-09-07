import * as MenuBar from '../Components/MenuBar';

export const latestVersion = '3';
export const defaultPollInterval = 900000;  // Default 15 minutes

export function getVersion(setIfUnset:boolean = false) {
  if (setIfUnset && localStorage['version'] !== latestVersion) {
    setVersion();
  }

  return localStorage['version'] || 0;
}

export function setVersion() {
  localStorage['version'] = latestVersion;
}

export function areNotificationsEnabled() {
  if (typeof localStorage['notificationsEnabled'] === 'undefined') {
    localStorage['notificationsEnabled'] = true;
  }
  return localStorage['notificationsEnabled'] === 'true';
}
export function setNotificationsEnabled(enabled) {
  localStorage['notificationsEnabled'] = enabled;
}

export function getPollInterval() {
  if (typeof localStorage['pollInterval'] === 'undefined') {
    localStorage['pollInterval'] = defaultPollInterval;
  }
  return ~~localStorage['pollInterval'];
}
export function setPollInterval(timeInMillis) {
  localStorage['pollInterval'] = timeInMillis;
}

export function getLastNotification() {
  return localStorage['notification'] ? JSON.parse(localStorage['notification']) : {type: 'multi', lastId: 0};
}

/**
 * @param obj An object with type as 'single' or 'multi', a lastId integer, and, if single, an article object
 */
export function setLastNotification(obj) {
  localStorage['notification'] = JSON.stringify(obj);
}

export function getArticles():Array {
  return JSON.parse(localStorage['articles'] || '[]');
}
export function setArticles(articles) {
  MenuBar.updateIcon(articles);
  localStorage['articles'] = JSON.stringify(articles);
}