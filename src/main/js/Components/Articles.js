'use strict';

import Request from 'superagent';
import Config from 'config!../Config';
import { Article, getParser } from '../Utils/ResponseParser';
import Storage from '../Utils/Storage';
import crel from 'crel';

/*
TODO fetchArticles
  when reconciling:
    0. check version number, if none, no unreads, just replace all
    1. Iterate over new list, take existing list and compare pids
    2a. If pid is found, set unread state to existing state
    2b. If not found, it's new, so mark as unread
    3. Set new article list as existing list
    Notify:
      1. Sort by date descending
      2. If unread && !== last notified, add to notify list
      3. If pid is same as last notified || first read, stop.
      4. make first notify as lastNotified
 */
export default class Articles {
  static populate(dom) {
    dom.innerHTML = '';

    Articles.getArticles().forEach((article: Article) => {
      const thumbnail = article.thumbnail || 'images/placeholder100.png';
      var el = crel('article', {'class': 'Latest-article'},
        crel('div', {'class': 'Latest-unreadIndicator' + (article.unread ? ' is-unread' : '')},
          crel('img', {src: 'images/unread.svg', alt: 'Unread'})),
        crel('div', {'class': 'Latest-thumbnailWrapper'},
          crel('button', {type: 'button', 'class': 'is-link'}, crel('img', {src: thumbnail, alt: article.title}))),
        crel('h3', crel('button', {type: 'button', 'class': 'is-link'}, article.title))
      )

      const markedAsRead = () => {
        Articles.markAsRead(article.id);
        el.querySelector('.Latest-unreadIndicator').classList.remove('is-unread');
      };

      const openArticle = (e) => {
        e.preventDefault();
        e.stopPropagation();
        markedAsRead();
        chrome.tabs.create({ url: article.link });
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

  static getArticles() {
    return Storage.getArticles().sort((a, b) => b.date - a.date);
  }

  static setArticles(newArticles: Array = [], reconcile: Boolean = false, isUpgrade: Boolean = false) {
    if (isUpgrade) {
      Storage.setArticles(newArticles.map((a) => {
        a.unread = false;
        return a;
      }));
    } else if (reconcile) {
      const existing = Articles.getArticles().filter(a => ({ id: a.id, unread: a.unread })).reduce((obj, a) => {
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

  static markAllAsRead(cb = () => {}) {
    Storage.setArticles(Articles.getArticles().map((a) => {
      a.unread = false;
      return a;
    }))
    cb();
  }

  static markAsRead(articleId: number) {
    const articles = Articles.getArticles();
    articles.some((a, idx) => {
      if (a.id === articleId) {
        articles[idx].unread = false;
        Articles.setArticles(articles);
        return true;
      }
      return false;
    })
  }

  static fetchArticles(cb, isUpgrade) {
    Request
      .get(Config.feedUrl)
      .end((err, res) => {
        if (res.ok) {
          console.log("OK")
          const articles = getParser(Config.parser)(res.text);
          Articles.setArticles(articles, true, isUpgrade);
        } else {
          // Silently fail (for now anyway)
          console.log("NOT OKAY")
        }
        cb();
      });
  }
}