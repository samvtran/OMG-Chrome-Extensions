###
Copyright (C) 2012 Ohso Ltd

Licensed to the Apache Software Foundation (ASF) under one
or more contributor license agreements. You may obtain a
copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing,
software distributed under the License is distributed on an
"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
KIND, either express or implied.  See the License for the
specific language governing permissions and limitations
under the License.
###
'use strict'
omgFeed = "http://feeds.feedburner.com/d0od?format=xml"

# IndexedDB
window.indexedDB = window.indexedDB || window.webkitIndexedDB
window.IDBTransaction = window.IDBTransaction || window.webkitIDBTransaction
window.IDBKeyRange = window.IDBKeyRange || window.webkitIDBKeyRange
window.IDBCursor = window.IDBCursor || window.webkitIDBCursor

readWrite = if typeof IDBTransaction.READ_WRITE is 'undefined' then 'readwrite' else IDBTransaction.READ_WRITE
readOnly = if typeof IDBTransaction.READ_ONLY is 'undefined' then 'readonly' else IDBTransaction.READ_ONLY
cursorPrev = if typeof IDBTransaction.PREV is 'undefined' then 'prev' else IDBTransaction.PREV

# Chrome < 22 uses deprecated IndexedDB upgrading, so we need to catch it
chromeVersion = parseInt window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10
db = undefined
DB_VERSION = 1

# Defaults set up
if typeof localStorage['unread'] is 'undefined'
  localStorage['unread'] = 0

if typeof localStorage['pollInterval'] is 'undefined'
  localStorage['pollInterval'] = 600000

if typeof localStorage['notificationsEnabled'] is 'undefined'
  localStorage['notificationsEnabled'] = true


omgBackground = angular.module 'omgBackground', ['omgUtil']

omgBackground.controller 'backgroundCtrl', ['databaseService', 'Badge', 'Articles', (databaseService, Badge, Articles) ->
  Badge.notify()
  databaseService.open().then (event) ->
    Articles.getLatestArticles()
  Articles.getArticlesOnTimeout()
]


omgApp = angular.module 'omgApp', ['omgUtil']

omgApp.controller 'popupCtrl', ['$scope', 'databaseService', 'Articles', 'LocalStorage', 'Badge', ($scope, databaseService, Articles, LocalStorage, Badge) ->
  Badge.notify()
  databaseService.open().then (event) ->
    Articles.getArticles().then (articles) ->
      $scope.latestArticles = articles

  $scope.markAsRead = (index) ->
    if $scope.latestArticles[index].unread is true
      LocalStorage.decrement()
      $scope.latestArticles[index].unread = false;
      db.transaction(['articles'], readWrite).objectStore('articles').put($scope.latestArticles[index])

  $scope.markAllAsRead = () ->
    LocalStorage.reset()
    for article in $scope.latestArticles
      if article.unread is true
        article.unread = false
        db.transaction(['articles'], readWrite).objectStore('articles').put(article)
  $scope.refresh = () ->
    $scope.refreshing = true;
    databaseService.open().then (event) ->
      Articles.getLatestArticles().then () ->
        Articles.getArticles().then (articles) ->
          $scope.latestArticles = articles
          $scope.refreshing = false;

  $scope.optionsPage = () ->
    chrome.tabs.create
      url: "options.html"
]


omgOptions = angular.module 'omgOptions', []

omgOptions.controller 'optionCtrl', ['$scope', ($scope) ->
  $scope.notificationsEnabled = (if localStorage['notificationsEnabled'] is "true" then true else false)

  $scope.$watch 'notificationsEnabled', (newValue) ->
    if newValue != (if localStorage['notificationsEnabled'] is "true" then true else false)
      localStorage['notificationsEnabled'] = newValue

  $scope.showExampleNotification = () ->
    webkitNotifications.createNotification('/images/icon48.png', "Example notification", "A summary of the new article or the number of new articles would go here!").show()
]

# Util functions
omgUtil = angular.module 'omgUtil', ['ngResource']

omgUtil.service 'databaseService', ['$q', '$rootScope', ($q, $rootScope) ->
  open = () ->
    deferred = $q.defer()
    if typeof db != "undefined" then deferred.resolve()
    request = indexedDB.open 'OMGUbuntu', DB_VERSION
    request.onerror = (event) ->
      console.log "Couldn't open the database"
      $rootScope.$apply () ->
        deferred.reject "Couldn't open the database"
    request.onsuccess = (event) ->
      db = request.result
      if chromeVersion <= 22
        if db.version != "1" || typeof db.version is "undefined"
          versionReq = db.setVersion DB_VERSION
          versionReq.onfailure = (event) ->
            $rootScope.$apply () ->
              deferred.resolve()
          versionReq.onsuccess = (event) ->
            # Note: Old indexeddb uses keypath as already descended in object
            createStores()
            $rootScope.$apply () ->
              deferred.resolve()
        else
          $rootScope.$apply () ->
            deferred.resolve()
      else
        $rootScope.$apply () ->
          deferred.resolve()
    request.onupgradeneeded = (event) ->
      console.log "Chrome >= 23: Database needs upgrading"
      db = event.target.result
      # Note: new indexeddb uses keypath including object
      createStores()
      $rootScope.$apply () ->
        deferred.resolve()
    deferred.promise

  createStores = () ->
    db.createObjectStore "articles", keyPath: "date"
  {
    open: open
  }
]

