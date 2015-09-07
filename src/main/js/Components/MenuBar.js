export function updateIcon(articles) {
  const unreadCount = articles.filter(a => a.unread).length;
  if (unreadCount === 0) {
    setBadgeText('');
    setIcon('images/icon_inactive38.png');
  } else {
    setBadgeText(`${unreadCount}`);
    setIcon('images/icon_active38.png');
  }
}

export function setBadgeText(text) {
  chrome.browserAction.setBadgeText({text});
}

export function setIcon(path) {
  chrome.browserAction.setIcon({path});
}