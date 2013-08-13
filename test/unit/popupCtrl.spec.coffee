describe 'popupCtrl', ->
  beforeEach ->
    module 'omgApp'
    chrome.tabs =
      create: ->
    chrome.notifications =
      onClicked:
        addListener: (callback) ->
          if notificationTest == 1
            callback()
      create: ->
      onButtonClicked:
        addListener: (callback) ->
          if notificationTest == 2
            callback(0, 0)
          if notificationTest == 3
            callback(0, 1)
      clear: (id, callback) -> callback()
  afterEach ->
    delete chrome.notifications
    delete chrome.tabs

  it 'should fetch the latest articles', inject ($controller) ->
    $scope = {}
    popupCtrl = $controller 'popupCtrl', {$scope: $scope}
    expect($scope.latestArticles).toEqual(angular.fromJson localStorage['articles'])

  it 'should retrieve a thumbnail for a given index value', inject ($controller) ->
    $scope = {}
    popupCtrl = $controller 'popupCtrl', {$scope: $scope}
    expect($scope.getThumbnail(0)).toEqual($scope.latestArticles[0].thumbnail)

  it 'should return a placeholder if no thumbnail exists for an article', inject ($controller) ->
    $scope = {}
    popupCtrl = $controller 'popupCtrl', {$scope: $scope}
    expect($scope.getThumbnail(3)).toEqual('images/placeholder100.png')

  it 'should mark a given article as read', inject ($controller, Articles) ->
    $scope = {}
    popupCtrl = $controller 'popupCtrl', {$scope: $scope}
    $scope.latestArticles[0].unread = true
    localStorage['articles'] = angular.toJson $scope.latestArticles
    spyOn(Articles, 'markAsReadAtIndex').andCallThrough()
    expect(angular.fromJson(localStorage['articles'])[0].unread).toBeTruthy()
    $scope.markAsRead(0)
    expect($scope.latestArticles[0].unread).toBeFalsy()
    expect(angular.fromJson(localStorage['articles'])[0].unread).toBeFalsy()
    expect(Articles.markAsReadAtIndex).toHaveBeenCalled()

  it 'should mark all articles as read', inject (Articles, $controller) ->
    $scope = {}
    popupCtrl = $controller 'popupCtrl', {$scope: $scope}
    testIndexes = [0,5,8,9]
    for i in testIndexes
      $scope.latestArticles[i].unread = true
    localStorage['articles'] = angular.toJson $scope.latestArticles
    spyOn(Articles, 'markAllAsRead').andCallThrough()
    spyOn(Articles, 'getArticles').andCallThrough()
    for i in testIndexes
      expect(angular.fromJson(localStorage['articles'])[i].unread).toBeTruthy()
    $scope.markAllAsRead()
    for i in testIndexes
      expect($scope.latestArticles[i].unread).toBeFalsy()
      expect(angular.fromJson(localStorage['articles'])[i].unread).toBeFalsy()

    expect(Articles.markAllAsRead).toHaveBeenCalled()
    expect(Articles.getArticles).toHaveBeenCalled()

  it 'should refresh the article list', inject (Articles, $controller, $httpBackend) ->
    localStorage['articles'] = angular.toJson(angular.fromJson(localStorage['articles']).slice(1))
    $scope = {}
    popupCtrl = $controller 'popupCtrl', {$scope: $scope}
    expect($scope.refreshing).toBeFalsy()
    expect($scope.latestArticles.length).toEqual(17)
    $httpBackend.when('GET', GlobalConfig.url).respond([testData])
    spyOn(Articles, 'fetchLatestArticles').andCallThrough()

    $scope.refresh()
    $httpBackend.flush()
    expect(Articles.fetchLatestArticles).toHaveBeenCalled()
    $httpBackend.verifyNoOutstandingRequest()
    expect($scope.latestArticles.length).toEqual(18)

  it 'should option the options page', inject ($controller) ->
    $scope = {}
    popupCtrl = $controller 'popupCtrl', {$scope: $scope}
    spyOn(chrome.tabs, 'create')
    $scope.optionsPage()
    expect(chrome.tabs.create).toHaveBeenCalledWith({url: 'options.html'})