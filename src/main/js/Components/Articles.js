'use strict';

import Request from 'superagent';
import Config from 'flavor/config';
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
  static getArticles() {
    var articles = JSON.parse(typeof localStorage['articles'] === 'undefined' ? '[]' : localStorage['articles']);
    if (typeof articles === 'undefined') return [];
    return articles.sort((a, b) => {
      return b.date - a.date;
    });
  }
  static markAsRead(articleId) {

  }
  static fetchArticles(cb) {
    Request
      .get(Config.url)
      .end(function(res) {
        if (res.ok) {
          console.log("OK")
          console.log(res);
          var dom = new DOMParser().parseFromString(res.text, 'application/xml');
          var channel = dom.querySelector('channel');
          if (!channel) return [];
          var items = channel.querySelectorAll('item');
          if (!items) return [];
          console.log(items)
          var articles = Array.prototype.map.call(items, function(item) {
            var thumbnail = item.querySelector('thumbnail');
            var article = {
              title: item.querySelector('title').textContent,
              author: item.querySelector('creator').textContent,
              link: item.querySelector('link').textContent,
              date: Date.parse(item.querySelector('pubDate').textContent),
              pid: item.querySelector('pid').textContent,
              unread: true,
            };
            if (thumbnail !== null) article.thumbnail = thumbnail.getAttribute('url');
            return article;
          })
          console.log(JSON.stringify(articles, null, 2));
        } else {
          console.log("NOT OKAY")
        }
        cb();
      });
  }
}