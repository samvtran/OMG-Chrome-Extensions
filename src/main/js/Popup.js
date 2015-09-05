'use strict';

import Articles from './Components/Articles';

import crel from 'crel';

(function() {
  var refresh = document.querySelector('.PopupHeader-refresh');
  var articleList = document.querySelector('#articleList');
  Articles.getArticles().forEach(function(article) {
    var thumbnail = (typeof article.thumbnail !== 'undefined') ? article.thumbnail : 'images/placeholder100.png';
    var el = crel('article', {'class': 'Latest-article'},
      crel('div', {'class': 'Latest-unreadIndicator' + (article.unread ? ' is-unread' : '')}, crel('img', {src: 'images/unread.svg', alt: 'Unread'})),
      crel('div', {'class': 'Latest-thumbnailWrapper'}, crel('a', {href: '#'}, crel('img', {src: thumbnail, alt: article.title}))),
      crel('h3', crel('a', {href: '#'}, article.title))
    )
    var markedAsRead = function() {
      Articles.markAsRead(article.pid);
      el.querySelector('.Latest-unreadIndicator').classList.remove('is-unread');
    }.bind(this);
    var openArticle = function(e) {
      e.preventDefault();
      e.stopPropagation();
      markedAsRead();
      chrome.tabs.create({ url: article.link });
    }.bind(this)
    el.addEventListener('click', function(e) {
      e.preventDefault();
      e.stopPropagation();
      markedAsRead();
    }.bind(this))
    el.querySelector('.Latest-thumbnailWrapper a').addEventListener('click', openArticle);
    el.querySelector('h3 a').addEventListener('click', openArticle);
    articleList.appendChild(el);
  });

  refresh.addEventListener('click', function(e) {
    if (!refresh.classList.contains('is-refreshing')) {
      refresh.classList.add('is-refreshing');
      Articles.fetchArticles(function() {
        console.log("Fetched...")
        refresh.classList.remove('is-refreshing');
      });
    }
  });
}());