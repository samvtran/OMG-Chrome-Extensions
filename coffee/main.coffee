###
Copyright (C) 2012-2013 Ohso Ltd

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

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
DB_VERSION = 1

# Defaults set up
do setup = ->
  if typeof localStorage['unread'] is 'undefined'
    localStorage['unread'] = 0

  if typeof localStorage['pollInterval'] is 'undefined'
    localStorage['pollInterval'] = 600000

  if typeof localStorage['notificationsEnabled'] is 'undefined'
    localStorage['notificationsEnabled'] = true

omgBackground = angular.module 'omgBackground', ['omgUtil']

omgBackground.controller 'backgroundCtrl', ['databaseService', 'Badge', 'Articles'
    , (databaseService, Badge, Articles) ->
  Badge.notify()
  Articles.getLatestArticles().then ->
    Articles.getArticlesOnTimeout()
]


omgApp = angular.module 'omgApp', ['omgUtil']

omgApp.controller 'popupCtrl', ['$scope', 'databaseService', 'Articles', 'LocalStorage', 'Badge'
    , ($scope, databaseService, Articles, LocalStorage, Badge) ->
  Badge.notify()
  Articles.getArticles().then (articles) ->
    $scope.latestArticles = articles

  $scope.markAsRead = (index) ->
    if $scope.latestArticles[index].unread is true
      LocalStorage.decrement()
      $scope.latestArticles[index].unread = false
      Articles.markAsRead $scope.latestArticles[index]

  $scope.markAllAsRead = () ->
    LocalStorage.reset()
    for article in $scope.latestArticles
      if article.unread is true
        article.unread = false
        Articles.markAsRead article
        LocalStorage.decrement()
  $scope.refresh = () ->
    $scope.refreshing = true
    Articles.getLatestArticles().then () ->
      Articles.getArticles().then (articles) ->
        $scope.latestArticles = articles
        $scope.refreshing = false

  $scope.optionsPage = () ->
    chrome.tabs.create
      url: "options.html"
]


omgOptions = angular.module 'omgOptions', ['omgUtil']

omgOptions.controller 'optionCtrl', ['$scope', ($scope) ->
  $scope.notificationsEnabled = (if localStorage['notificationsEnabled'] is "true" then true else false)

  $scope.$watch 'notificationsEnabled', (newValue) ->
    if newValue != (if localStorage['notificationsEnabled'] is "true" then true else false)
      localStorage['notificationsEnabled'] = newValue

  $scope.showExampleNotification = () ->
    webkitNotifications.createNotification('/images/icon48.png', "Example notification",
      "A summary of the new article or the number of new articles would go here!").show()
]

# Util functions
omgUtil = angular.module 'omgUtil', ['ngResource']

omgUtil.service 'databaseService', ['$q', '$rootScope', ($q, $rootScope) ->
  db = undefined
  open = ->
    deferred = $q.defer()
    if typeof db != "undefined"
      deferred.resolve
        code: statuses.ALREADY_OPEN
        message: 'Database already open'
    request = indexedDB.open 'OMGUbuntu', DB_VERSION
    request.onerror = (event) ->
      console.log "Couldn't open the database"
      $rootScope.$apply () ->
        deferred.reject
          code: statuses.ERROR
          message: "Couldn't open the database"
    request.onsuccess = (event) ->
      setDb request.result
      if chromeVersion <= 22
        if db.version != "1" || typeof db.version is "undefined"
          versionReq = db.setVersion DB_VERSION
          versionReq.onfailure = (event) ->
            $rootScope.$apply () ->
              deferred.reject
                code: statuses.ERROR
                message: 'Chrome <= 22 error upgrading database'
          versionReq.onsuccess = (event) ->
            createStores().then ->
              deferred.resolve
                code: statuses.OPENED
                message: 'Chrome <= 22 database upgraded and opened'
            , ->
              deferred.reject
                code: statuses.ERROR
                message: 'Upgrading the database failed!'
        else
          $rootScope.$apply () ->
            deferred.resolve
              code: statuses.OPENED
              message: 'Chrome <= 22 database up-to-date and opened'
      else
        $rootScope.$apply () ->
          deferred.resolve
            code: statuses.OPENED
            message: 'Chrome >= 23 database up-to-date and opened'
    request.onupgradeneeded = (event) ->
      console.log 'Chrome >= 23: Database needs upgrading'
      setDb event.target.result
      createStores().then ->
        console.log "Database upgraded!"
        deferred.resolve
          code: statuses.OPENED
          message: 'Upgraded database for Chrome >= 23'
      , ->
        deferred.reject
          code: statuses.ERROR
          message; 'Upgrading the database failed!'
    deferred.promise

  clear = ->
    deferred = $q.defer()
    request = indexedDB.deleteDatabase 'OMGUbuntu'
    request.onsuccess = ->
      $rootScope.$apply ->
        deferred.resolve 'Deleted database successfully'
    request.onerror = ->
      $rootScope.$apply ->
        deferred.reject 'Problem deleting the database'

    deferred.promise

  createStores = ->
    deffered = $q.defer()
    createAction = db.createObjectStore "articles", keyPath: "date"
    createAction.onsuccess = ->
      $rootScope.$apply () ->
        deferred.resolve
    createAction.onerror = ->
      $rootScope.$apply () ->
        deferred.reject
    deffered.promise
  getDb = ->
    deferred = $q.defer()
    open().then ->
      deferred.resolve db
    deferred.promise

  setDb = (openedDb) ->
    $rootScope.$apply ->
      db = openedDb

  statuses =
    CLOSED: 0
    OPENED: 1
    ALREADY_OPEN: 2
    ERROR: 4

  {
    open: open
    clear: clear
    getDb: getDb
    status: statuses
  }
]

