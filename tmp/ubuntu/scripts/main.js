(function() {
  this.GlobalConfig = {};

}).call(this);

(function() {
  GlobalConfig.name = 'OMG! Ubuntu!';

  GlobalConfig.tag = 'omgUbuntu';

  GlobalConfig.homepage = 'http://www.omgubuntu.co.uk';

  GlobalConfig.url = 'http://www.omgubuntu.co.uk/wp-content/plugins/ohsofeeder/article-titles.php';

  GlobalConfig.intro = '<p>We\'re the world\'s largest Linux-orientated site on the web, bringing the latest news, reviews and tutorials to over 2 million unique readers a month.</p><p>But we\'re more than just a website &ndash; we\'re also a vibrant community, boasting over 200,000 subscribers across <a href="http://twitter.com/omgubuntu" title="OMG! Ubuntu! on Twitter">Twitter</a>, <a href="http://facebook.com/omgubuntu" title="OMG! Ubuntu! on Facebook">Facebook</a>, <a href="http://youtube.com/omgubuntu" title="OMG! Ubuntu! on Youtube">Youtube</a> and more.</p><p>And by using this extension, you\'re part of that, too!</p><p>OMG! Ubuntu! is part of <strong><a href="http://ohso.co" title="Ohso Ltd">Ohso Ltd</a></strong>, a New-Zealand based media and software publishing company founded in 2010.</p>';

}).call(this);

