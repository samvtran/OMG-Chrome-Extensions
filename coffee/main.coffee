'use strict'
omgApp = angular.module 'omgApp', ['ngResource']
omgFeed = "http://feeds.feedburner.com/d0od?format=xml"

# IndexedDB
window.indexedDB = window.indexedDB || window.webkitIndexedDB
window.IDBTransaction = window.IDBTransaction || window.webkitIDBTransaction
window.IDBKeyRange = window.IDBKeyRange || window.webkitIDBKeyRange
window.IDBCursor = window.IDBCursor || window.webkitIDBCursor

# Chrome < 22 uses deprecated IndexedDB upgrading
chromeVersion = parseInt window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10
db = undefined
DB_VERSION = 1

omgApp.service 'databaseService', ['$q', '$rootScope', ($q, $rootScope) ->
  open = () ->
    deferred = $q.defer()
    request = indexedDB.open 'OMGUbuntu', DB_VERSION
    request.onerror = (event) ->
      console.log "Couldn't open the database"
      $rootScope.$apply () ->
        deferred.reject "Couldn't open the database"
    request.onsuccess = (event) ->
      console.log "Opened db #{request.result.version} successfully"
      db = request.result
      if chromeVersion <= 22
        if db.version != "1" || typeof db.version is "undefined"
          versionReq = db.setVersion(DB_VERSION)
          versionReq.onfailure = () ->
            $rootScope.$apply () ->
              deferred.resolve()
          versionReq.onsuccess = (event) ->
            # Note: Old indexeddb uses keypath as already descended in object
            createStores().then () ->
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
      createStores().then () ->
        deferred.resolve()
    deferred.promise

  createStores = () ->
    deferred = $q.defer()
    createEvent = db.createObjectStore "articles", keyPath: "date"
    createEvent.onsuccess = (event) ->
      console.log "Successfully created object stores"
      $rootScope.$apply () ->
        deferred.resolve()

    deferred.promise

  {
    open: open
  }
]

omgApp.service 'Articles', ['$q', '$rootScope', ($q, $rootScope)->
  _getLatestArticles = () ->
    deferred = $q.defer()
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
            date: moment(article.find('pubDate').text(), 'ddd, DD MMM YYYY HH:mm:ss PST').valueOf()
            unread: true
          addArticle = _addArticle(articleObj)
          promises.push addArticle
        $q.all(promises).then () ->
          deferred.resolve()
      error: () ->
        $rootScope.$apply () ->
          deferred.reject "Issue getting articles"

    deferred.promise
  _addArticle = (articleObj) ->
    deferred = $q.defer()
    addArticle = db.transaction(['articles'], 'readwrite').objectStore('articles').add(articleObj)
    addArticle.onsuccess = (event) ->
      # TODO increment unread if matches categories list
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
    objectStore = db.transaction(['articles'], 'readonly').objectStore('articles')
    objectStore.openCursor(null, "prev").onsuccess = (event) ->
      cursor = event.target.result
      if cursor
        console.log cursor
        if articles.length < 20
          articles.push cursor.value
        else
          console.log "Would delete #{cursor.value.title}"
          db.transaction(['articles'], 'readwrite').objectStore('articles').delete(cursor.key)
        cursor.continue()
      else
        $rootScope.$apply () ->
          deferred.resolve articles
    deferred.promise

  getArticles = () ->
    console.log "Getting articles"
    deferred = $q.defer()
    objectStore = db.transaction(['articles'], 'readonly').objectStore('articles')
    objectStore.count().onsuccess = (event) ->
      console.log "Got back #{event.target.result} articles"
      if event.target.result < 20
        _getLatestArticles().then () ->
          console.log "Got latest articles"
          _getArticlesFromDatabase().then (articles) ->
            console.log "Got latest articles from database"
            console.log articles
            deferred.resolve articles
      else _getArticlesFromDatabase().then (articles) ->
        deferred.resolve articles
    deferred.promise

  {
    getArticles: getArticles
  }
]
omgApp.controller 'popupCtrl', ['$scope', '$resource', 'databaseService', 'Articles', ($scope, $resource, databaseService, Articles) ->
  databaseService.open().then (event) ->
    console.log "Moving on"
    Articles.getArticles().then (articles) ->
      console.log articles
      $scope.latestArticles = articles

  $scope.markAsRead = (index) ->
    if $scope.latestArticles[index].unread is true
      $scope.latestArticles[index].unread = false;
      db.transaction(['articles'], 'readwrite').objectStore('articles').put($scope.latestArticles[index])

  $scope.markAllAsRead = () ->
    for article in $scope.latestArticles
      if article.unread is true
        article.unread = false
        db.transaction(['articles'], 'readwrite').objectStore('articles').put(article)

]

omgApp.filter 'truncate', () -> (input, count) ->
  final = input;
  if input == undefined then return "";
  if input.length <= count
    return final
  truncated = input.substring(0, (count))
  # Is the current EOL whitespace?
  if truncated.substring(truncated.length - 1).match(/\s/)
    final = truncated
  # Is the character after whitespace?
  if input.substring(truncated.length, truncated.length + 1).match(/\s/)
    final = truncated

  for i in [1 .. (truncated.length - 1)]
    truncatedTest = truncated.substring(truncated.length - i, truncated.length - (i - 1));
    if truncatedTest.match(/\s/)
      final = truncated.substring(0, truncated.length - i)
      break;
  return final + "..."