omgUtil.service 'Articles', ['$q', '$rootScope', '$http', 'LocalStorage', 'Notification', 'databaseService'
    , ($q, $rootScope, $http, LocalStorage, Notification, databaseService) ->
  getLatestArticles = ->
    deferred = $q.defer()
    # Resets notification on every go
    localStorage['newArticles'] = 0
    promises = []
    $http.get omgFeed,
      headers: 'Accept': 'application/xml'
      transformResponse: (data) -> data
    .success((data) ->
      parser = new DOMParser()
      articleRss =  parser.parseFromString data, 'application/xml'
      items = angular.element(articleRss).find('channel').find('item')
      if items.length < 1
        deferred.reject
          message: "Couldn't get articles"
          response: true
        return
      for articleXml in items
        article = angular.element(articleXml)
        parsedDescription = parser.parseFromString '<div>' +
            article.find('description').text() + '</div>', 'application/xml'
        description = parsedDescription.getElementsByTagName('div')[0]
        thumbnail = 'images/placeholder.png'
        if typeof description.getElementsByTagName('img')[0] != 'undefined'
          thumbnail = description.getElementsByTagName('img')[0].getAttribute('src')

        articleObj =
          title: article.find('title').text()
          summary: description.textContent
          thumbnail: thumbnail
          link: article.find('link').text()
          date: Date.parse article.find('pubDate').text()
          unread: true
        addArticle = _addArticle(articleObj)
        promises.push addArticle
      $q.all(promises).then ->
        Notification.start()
        deferred.resolve()
    ).error( ->
      deferred.reject
        message: 'Error retrieving articles'
        response: false
    )
    deferred.promise

  _addArticle = (articleObj) ->
    deferred = $q.defer()
    databaseService.getDb().then (db) ->
      addArticle = db.transaction(['articles'], readWrite).objectStore('articles').add(articleObj)
      addArticle.onsuccess = (event) ->
        # TODO increment unread if matches categories list
        LocalStorage.increment()
        localStorage['newArticles'] = ~~localStorage['newArticles'] + 1
        $rootScope.$apply ->
          deferred.resolve()
      addArticle.onerror = (event) ->
        $rootScope.$apply ->
          deferred.resolve()
        return
    deferred.promise

  _getArticlesFromDatabase = ->
    deferred = $q.defer()
    articles = []
    totalCount = 0
    databaseService.getDb().then (db) ->
      objectStore = db.transaction(['articles'], readOnly).objectStore('articles')
      objectStore.openCursor(null, cursorPrev).onsuccess = (event) ->
        cursor = event.target.result
        if cursor
          totalCount++
          if articles.length < 18
            articles.push cursor.value
          else if totalCount > 30 # Safeguard against deleted articles
            if cursor.value.unread is true
              LocalStorage.decrement()
            db.transaction(['articles'], readWrite).objectStore('articles').delete(cursor.key)
          cursor.continue()
        else
          $rootScope.$apply ->
            deferred.resolve articles
    deferred.promise

  getArticles = ->
    deferred = $q.defer()
    databaseService.getDb().then (db) ->
      objectStore = db.transaction(['articles'], readOnly).objectStore('articles')
      objectStore.count().onsuccess = (event) ->
        if event.target.result < 18
          getLatestArticles().then ->
            _getArticlesFromDatabase().then (articles) ->
              deferred.resolve articles
        else _getArticlesFromDatabase().then (articles) ->
          deferred.resolve articles
    deferred.promise

  getArticlesOnTimeout = ->
    setTimeout ->
      getLatestArticles().then ->
        getArticles().then ->
          getArticlesOnTimeout()
    ,localStorage['pollInterval']

  markAsRead = (article) ->
    databaseService.getDb().then (db) ->
      db.transaction(['articles'], readWrite).objectStore('articles').put(article)

  {
    getArticles: getArticles
    getArticlesOnTimeout: getArticlesOnTimeout
    getLatestArticles: getLatestArticles
    markAsRead: markAsRead
  }
]

