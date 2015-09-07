import Request from 'superagent';
import Config from 'config!../Config';
import { Article, getParser } from '../Utils/ResponseParser';
import * as Storage from '../Utils/Storage';
import { clearNotifications } from '../Utils/Notifier';
import crel from 'crel';

export function populate(dom) {
  dom.innerHTML = '';

  getArticles().forEach((article:Article) => {
    const thumbnail = article.thumbnail || 'images/placeholder100.png';
    var el = crel('article', {'class': 'Latest-article'},
      crel('div', {'class': 'Latest-unreadIndicator' + (article.unread ? ' is-unread' : '')},
        crel('img', {src: 'images/unread.svg', alt: 'Unread'})),
      crel('div', {'class': 'Latest-thumbnailWrapper'},
        crel('button', {type: 'button', 'class': 'is-link'}, crel('img', {src: thumbnail, alt: article.title}))),
      crel('h3', crel('button', {type: 'button', 'class': 'is-link'}, article.title))
    )

    const markedAsRead = () => {
      markAsRead(article.id);
      el.querySelector('.Latest-unreadIndicator').classList.remove('is-unread');
    };

    const openArticle = (e) => {
      e.preventDefault();
      e.stopPropagation();
      markedAsRead();
      chrome.tabs.create({url: article.link});
    };

    el.addEventListener('click', (e) => {
      e.preventDefault();
      e.stopPropagation();
      markedAsRead();
    })

    el.querySelector('.Latest-thumbnailWrapper button').addEventListener('click', openArticle);
    el.querySelector('h3 button').addEventListener('click', openArticle);
    dom.appendChild(el);
  });
}

export function getArticles() {
  return Storage.getArticles().sort((a, b) => b.date - a.date);
}

export function setArticles(newArticles:Array = [], reconcile:Boolean = false, isUpgrade:Boolean = false) {
  if (isUpgrade) {
    Storage.setArticles(newArticles.map((a) => {
      a.unread = false;
      return a;
    }));
  } else if (reconcile) {
    const existing = getArticles().filter(a => ({id: a.id, unread: a.unread})).reduce((obj, a) => {
      obj[a.id] = a.unread;
      return obj;
    }, {});
    const toStorage = newArticles.map((a) => {
      if (typeof existing[a.id] !== 'undefined') {
        a.unread = existing[a.id];
      }
      return a;
    });
    Storage.setArticles(toStorage);
  } else {
    Storage.setArticles(newArticles);
  }
}

export function markAllAsRead(cb = () => {}) {
  Storage.setArticles(getArticles().map((a) => {
    a.unread = false;
    return a;
  }));
  clearNotifications();
  cb();
}

export function markAsRead(articleId:number) {
  const articles = getArticles();
  articles.some((a, idx) => {
    if (a.id === articleId) {
      if (articles[idx].unread) {
        articles[idx].unread = false;
        setArticles(articles);
        const lastNotification = Storage.getLastNotification();
        if (lastNotification.type === 'multi' || lastNotification.lastId === articleId) clearNotifications();
      }
      return true;
      return true;
    }
    return false;
  });
}

export function fetchArticles(cb, isUpgrade) {
  Request
    .get(Config.feedUrl)
    .end((err, res) => {
      if (res.ok) {
        console.log("OK")
        const articles = getParser(Config.parser)(res.text);
        setArticles(articles, true, isUpgrade);
      } else {
        // Silently fail (for now anyway)
        console.log("NOT OKAY")
      }
      cb();
    });
}