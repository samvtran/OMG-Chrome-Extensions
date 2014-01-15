describe 'backgroundApp', ->
  notificationTestIndex = -1 # 1 is click, 2 is click on button 0, 3 is click on button 1
  notificationTest = [0,1,2,3,1,2,3]

  beforeEach -> module 'omgBackground'
  beforeEach ->
    mockArticles =
      fetchLatestArticles: -> {then: (callback) -> callback() }
      fetchLatestArticlesOnTimeout: ->
      markAllAsRead: ->
      markAsRead: ->
    mockNotifier =
      notify:
        badge: ->
        notification: ->
      hasRichNotifications: ->
    angular.mock.module ($provide) ->
      $provide.value 'Articles', mockArticles
      null
    angular.mock.module ($provide) ->
      $provide.value 'Notifier', mockNotifier
      null


    chrome.notifications =
      onClicked:
        addListener: (callback) ->
          if notificationTest[notificationTestIndex] == 1
            callback()
      create: ->
      onButtonClicked:
        addListener: (callback) ->
          if notificationTest[notificationTestIndex] == 2
            callback(0, 0)
          if notificationTest[notificationTestIndex] == 3
            callback(0, 1)
      clear: (id, callback) -> callback()

  beforeEach inject ($controller, Articles) ->
    spyOn(Articles, 'fetchLatestArticlesOnTimeout')
    spyOn(chrome.notifications.onClicked, 'addListener').andCallThrough()
    spyOn(chrome.notifications.onButtonClicked, 'addListener').andCallThrough()
    spyOn(Articles, 'markAsRead')
    spyOn(Articles, 'markAllAsRead')
    spyOn(window, 'open')
    notificationTestIndex++
    if (notificationTestIndex <= 3)
      localStorage['notification'] = angular.toJson {type: 'single', link: 'http://example.com/singleNotification'}
    else
      localStorage['notification'] = angular.toJson {type: 'multi', link: 'http://example.com/multiNotification'}
    $scope = {}
    $controller 'backgroundCtrl', {$scope: $scope}

  afterEach ->
    delete chrome.notifications

  it 'should fetch the latest articles', inject ($controller, Articles) ->
    expect(Articles.fetchLatestArticlesOnTimeout).toHaveBeenCalled()

  it 'should open a single article when a single notification is clicked', inject ($controller, Articles) ->
    expect(Articles.markAsRead).toHaveBeenCalledWith('http://example.com/singleNotification')
    expect(Articles.markAllAsRead).not.toHaveBeenCalled()
    expect(chrome.notifications.onClicked.addListener.callCount).toEqual(1)
    expect(window.open).toHaveBeenCalledWith('http://example.com/singleNotification')

  it 'should open a single article when a single notification button is clicked', inject ($controller, Articles) ->
    expect(Articles.markAsRead).toHaveBeenCalledWith('http://example.com/singleNotification')
    expect(window.open).toHaveBeenCalledWith('http://example.com/singleNotification')
    expect(Articles.markAllAsRead).not.toHaveBeenCalled()
    expect(chrome.notifications.onButtonClicked.addListener.callCount).toEqual(1)
  it 'should mark a single article as read when a single notification button is clicked', inject ($controller, Articles) ->
    expect(Articles.markAsRead).toHaveBeenCalledWith('http://example.com/singleNotification')
    expect(Articles.markAllAsRead).not.toHaveBeenCalled()
    expect(window.open).not.toHaveBeenCalled()
    expect(chrome.notifications.onButtonClicked.addListener.callCount).toEqual(1)

  it 'should open the homepage when a multi notification is clicked', inject ($controller, Articles) ->
    expect(Articles.markAllAsRead).toHaveBeenCalledWith()
    expect(Articles.markAsRead).not.toHaveBeenCalled()
    expect(chrome.notifications.onClicked.addListener.callCount).toEqual(1)
    expect(window.open).toHaveBeenCalledWith('http://example.com/multiNotification')
  it 'should open the homepage when a multi notification button is clicked', inject ($controller, Articles) ->
    expect(Articles.markAllAsRead).toHaveBeenCalledWith()
    expect(Articles.markAsRead).not.toHaveBeenCalled()
    expect(window.open).toHaveBeenCalledWith(GlobalConfig.homepage)
    expect(chrome.notifications.onButtonClicked.addListener.callCount).toEqual(1)
  it 'should mark all as read when a multi notification button is clicked', inject ($controller, Articles) ->
    expect(Articles.markAllAsRead).toHaveBeenCalledWith()
    expect(Articles.markAsRead).not.toHaveBeenCalled()
    expect(window.open).not.toHaveBeenCalled()
    expect(chrome.notifications.onButtonClicked.addListener.callCount).toEqual(1)