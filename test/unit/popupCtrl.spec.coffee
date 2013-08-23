describe 'popupCtrl', ->
  $scope = {}
  beforeEach ->
    module 'omgApp'
    chrome.tabs =
      create: ->
    chrome.notifications =
      onClicked:
        addListener: ->
      create: ->
      onButtonClicked:
        addListener: ->
      clear: (id, callback) -> callback()

  beforeEach inject ($controller) ->
    $scope = {}
    popupCtrl = $controller 'popupCtrl', {$scope: $scope}

  afterEach ->
    delete chrome.notifications
    delete chrome.tabs

  it 'should fetch the latest articles', ->
    expect($scope.latestArticles).toEqual(angular.fromJson localStorage['articles'])

  it 'should retrieve a thumbnail for a given index value', ->
    expect($scope.getThumbnail(0)).toEqual($scope.latestArticles[0].thumbnail)

  it 'should return a placeholder if no thumbnail exists for an article', ->
    expect($scope.getThumbnail(3)).toEqual('images/placeholder100.png')

  it 'should mark a given article as read', inject (Articles) ->
    $scope.latestArticles[0].unread = true
    localStorage['articles'] = angular.toJson $scope.latestArticles
    spyOn(Articles, 'markAsReadAtIndex').andCallThrough()
    expect(angular.fromJson(localStorage['articles'])[0].unread).toBeTruthy()
    $scope.markAsRead(0)
    expect($scope.latestArticles[0].unread).toBeFalsy()
    expect(angular.fromJson(localStorage['articles'])[0].unread).toBeFalsy()
    expect(Articles.markAsReadAtIndex).toHaveBeenCalled()

  it 'should mark all articles as read', inject (Articles) ->
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

  it 'should refresh the article list', inject (Articles, $httpBackend, $controller) ->
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

  it 'should option the options page', ->
    spyOn(chrome.tabs, 'create')
    $scope.optionsPage()
    expect(chrome.tabs.create).toHaveBeenCalledWith({url: 'options.html'})