omgUtil.service 'Badge', [ ->
  notify = () ->
    if localStorage['unread'] is "0"
      chrome.browserAction.setBadgeText text: ""
      chrome.browserAction.setIcon path: 'images/icon_unread19.png'
    else
      chrome.browserAction.setBadgeText text: localStorage['unread']
      chrome.browserAction.setIcon path: 'images/icon19.png'

  {
    notify: notify
  }
]

omgUtil.directive 'eatClick', [ ->
  (scope, element, attrs) ->
    element[0].onclick = (event) ->
      false
]

omgUtil.service 'LocalStorage', ['Badge', (Badge)->
  increment = () ->
    localStorage['unread'] = ~~localStorage['unread'] + 1
    Badge.notify()
  decrement = () ->
    if localStorage['unread'] is "0" then return
    localStorage['unread'] = ~~localStorage['unread'] - 1
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

omgUtil.filter 'truncate', -> (input, count) ->
  final = input
  if typeof input is "undefined" then return ""
  if input.length <= count
    return final
  truncated = input.substring(0, count)

  # Is the character after whitespace?
  if input.substring(truncated.length, truncated.length + 1).match(/\s/)
    final = truncated
  else # Search backwards until we hit whitespace or the end of the string.
    for i in [1 .. (truncated.length - 1)] by 1
      truncatedTest = truncated.substring(truncated.length - i, truncated.length - (i - 1))
      if truncatedTest.match(/\s/)
        final = truncated.substring(0, truncated.length - i)
        break
  final + "..."

omgUtil.service 'Notification', ['$filter', 'databaseService', ($filter, databaseService) ->
  start = () ->
    if localStorage['notificationsEnabled'] is "false" then return
    if localStorage['newArticles'] is "0" then return
    if localStorage['newArticles'] is "1"
      databaseService.getDb().then (db) ->
        objectStore = db.transaction(['articles'], readOnly).objectStore('articles')
        objectStore.openCursor(null, cursorPrev).onsuccess = (event) ->
          cursor = event.target.result
          if cursor and cursor.value
            singleNotify(cursor.value)
    if localStorage['newArticles'] > 1
      multiNotify localStorage['newArticles']
  singleNotify = (article, timeout) ->
    if localStorage['notificationsEnabled'] is "false" then return
    notification = webkitNotifications.createNotification('images/icon48.png',
      "New article! #{article.title}", "#{$filter('truncate')(article.summary, 100)}")
    notification.addEventListener 'click', () ->
      notification.cancel()
      window.open article.link
    notification.show()
    setTimeout () ->
      notification.cancel()
    , if typeof timeout != 'undefined' then timeout else 7500
  multiNotify = (number, timeout) ->
    if localStorage['notificationsEnabled'] is "false" then return
    notification = webkitNotifications.createNotification('images/icon48.png', 'New articles!',
      "#{number} new articles on OMG! Ubuntu!")
    notification.addEventListener 'click', () ->
      notification.cancel()
      window.open 'http://omgubuntu.co.uk'
    notification.show()
    setTimeout () ->
      notification.cancel()
    , if typeof timeout != 'undefined' then timeout else 7500

  {
    start: start
    singleNotify: singleNotify
    multiNotify: multiNotify
  }
]