omgUtil.service 'Articles', ['$q', '$rootScope', 'LocalStorage', 'Notification', 'databaseService', ($q, $rootScope, LocalStorage, Notification, databaseService)->
  getLatestArticles = () ->
    deferred = $q.defer()
    # Resets notification on every go
    localStorage['newArticles'] = 0
    promises = []
    $.ajax
      url: omgFeed
      dataType: 'xml'
      success: (data) ->
        articles = $(data).find('rss').find('channel').find('item')
        for articleXml in articles
          article = $(articleXml)
          articleObj =
            title: article.find('title').text()
            summary: $('<div>' + article.find('description').text() + '</div>').text()
            link: article.find('origLink').text()
            date: Date.parse article.find('pubDate').text()
            unread: true
          addArticle = _addArticle(articleObj)
          promises.push addArticle
        $q.all(promises).then () ->
          Notification.start()
          deferred.resolve()
      error: () ->
        $rootScope.$apply () ->
          deferred.resolve()
    deferred.promise

  _addArticle = (articleObj) ->
    deferred = $q.defer()
    addArticle = db.transaction(['articles'], readWrite).objectStore('articles').add(articleObj)
    addArticle.onsuccess = (event) ->
      # TODO increment unread if matches categories list
      LocalStorage.increment()
      localStorage['newArticles'] = parseInt(localStorage['newArticles']) + 1
      $rootScope.$apply () ->
        deferred.resolve()
    addArticle.onerror = (event) ->
      $rootScope.$apply () ->
        deferred.resolve()
      return
    deferred.promise

  _getArticlesFromDatabase = () ->
    deferred = $q.defer()
    articles = []
    objectStore = db.transaction(['articles'], readOnly).objectStore('articles')
    objectStore.openCursor(null, cursorPrev).onsuccess = (event) ->
      cursor = event.target.result
      if cursor
        if articles.length < 20
          articles.push cursor.value
        else
          if cursor.value.unread is true
            LocalStorage.decrement()
          db.transaction(['articles'], readWrite).objectStore('articles').delete(cursor.key)
        cursor.continue()
      else
        $rootScope.$apply () ->
          deferred.resolve articles
    deferred.promise

  getArticles = () ->
    deferred = $q.defer()
    objectStore = db.transaction(['articles'], readOnly).objectStore('articles')
    objectStore.count().onsuccess = (event) ->
      if event.target.result < 20
        getLatestArticles().then () ->
          _getArticlesFromDatabase().then (articles) ->
            deferred.resolve articles
      else _getArticlesFromDatabase().then (articles) ->
        deferred.resolve articles
    deferred.promise

  getArticlesOnTimeout = () ->
    setTimeout () ->
      databaseService.open().then (event) ->
        getLatestArticles().then () ->
          getArticles().then () ->
            getArticlesOnTimeout()
    ,localStorage['pollInterval']

  {
    getArticles: getArticles
    getArticlesOnTimeout: getArticlesOnTimeout
    getLatestArticles: getLatestArticles
  }
]

omgUtil.filter 'truncate', () -> (input, count) ->
  final = input;
  if typeof input is "undefined" then return "";
  if input.length <= count
    return final
  truncated = input.substring(0, (count))
  # Is the current EOL whitespace?
  if truncated.substring(truncated.length - 1).match(/\s/)
    final = truncated
  # Is the character after whitespace?
  if input.substring(truncated.length, truncated.length + 1).match(/\s/)
    final = truncated

  # Search backwards until we hit whitespace or the end of the string.
  for i in [1 .. (truncated.length - 1)]
    truncatedTest = truncated.substring(truncated.length - i, truncated.length - (i - 1));
    if truncatedTest.match(/\s/)
      final = truncated.substring(0, truncated.length - i)
      break;
  return final + "..."

omgUtil.filter 'uriEncode', () -> (input) ->
  encodeURIComponent input

omgUtil.service 'Badge', [->
  notify = () ->
    if localStorage['unread'] is "0"
      chrome.browserAction.setBadgeText text: ""
      chrome.browserAction.setIcon path: '/images/icon_unread19.png'
    else
      chrome.browserAction.setBadgeText text: localStorage['unread']
      chrome.browserAction.setIcon path: '/images/icon19.png'

  {
    notify: notify
  }
]

omgUtil.service 'LocalStorage', ['Badge', (Badge)->
  increment = () ->
    localStorage['unread'] = parseInt(localStorage['unread']) + 1
    Badge.notify()
  decrement = () ->
    if localStorage['unread'] is "0" then return
    localStorage['unread'] = parseInt(localStorage['unread']) - 1
    Badge.notify()
  reset = () ->
    localStorage['unread'] = 0
    Badge.notify()

  {
    increment: increment
    decrement: decrement
    reset: reset
  }
]

omgUtil.service 'Notification', ['$filter', ($filter) ->
  start = () ->
    if localStorage['notificationsEnabled'] is "false" then return
    if localStorage['newArticles'] is "0" then return
    if localStorage['newArticles'] is "1"
      objectStore = db.transaction(['articles'], readOnly).objectStore('articles')
      objectStore.openCursor(null, cursorPrev).onsuccess = (event) ->
        cursor = event.target.result
        if cursor
          singleNotify(cursor.value)
    if localStorage['newArticles'] > 1
      multiNotify(localStorage['newArticles'])
  singleNotify = (article) ->
    if localStorage['notificationsEnabled'] is "false" then return
    notification = webkitNotifications.createNotification('/images/icon48.png', "New article! #{article.title}", "#{$filter('truncate')(article.summary, 100)}")
    notification.show()
    setTimeout () ->
      notification.cancel()
    , 7500
  multiNotify = (number) ->
    if localStorage['notificationsEnabled'] is "false" then return
    notification = webkitNotifications.createNotification('/images/icon48.png', 'New articles!', "#{number} new articles on OMG! Ubuntu!")
    notification.show()
    setTimeout () ->
      notification.cancel()
    , 7500

  {
    start: start
    singleNotify: singleNotify
    multiNotify: multiNotify
  }
]
