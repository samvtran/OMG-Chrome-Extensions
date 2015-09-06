import MenuBar from '../Components/MenuBar';

export default class Storage {
  static latestVersion = '3';
  static defaultPollInterval = 900000;  // Default 15 minutes

  static getVersion(setIfUnset: boolean = false) {
    if (setIfUnset && localStorage['version'] !== Storage.latestVersion) {
      Storage.setVersion();
    }

    return localStorage['version'] || 0;
  }

  static setVersion() {
    localStorage['version'] = Storage.latestVersion;
  }

  static areNotificationsEnabled() {
    if (typeof localStorage['notificationsEnabled'] === 'undefined') {
      localStorage['notificationsEnabled'] = true;
    }
    return localStorage['notificationsEnabled'] === 'true';
  }
  static setNotificationsEnabled(enabled) {
    localStorage['notificationsEnabled'] = enabled;
  }

  static getPollInterval() {
    if (typeof localStorage['pollInterval'] === 'undefined') {
      localStorage['pollInterval'] = Storage.defaultPollInterval;
    }
    return ~~localStorage['pollInterval'];
  }
  static setPollInterval(timeInMillis) {
    localStorage['pollInterval'] = timeInMillis;
  }

  static getLastNotification() {
    return localStorage['notification'] ? JSON.parse(localStorage['notification']) : { type: 'multi', lastId: 0 };
  }

  /**
   * @param obj An object with type as 'single' or 'multi', a lastId integer, and, if single, an article object
   */
  static setLastNotification(obj) {
    localStorage['notification'] = JSON.stringify(obj);
  }

  static getArticles(): Array {
    return JSON.parse(localStorage['articles'] || '[]');
  }
  static setArticles(articles) {
    MenuBar.updateIcon(articles);
    localStorage['articles'] = JSON.stringify(articles);
  }
}