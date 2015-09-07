import * as Storage from './Storage';
import Config from 'config!../Config';
import * as Articles from '../Components/Articles';

const ID = 'OMG_NEW_NOTIFICATION';

export function testNotification() {
  single({
    title: "Ten Times Kittens with Mittens Melted Our Hearts",
    id: 0,
    link: Config.homepage
  });
  clearNotifications();
}

/**
 * This function does NOT check if notifications are enabled first.
 */
export function single(article) {
  const options = {
    type: 'basic',
    title: `New article on ${Config.title}`,
    message: article.title,
    iconUrl: 'images/icon_logo128.png'
  };

  if (!Config.opera) {
    options.buttons = [
      {
        title: 'Read',
        iconUrl: 'images/read.png'
      },
      {
        title: 'Mark As Read',
        iconUrl: 'images/mark_as_read.png'
      }
    ]
  }

  if (article.thumbnail && !Config.opera) { // Opera doesn't currently support image notifications  w
    options.type = 'image';
    options.imageUrl = article.thumbnail;
  }
  Storage.setLastNotification({type: 'single', lastId: article.id, article});
  createRichNotification(options);
}

/**
 * This function does NOT check if notifications are enabled first.
 */
export function multi(articles) {
  const options = {
    type: 'list',
    title: `${articles.length} new articles on ${Config.title}`,
    message: `"${articles[0].title}" and ${articles.length - 1} other ${articles.length - 1 === 1 ? 'article' : 'articles'}`,
    iconUrl: 'images/icon_logo128.png',
    items: articles.map((a) => ({title: a.title, message: ''}))
  };
  if (!Config.opera) {
    options.buttons = [
      {
        title: 'Read',
        iconUrl: 'images/read.png'
      },
      {
        title: 'Mark All As Read',
        iconUrl: 'images/mark_as_read.png'
      }
    ];
  }
  Storage.setLastNotification({type: 'multi', lastId: articles[0].id});
  createRichNotification(options);
}

function createRichNotification(options) {
  chrome.notifications.create(ID, options, () => {});
}

/**
 * This function checks if notifications are enabled first.
 */
export function notifyUnread() {
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
    unread.length > 1 ? multi(unread) : single(unread[0]);
  }
}

export function clearNotifications(cb = () => {}) {
  chrome.notifications.clear(ID, cb);
}

export function init() {
  // Chrome global listeners
  chrome.notifications.onShowSettings.addListener(() => chrome.windows.create({url: '/options.html', focused: true}));
  chrome.notifications.onClicked.addListener((id) => {
    const lastNotification = Storage.getLastNotification();
    if (lastNotification.type === 'single') {
      const article = lastNotification.article;
      Articles.markAsRead(article.id);
      window.open(article.link);
    } else {
      Articles.markAllAsRead();
      window.open(Config.homepage);
    }
    clearNotifications();
  });
  chrome.notifications.onButtonClicked.addListener((id, idx) => {
    console.log('button clicked!')
    const lastNotification = Storage.getLastNotification();
    if (lastNotification.type === 'single') {
      const article = lastNotification.article;
      Articles.markAsRead(article.id);
      if (idx === 0) window.open(article.link);
    } else {
      Articles.markAllAsRead();
      if (idx === 0) window.open(Config.homepage);
    }
    clearNotifications();
  });
}