'use strict';

export default class Storage {
  static notificationsEnabled() {
    if (typeof localStorage['notificationsEnabled'] === 'undefined') {
      localStorage['notificationsEnabled'] = true;
    }
    return localStorage['notificationsEnabled'] === 'true';
  }
  static setNotificationsEnabled(enabled) {
    localStorage['notificationsEnabled'] = enabled;
  }

  static pollInterval() {
    if (typeof localStorage['pollInterval'] === 'undefined') {
      localStorage['pollInterval'] = 900000;  // Default 15 minutes
    }
    return localStorage['pollInterval'];
  }
  static setPollInterval(timeInMillis) {
    localStorage['pollInterval'] = timeInMillis;
  }

  static lastNotification() {
    if (typeof localStorage['notification'] === 'undefined') return false;
    return localStorage['notification'];
  }
  static setLastNotification(lastNotification) {
    localStorage['notification'] = lastNotification;
  }

  static articles() {
    if (typeof localStorage['articles'] === 'undefined') return [];
    return localStorage['articles'];
  }
  static setArticles(articles) {
    localStorage['articles'] = articles;
  }
}