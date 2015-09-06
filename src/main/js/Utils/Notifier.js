import Storage from './Storage';
import Config from 'config!../Config';
import Articles from '../Components/Articles';

const ID_SINGLE = 'OMG_NEW_NOTIFICATION_SINGLE';
const ID_MULTI = 'OMG_NEW_NOTIFICATION_MULTI';

export default class Notifier {
  static testNotification() {
    Notifier.single({
      title: "Ten Times Kittens with Mittens Melted Our Hearts",
      id: 0,
      link: Config.homepage
    });
    if (Notifier.hasRichNotifications()) {
      chrome.notifications.clear(ID, () => {});
    }
  }

  static hasRichNotifications() {
    return !!chrome.notifications;
  }

  /**
   * This function does NOT check if notifications are enabled first.
   */
  static single(article) {
    const options = {
      type: 'basic',
      title: `New article on ${Config.title}`,
      message: article.title,
      iconUrl: 'images/icon_logo128.png',
      buttons: [
        {
          title: 'Read',
          iconUrl: 'images/read.png'
        },
        {
          title: 'Mark As Read',
          iconUrl: 'images/mark_as_read.png'
        }
      ]
    };

    if (article.thumbnail && !Config.opera) { // Opera doesn't currently support image notifications  w
      options.type = 'image';
      options.imageUrl = article.thumbnail;
    }
    Storage.setLastNotification({ type: 'single', lastId: article.id, article });
    Notifier.createRichNotification(options, ID_SINGLE);
  }

  /**
   * This function does NOT check if notifications are enabled first.
   */
  static multi(articles) {
    const options = {
      type: 'list',
      title: `${articles.length} new articles on ${Config.title}`,
      message: `"${articles[0].title}" and ${articles.length - 1} other ${articles.length - 1 === 1 ? 'article' : 'articles'}`,
      iconUrl: 'images/icon_logo128.png',
      items: articles.map((a) => ({ title: a.title, message: '' })),
      buttons: [
        {
          title: 'Read',
          iconUrl: 'images/read.png'
        },
        {
          title: 'Mark All As Read',
          iconUrl: 'images/mark_as_read.png'
        }
      ]
    };
    Storage.setLastNotification({ type: 'multi', lastId: articles[0].id });
    Notifier.createRichNotification(options, ID_MULTI);
  }

  static createRichNotification(options, id) {
    chrome.notifications.create(id, options, () => {});
  }

  /**
   * This function checks if notifications are enabled first.
   */
  static notifyUnread() {
    if (!Storage.areNotificationsEnabled()) return;
    const articlesToLastNotified = [];
    const lastNotify = Storage.getLastNotification().lastId;
    Articles.getArticles().some((a) => {
      if (a.id === lastNotify) {
        return true;
      } else {
        articlesToLastNotified.push(a);
        return false;
      }
    });
    const unread = articlesToLastNotified.filter((a) => a.unread);
    if (unread.length) {
      unread.length > 1 ? Notifier.multi(unread) : Notifier.single(unread[0]);
    }
  }

  static clearRichNotification(single) {
    chrome.notifications.clear(single ? ID_SINGLE : ID_MULTI, () => {});
  }
}

// Chrome global listeners
chrome.notifications.onShowSettings.addListener(() => chrome.windows.create({ url: '/options.html', focused: true }));
chrome.notifications.onClicked.addListener((id) => {
  const lastNotification = Storage.getLastNotification();
  if (lastNotification.type === 'single') {
    const article = lastNotification.article;
    Articles.markAsRead(article.id);
    window.open(article.link);
    Notifier.clearRichNotification(true);
  } else {
    Articles.markAllAsRead();
    window.open(Config.homepage);
    Notifier.clearRichNotification(false);
  }
});
chrome.notifications.onButtonClicked.addListener((id, idx) => {
  console.log('button clicked!')
  const lastNotification = Storage.getLastNotification();
  if (lastNotification.type === 'single') {
    const article = lastNotification.article;
    Articles.markAsRead(article.id);
    if (idx === 0) window.open(article.link);
    Notifier.clearRichNotification(true);
  } else {
    Articles.markAllAsRead();
    if (idx === 0) window.open(Config.homepage);
    Notifier.clearRichNotification(false);
  }
});