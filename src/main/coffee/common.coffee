'use strict'

do setup = ->
  if typeof localStorage['pollInterval'] is 'undefined'
    localStorage['pollInterval'] = 900000

  if typeof localStorage['notificationsEnabled'] is 'undefined'
    localStorage['notificationsEnabled'] = true


# Common utilities and controllers
omgBackground = angular.module('omgBackground', ['omgUtil'])
omgBackground.controller('backgroundCtrl', ['Articles', 'Notifier', 'Badge', (Articles, Notifier, Badge) ->
  if Notifier.hasRichNotifications()
    chrome.notifications.onShowSettings.addListener ->
      chrome.windows.create url: '/options.html', focused: true
  Articles.fetchLatestArticles().then ->
    Articles.fetchLatestArticlesOnTimeout()
  chrome.notifications.onClicked.addListener ->
    notification = angular.fromJson localStorage['notification']
    if notification.type == 'single'
      window.open notification.link
      Articles.markAsRead notification.link
    else
      window.open notification.link
      Articles.markAllAsRead()
    chrome.notifications.clear Notifier.richNotificationId, ->
  chrome.notifications.onButtonClicked.addListener (id, idx) ->
    notification = angular.fromJson localStorage['notification']
    if notification.type == 'single'
      if idx == 0
        window.open notification.link
        Articles.markAsRead notification.link
      else
        Articles.markAsRead notification.link
    else
      if idx == 0
        window.open GlobalConfig.homepage
        Articles.markAllAsRead()
      else
        Articles.markAllAsRead()
    chrome.notifications.clear Notifier.richNotificationId, ->
])

omgApp = angular.module 'omgApp', ['omgUtil']

omgApp.controller 'popupCtrl', ['$scope', 'Articles', 'Notifier', ($scope, Articles, Notifier) ->
  $scope.linkToHome =
    url: GlobalConfig.homepage
    title: GlobalConfig.name
  $scope.latestArticles = Articles.getArticles()

  $scope.getThumbnail = (index) ->
    thumbnail = $scope.latestArticles[index].thumbnail
    if typeof thumbnail != 'undefined' then thumbnail else 'images/placeholder100.png'

  $scope.markAsRead = (index) ->
    Notifier.dismissAll()
    $scope.latestArticles[index].unread = false
    Articles.markAsReadAtIndex(index)

  $scope.markAllAsRead = () ->
    Notifier.dismissAll()
    Articles.markAllAsRead()
    $scope.latestArticles = Articles.getArticles()

  $scope.refresh = () ->
    $scope.refreshing = true
    Articles.fetchLatestArticles().then ->
      $scope.latestArticles = Articles.getArticles()
      $scope.refreshing = false

  $scope.optionsPage = () ->
    chrome.tabs.create { url: "options.html" }
]

omgOptions = angular.module 'omgOptions', ['omgUtil']

omgOptions.controller 'optionCtrl', ['$scope', '$sce', ($scope, $sce) ->
  $scope.GlobalConfig = GlobalConfig
  $scope.intro = $sce.trustAsHtml(GlobalConfig.intro)
  $scope.notificationsEnabled = (if localStorage['notificationsEnabled'] == "true" then true else false)

  $scope.$watch 'notificationsEnabled', (newValue) ->
    if newValue != (if localStorage['notificationsEnabled'] == "true" then true else false)
      localStorage['notificationsEnabled'] = newValue

  $scope.showExampleNotification = () ->
    webkitNotifications.createNotification('/images/icon_logo48.png', "Example notification",
      "A summary of the new article or the number of new articles would go here!").show()
]


omgUtil = angular.module('omgUtil', [])

# Workaround to avoid circular dependency
omgUtil.service 'Messenger', [ ->
  {
    notify: {
      badge: (articles) ->
        chrome.runtime.sendMessage {type: 'badge', articles: articles}
      notification: (articles) ->
        chrome.runtime.sendMessage {type: 'notification', articles: articles}
    }
  }
]