(function() {
  'use strict';
  var omgApp, omgBackground, omgOptions, omgUtil, setup;

  (setup = function() {
    if (typeof localStorage['pollInterval'] === 'undefined') {
      localStorage['pollInterval'] = 900000;
    }
    if (typeof localStorage['notificationsEnabled'] === 'undefined') {
      return localStorage['notificationsEnabled'] = true;
    }
  })();

  omgBackground = angular.module('omgBackground', ['omgUtil']);

  omgBackground.controller('backgroundCtrl', [
    'Articles', 'Notifier', 'Badge', function(Articles, Notifier, Badge) {
      Articles.fetchLatestArticles().then(function() {
        return Articles.fetchLatestArticlesOnTimeout();
      });
      chrome.notifications.onClicked.addListener(function() {
        var notification;
        notification = angular.fromJson(localStorage['notification']);
        if (notification.type === 'single') {
          window.open(notification.link);
          Articles.markAsRead(notification.link);
        } else {
          window.open(notification.link);
          Articles.markAllAsRead();
        }
        return chrome.notifications.clear(Notifier.richNotificationId, function() {});
      });
      return chrome.notifications.onButtonClicked.addListener(function(id, idx) {
        var notification;
        notification = angular.fromJson(localStorage['notification']);
        if (notification.type === 'single') {
          if (idx === 0) {
            window.open(notification.link);
            Articles.markAsRead(notification.link);
          } else {
            Articles.markAsRead(notification.link);
          }
        } else {
          if (idx === 0) {
            window.open(GlobalConfig.homepage);
            Articles.markAllAsRead();
          } else {
            Articles.markAllAsRead();
          }
        }
        return chrome.notifications.clear(Notifier.richNotificationId, function() {});
      });
    }
  ]);

  omgApp = angular.module('omgApp', ['omgUtil']);

  omgApp.controller('popupCtrl', [
    '$scope', 'Articles', function($scope, Articles) {
      $scope.linkToHome = {
        url: GlobalConfig.homepage,
        title: GlobalConfig.name
      };
      $scope.latestArticles = Articles.getArticles();
      $scope.getThumbnail = function(index) {
        var thumbnail;
        thumbnail = $scope.latestArticles[index].thumbnail;
        if (typeof thumbnail !== 'undefined') {
          return thumbnail;
        } else {
          return 'images/placeholder100.png';
        }
      };
      $scope.markAsRead = function(index) {
        $scope.latestArticles[index].unread = false;
        return Articles.markAsReadAtIndex(index);
      };
      $scope.markAllAsRead = function() {
        Articles.markAllAsRead();
        return $scope.latestArticles = Articles.getArticles();
      };
      $scope.refresh = function() {
        $scope.refreshing = true;
        return Articles.fetchLatestArticles().then(function() {
          $scope.latestArticles = Articles.getArticles();
          return $scope.refreshing = false;
        });
      };
      return $scope.optionsPage = function() {
        return chrome.tabs.create({
          url: "options.html"
        });
      };
    }
  ]);

  omgOptions = angular.module('omgOptions', ['omgUtil']);

  omgOptions.controller('optionCtrl', [
    '$scope', function($scope) {
      $scope.GlobalConfig = GlobalConfig;
      $scope.notificationsEnabled = (localStorage['notificationsEnabled'] === "true" ? true : false);
      $scope.$watch('notificationsEnabled', function(newValue) {
        if (newValue !== (localStorage['notificationsEnabled'] === "true" ? true : false)) {
          return localStorage['notificationsEnabled'] = newValue;
        }
      });
      return $scope.showExampleNotification = function() {
        return webkitNotifications.createNotification('/images/icon_logo48.png', "Example notification", "A summary of the new article or the number of new articles would go here!").show();
      };
    }
  ]);

  omgUtil = angular.module('omgUtil', []);

  omgUtil.service('Messenger', [
    function() {
      return {
        notify: {
          badge: function(articles) {
            return chrome.runtime.sendMessage({
              type: 'badge',
              articles: articles
            });
          },
          notification: function(articles) {
            return chrome.runtime.sendMessage({
              type: 'notification',
              articles: articles
            });
          }
        }
      };
    }
  ]);

  omgUtil.service('Articles', [
    '$http', '$q', 'Messenger', function($http, $q, Messenger) {
      var checkExistingArticles, fetchLatestArticles, fetchLatestArticlesOnTimeout, getArticles, getUnreadArticles, markAllAsRead, markAsRead, markAsReadAtIndex, putArticles, putLatestArticlesAndNotify;
      fetchLatestArticles = function() {
        var deferred;
        deferred = $q.defer();
        $http.get(GlobalConfig.url, {
          transformResponse: function(data) {
            return new DOMParser().parseFromString(data, 'application/xml');
          }
        }).success(function(data) {
          var article, articles, item, items, thumbnail, _i, _len;
          items = angular.element(data).find('channel').find('item');
          if (items.length < 1) {
            deferred.resolve([]);
            return;
          }
          articles = [];
          for (_i = 0, _len = items.length; _i < _len; _i++) {
            item = items[_i];
            thumbnail = item.querySelector('thumbnail');
            article = {
              title: item.querySelector('title').textContent,
              author: item.querySelector('creator').textContent,
              link: item.querySelector('link').textContent,
              date: Date.parse(item.querySelector('pubDate').textContent),
              unread: true
            };
            if (thumbnail !== null) {
              article.thumbnail = thumbnail.getAttribute('url');
            }
            articles.push(article);
          }
          putLatestArticlesAndNotify(articles);
          return deferred.resolve(articles);
        }).error(function() {
          return deferred.resolve([]);
        });
        return deferred.promise;
      };
      fetchLatestArticlesOnTimeout = function() {
        return setTimeout(function() {
          return fetchLatestArticles().then(function() {
            return fetchLatestArticlesOnTimeout();
          });
        }, localStorage['pollInterval']);
      };
      putLatestArticlesAndNotify = function(articles) {
        var article, existingArticles, i, j, latestNewArticleSlice, newArticles, uniqueArticles, unreadArticles, yesterday, _i, _j, _k, _len, _ref, _ref1;
        newArticles = [];
        if (typeof localStorage['unread'] !== 'undefined') {
          for (_i = 0, _len = articles.length; _i < _len; _i++) {
            article = articles[_i];
            article.unread = false;
          }
          localStorage.removeItem('unread');
        }
        existingArticles = getArticles();
        yesterday = new Date();
        yesterday.setDate(yesterday.getDate() - 1);
        yesterday = yesterday.getTime();
        if (existingArticles.length > 0) {
          latestNewArticleSlice = -1;
          for (i = _j = 0, _ref = articles.length - 1; _j <= _ref; i = _j += 1) {
            if (existingArticles[0].link === articles[i].link) {
              latestNewArticleSlice = i;
              for (j = _k = i, _ref1 = articles.length - 1; _k <= _ref1; j = _k += 1) {
                if (articles[j].date > yesterday) {
                  existingArticles[j - i].title = articles[j].title;
                  if (typeof articles[j].thumbnail !== 'undefined') {
                    existingArticles[j - i].thumbnail = articles[j].thumbnail;
                  }
                } else {
                  break;
                }
              }
              break;
            }
          }
          if (latestNewArticleSlice < 0) {
            newArticles = articles;
          } else {
            newArticles = articles.slice(0, latestNewArticleSlice);
          }
        } else {
          newArticles = articles;
        }
        uniqueArticles = checkExistingArticles(existingArticles, newArticles);
        putArticles(uniqueArticles.concat(existingArticles));
        unreadArticles = getUnreadArticles();
        Messenger.notify.badge(unreadArticles);
        return Messenger.notify.notification(uniqueArticles);
      };
      checkExistingArticles = function(existing, newArticles) {
        var i, paths, uniqueArticles, _i, _ref;
        uniqueArticles = [];
        paths = existing.map(function(article) {
          return article.link;
        });
        for (i = _i = 0, _ref = newArticles.length - 1; _i <= _ref; i = _i += 1) {
          if (paths.indexOf(newArticles[i].link) === -1) {
            uniqueArticles.push(newArticles[i]);
          }
        }
        return uniqueArticles;
      };
      putArticles = function(articlesJson) {
        return localStorage['articles'] = angular.toJson(articlesJson.slice(0, 30));
      };
      getArticles = function() {
        var articles;
        articles = angular.fromJson(localStorage['articles']);
        if (typeof articles === 'undefined') {
          return [];
        }
        return articles.sort(function(a, b) {
          return b.date - a.date;
        });
      };
      getUnreadArticles = function() {
        var article, articles, unreadArticles, _i, _len;
        articles = getArticles();
        unreadArticles = [];
        for (_i = 0, _len = articles.length; _i < _len; _i++) {
          article = articles[_i];
          if (article.unread === true) {
            unreadArticles.push(article);
          }
        }
        return unreadArticles;
      };
      markAllAsRead = function() {
        var article, articles, _i, _len;
        articles = getArticles();
        for (_i = 0, _len = articles.length; _i < _len; _i++) {
          article = articles[_i];
          article.unread = false;
        }
        putArticles(articles);
        return Messenger.notify.badge(getUnreadArticles());
      };
      markAsRead = function(articleLink) {
        var article, articles, _i, _len;
        articles = getArticles();
        for (_i = 0, _len = articles.length; _i < _len; _i++) {
          article = articles[_i];
          if (article.link === articleLink) {
            article.unread = false;
          }
        }
        putArticles(articles);
        return Messenger.notify.badge(getUnreadArticles());
      };
      markAsReadAtIndex = function(index) {
        var articles;
        articles = getArticles();
        articles[index].unread = false;
        putArticles(articles);
        return Messenger.notify.badge(getUnreadArticles());
      };
      return {
        fetchLatestArticles: fetchLatestArticles,
        fetchLatestArticlesOnTimeout: fetchLatestArticlesOnTimeout,
        putLatestArticlesAndNotify: putLatestArticlesAndNotify,
        putArticles: putArticles,
        getArticles: getArticles,
        getUnreadArticles: getUnreadArticles,
        markAllAsRead: markAllAsRead,
        markAsRead: markAsRead,
        markAsReadAtIndex: markAsReadAtIndex,
        checkExistingArticles: checkExistingArticles
      };
    }
  ]);

  omgUtil.service('Notifier', [
    'Articles', function(Articles) {
      var hasRichNotifications, multiNotify, notify, richNotificationId, singleNotify;
      richNotificationId = "" + GlobalConfig.tag + "ExtensionNotification";
      hasRichNotifications = function() {
        return typeof chrome.notifications !== 'undefined';
      };
      notify = function(unreadArticles) {
        if (localStorage['notificationsEnabled'] === "false") {
          return;
        }
        if (unreadArticles.length === 0) {
          return;
        }
        if (unreadArticles.length === 1) {
          return singleNotify(unreadArticles[0]);
        } else {
          return multiNotify(unreadArticles);
        }
      };
      chrome.runtime.onMessage.addListener(function(request) {
        if (request.type !== 'notification') {
          return;
        }
        return notify(request.articles);
      });
      singleNotify = function(article) {
        var notification, options;
        if (hasRichNotifications()) {
          options = {
            type: 'basic',
            title: "New article on " + GlobalConfig.name,
            message: article.title,
            iconUrl: 'images/icon_logo128.png',
            expandedMessage: "" + article.title + " by " + article.author,
            buttons: [
              {
                title: 'Read',
                iconUrl: 'images/read.png'
              }, {
                title: 'Mark As Read',
                iconUrl: 'images/mark_as_read.png'
              }
            ]
          };
          if (typeof article.thumbnail !== 'undefined') {
            options.type = 'image';
            options.imageUrl = article.thumbnail;
          }
          localStorage['notification'] = angular.toJson({
            type: 'single',
            link: article.link
          });
          return chrome.notifications.create(richNotificationId, options, function() {});
        } else {
          notification = webkitNotifications.createNotification('images/icon_logo48.png', "New article on " + GlobalConfig.name, article.title);
          notification.addEventListener('click', function() {
            notification.cancel();
            Articles.markAsRead(article.link);
            return window.open(article.link);
          });
          notification.show();
          return setTimeout(function() {
            return notification.cancel();
          }, 5000);
        }
      };
      multiNotify = function(articles) {
        var articleList, messageText, notification, options;
        articleList = articles.map(function(article) {
          return {
            title: article.title,
            message: ''
          };
        });
        if (localStorage['notificationsEnabled'] === "false") {
          return;
        }
        messageText = "\"" + articles[0].title + "\" and " + (articles.length - 1) + " ";
        messageText += articles.length - 1 === 1 ? "other" : "others";
        if (hasRichNotifications()) {
          options = {
            type: 'list',
            title: "" + articles.length + " new articles on " + GlobalConfig.name,
            message: messageText,
            iconUrl: 'images/icon_logo128.png',
            items: articleList,
            buttons: [
              {
                title: 'Read',
                iconUrl: 'images/read.png'
              }, {
                title: 'Mark All As Read',
                iconUrl: 'images/mark_as_read.png'
              }
            ]
          };
          localStorage['notification'] = angular.toJson({
            type: 'multi',
            link: GlobalConfig.homepage
          });
          return chrome.notifications.create(richNotificationId, options, function() {});
        } else {
          notification = webkitNotifications.createNotification('images/icon_logo48.png', "" + articles.length + " new articles on " + GlobalConfig.name, messageText);
          notification.addEventListener('click', function() {
            notification.cancel();
            Articles.markAllAsRead();
            return window.open(GlobalConfig.homepage);
          });
          notification.show();
          return setTimeout(function() {
            return notification.cancel();
          }, 5000);
        }
      };
      return {
        richNotificationId: richNotificationId,
        notify: notify,
        singleNotify: singleNotify,
        multiNotify: multiNotify
      };
    }
  ]);

  omgUtil.service('Badge', [
    function() {
      var notify;
      notify = function(unreadArticles) {
        if (unreadArticles.length === 0) {
          chrome.browserAction.setBadgeText({
            text: ""
          });
          return chrome.browserAction.setIcon({
            path: 'images/icon_inactive38.png'
          });
        } else {
          chrome.browserAction.setBadgeText({
            text: "" + unreadArticles.length
          });
          return chrome.browserAction.setIcon({
            path: 'images/icon_active38.png'
          });
        }
      };
      chrome.runtime.onMessage.addListener(function(request) {
        if (request.type !== 'badge') {
          return;
        }
        return notify(request.articles);
      });
      return {
        notify: notify
      };
    }
  ]);

  omgUtil.directive('eatClick', [
    function() {
      return function(scope, element, attrs) {
        return element[0].onclick = function(event) {
          return false;
        };
      };
    }
  ]);

}).call(this);
