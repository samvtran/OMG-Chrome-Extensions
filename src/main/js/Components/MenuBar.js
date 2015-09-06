export default class MenuBar {
  static updateIcon(articles) {
    const unreadCount = articles.filter(a => a.unread).length;
    if (unreadCount === 0) {
      MenuBar.setBadgeText('');
      MenuBar.setIcon('images/icon_inactive38.png');
    } else {
      MenuBar.setBadgeText(`${unreadCount}`);
      MenuBar.setIcon('images/icon_active38.png');
    }
  }

  static setBadgeText(text) {
    chrome.browserAction.setBadgeText({ text });
  }

  static setIcon(path) {
    chrome.browserAction.setIcon({ path });
  }
}