omgUtil.service 'Articles', ['$http', '$q', 'Messenger', ($http, $q, Messenger) ->
  fetchLatestArticles = ->
    deferred = $q.defer()
    $http.get GlobalConfig.url,
      transformResponse: (data) -> new DOMParser().parseFromString data, 'application/xml'
    .success (data) ->
      items = angular.element(data).find('channel').find('item')
      if items.length < 1
        deferred.resolve [] # Never reject/fail. Continue on as if there weren't any articles.
        return
      articles = []
      for item in items
        thumbnail = item.querySelector('thumbnail')
        article =
          title: item.querySelector('title').textContent
          author: item.querySelector('creator').textContent
          link: item.querySelector('link').textContent
          date: Date.parse item.querySelector('pubDate').textContent
          unread: true
        if thumbnail != null then article.thumbnail = thumbnail.getAttribute('url')
        articles.push article
      putLatestArticlesAndNotify(articles)
      deferred.resolve articles
    .error ->
      deferred.resolve []
    deferred.promise
  fetchLatestArticlesOnTimeout = ->
    setTimeout ->
      fetchLatestArticles().then ->
        fetchLatestArticlesOnTimeout()
    , localStorage['pollInterval']
  putLatestArticlesAndNotify = (articles) ->
    newArticles = []
    if typeof localStorage['unread'] != 'undefined' # Catch upgrading users and don't notify
      for article in articles
        article.unread = false
      localStorage.removeItem 'unread'
    existingArticles = getArticles()
    yesterday = new Date()
    yesterday.setDate(yesterday.getDate() - 1)
    yesterday = yesterday.getTime()
    if existingArticles.length > 0
      latestNewArticleSlice = -1
      for i in [0..articles.length - 1] by 1
        if existingArticles[0].link == articles[i].link # Our latest article is at index i in the feed's updated list
          latestNewArticleSlice = i
          for j in [i..articles.length - 1] by 1
            if articles[j].date > yesterday # Article is less than a day old, so update title and thumbnail if it exists
              existingArticles[j - i].title = articles[j].title
              if typeof articles[j].thumbnail != 'undefined'
                existingArticles[j - i].thumbnail = articles[j].thumbnail
            else # Exit as soon as we hit an article more than a day old
              break
          break
      # TODO fix this condition: what happens when all articles are too old?
      if latestNewArticleSlice < 0 # Clear the notification badge and don't do anything
#        console.log 'Clearing the badge'
#        Messenger.notify.badge []
#        return
        newArticles = articles
      else
        newArticles = articles.slice(0, latestNewArticleSlice)
    else
      newArticles = articles

    uniqueArticles = checkExistingArticles(existingArticles, newArticles)
    putArticles uniqueArticles.concat existingArticles
    unreadArticles = getUnreadArticles()
    Messenger.notify.badge unreadArticles
    Messenger.notify.notification uniqueArticles

  checkExistingArticles = (existing, newArticles) ->
    uniqueArticles = []
    paths = existing.map (article) -> article.link
    for i in [0..newArticles.length - 1] by 1
      if paths.indexOf(newArticles[i].link) == -1
        uniqueArticles.push(newArticles[i])
    uniqueArticles

  putArticles = (articlesJson) ->
    localStorage['articles'] = angular.toJson articlesJson.slice(0, 30)
  getArticles = ->
    articles = angular.fromJson localStorage['articles']
    if typeof articles == 'undefined' then return []
    articles.sort (a, b) -> # Sort by date descending
      b.date - a.date
  getUnreadArticles = ->
    articles = getArticles()
    unreadArticles = []
    for article in articles
      if article.unread == true then unreadArticles.push article
    unreadArticles
  markAllAsRead = ->
    articles = getArticles()
    for article in articles
      article.unread = false
    putArticles articles
    Messenger.notify.badge getUnreadArticles()
  markAsRead = (articleLink) ->
    articles = getArticles()
    for article in articles
      if article.link == articleLink
        article.unread = false
    putArticles articles
    Messenger.notify.badge getUnreadArticles()
  markAsReadAtIndex = (index) ->
    articles = getArticles()
    articles[index].unread = false
    putArticles articles
    Messenger.notify.badge getUnreadArticles()

  {
    fetchLatestArticles: fetchLatestArticles
    fetchLatestArticlesOnTimeout: fetchLatestArticlesOnTimeout
    putLatestArticlesAndNotify: putLatestArticlesAndNotify
    putArticles: putArticles
    getArticles: getArticles
    getUnreadArticles: getUnreadArticles
    markAllAsRead: markAllAsRead
    markAsRead: markAsRead
    markAsReadAtIndex: markAsReadAtIndex
    checkExistingArticles: checkExistingArticles
  }
]

omgUtil.service('Notifier', ['Articles', (Articles) ->
  richNotificationId = "#{GlobalConfig.tag}ExtensionNotification"
  dismissAll = ->
    if hasRichNotifications()
      chrome.notifications.clear richNotificationId, ->
  hasRichNotifications = ->
    typeof chrome.notifications != 'undefined'
  notify = (unreadArticles) ->
    if localStorage['notificationsEnabled'] == "false" then return
    if unreadArticles.length is 0 then return
    if unreadArticles.length is 1
      singleNotify(unreadArticles[0])
    else
      multiNotify(unreadArticles)
  chrome.runtime.onMessage.addListener (request) ->
    if request.type != 'notification' then return
    notify(request.articles)
  singleNotify = (article) ->
    if hasRichNotifications()
      options =
        type: 'basic'
        title: "New article on #{GlobalConfig.name}"
        message: article.title
        iconUrl: 'images/icon_logo128.png'
        expandedMessage: "#{article.title} by #{article.author}"
        buttons: [
          {
            title: 'Read'
            iconUrl: 'images/read.png'
          }
          {
            title: 'Mark As Read'
            iconUrl: 'images/mark_as_read.png'
          }
        ]
      if typeof article.thumbnail != 'undefined'
        options.type = 'image'
        options.imageUrl = article.thumbnail
      localStorage['notification'] = angular.toJson {type: 'single', link: article.link}
      chrome.notifications.create richNotificationId, options, ->
    else
      notification = webkitNotifications.createNotification('images/icon_logo48.png',
        "New article on #{GlobalConfig.name}", article.title)
      notification.addEventListener 'click', ->
        notification.cancel()
        Articles.markAsRead article.link
        window.open article.link
      notification.show()
      setTimeout ->
        notification.cancel()
      , 5000
  multiNotify = (articles) ->
    articleList = articles.map (article) ->
      {
        title: article.title
        message: ''
      }
    if localStorage['notificationsEnabled'] is "false" then return
    messageText = "\"#{articles[0].title}\" and #{articles.length - 1} "
    messageText += if articles.length - 1 == 1 then "other" else "others"
    if hasRichNotifications()
      options =
        type: 'list'
        title: "#{articles.length} new articles on #{GlobalConfig.name}"
        message: messageText
        iconUrl: 'images/icon_logo128.png'
        items: articleList
        buttons: [
          {
            title: 'Read'
            iconUrl: 'images/read.png'
          }
          {
            title: 'Mark All As Read'
            iconUrl: 'images/mark_as_read.png'
          }
        ]
      localStorage['notification'] = angular.toJson {type: 'multi', link: GlobalConfig.homepage}
      chrome.notifications.create richNotificationId, options, ->
    else
      notification = webkitNotifications.createNotification('images/icon_logo48.png',
        "#{articles.length} new articles on #{GlobalConfig.name}", messageText)
      notification.addEventListener 'click', ->
        notification.cancel()
        Articles.markAllAsRead()
        window.open GlobalConfig.homepage
      notification.show()
      setTimeout ->
        notification.cancel()
      , 5000

  {
    richNotificationId: richNotificationId
    notify: notify
    singleNotify: singleNotify
    multiNotify: multiNotify
    dismissAll: dismissAll
    hasRichNotifications: hasRichNotifications
  }
])

omgUtil.service 'Badge', [ ->
  notify = (unreadArticles) ->
    if unreadArticles.length == 0
      chrome.browserAction.setBadgeText text: ""
      chrome.browserAction.setIcon path: 'images/icon_inactive38.png'
    else
      chrome.browserAction.setBadgeText text: "#{unreadArticles.length}"
      chrome.browserAction.setIcon path: 'images/icon_active38.png'
  chrome.runtime.onMessage.addListener (request) ->
    if request.type != 'badge' then return
    notify(request.articles)
  {
    notify: notify
  }
]

omgUtil.directive 'eatClick', [ ->
  (scope, element, attrs) ->
    element[0].onclick = (event) ->
      false
]
