describe 'backgroundApp', ->
  beforeEach ->
    module 'omgBackground'
  describe 'backgroundCtrl', ->
    notificationTest = 0 # 1 is click, 2 is click on button 0, 3 is click on button 1
    beforeEach ->
      module ($provide) ->
        $provide.provider 'Articles', ->
          @$get = ->
            {
              fetchLatestArticles: -> {then: (callback) -> callback() }
              fetchLatestArticlesOnTimeout: ->
              markAllAsRead: ->
              markAsRead: ->
            }
        return
        $provide.provider 'Notifier', ->
          @$get = ->
            {
            notify:
              badge: ->
              notification: ->
            }
        return
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

    it 'should fetch the latest articles', inject ($controller, Articles) ->
      spyOn(Articles, 'fetchLatestArticlesOnTimeout')
      $scope = {}
      backgroundCtrl = $controller 'backgroundCtrl', {$scope: $scope}
      expect(Articles.fetchLatestArticlesOnTimeout).toHaveBeenCalled()

    it 'should open a single article when a single notification is clicked', inject ($controller, Articles) ->
      notificationTest = 1
      spyOn(chrome.notifications.onClicked, 'addListener').andCallThrough()
      spyOn(Articles, 'markAsRead')
      spyOn(Articles, 'markAllAsRead')
      spyOn(window, 'open')
      localStorage['notification'] = angular.toJson {type: 'single', link: 'http://example.com/singleNotification'}
      $scope = {}
      backgroundCtrl = $controller 'backgroundCtrl', {$scope: $scope}
      expect(Articles.markAsRead).toHaveBeenCalledWith('http://example.com/singleNotification')
      expect(Articles.markAllAsRead).not.toHaveBeenCalled()
      expect(chrome.notifications.onClicked.addListener.callCount).toEqual(1)
      expect(window.open).toHaveBeenCalledWith('http://example.com/singleNotification')

    it 'should open a single article when a single notification button is clicked', inject ($controller, Articles) ->
      notificationTest = 2
      spyOn(chrome.notifications.onButtonClicked, 'addListener').andCallThrough()
      spyOn(Articles, 'markAsRead')
      spyOn(Articles, 'markAllAsRead')
      spyOn(window, 'open')
      localStorage['notification'] = angular.toJson {type: 'single', link: 'http://example.com/singleNotification'}
      $scope = {}
      backgroundCtrl = $controller 'backgroundCtrl', {$scope: $scope}
      expect(Articles.markAsRead).toHaveBeenCalledWith('http://example.com/singleNotification')
      expect(window.open).toHaveBeenCalledWith('http://example.com/singleNotification')
      expect(Articles.markAllAsRead).not.toHaveBeenCalled()
      expect(chrome.notifications.onButtonClicked.addListener.callCount).toEqual(1)
    it 'should mark a single article as read when a single notification button is clicked', inject ($controller, Articles) ->
      notificationTest = 3
      spyOn(chrome.notifications.onButtonClicked, 'addListener').andCallThrough()
      spyOn(Articles, 'markAsRead')
      spyOn(Articles, 'markAllAsRead')
      spyOn(window, 'open')
      localStorage['notification'] = angular.toJson {type: 'single', link: 'http://example.com/singleNotification'}
      $scope = {}
      backgroundCtrl = $controller 'backgroundCtrl', {$scope: $scope}
      expect(Articles.markAsRead).toHaveBeenCalledWith('http://example.com/singleNotification')
      expect(Articles.markAllAsRead).not.toHaveBeenCalled()
      expect(window.open).not.toHaveBeenCalled()
      expect(chrome.notifications.onButtonClicked.addListener.callCount).toEqual(1)

    it 'should open the homepage when a multi notification is clicked', inject ($controller, Articles) ->
      notificationTest = 1
      spyOn(chrome.notifications.onClicked, 'addListener').andCallThrough()
      spyOn(Articles, 'markAsRead')
      spyOn(Articles, 'markAllAsRead')
      spyOn(window, 'open')
      localStorage['notification'] = angular.toJson {type: 'multi', link: 'http://example.com/multiNotification'}
      $scope = {}
      backgroundCtrl = $controller 'backgroundCtrl', {$scope: $scope}
      expect(Articles.markAllAsRead).toHaveBeenCalledWith()
      expect(Articles.markAsRead).not.toHaveBeenCalled()
      expect(chrome.notifications.onClicked.addListener.callCount).toEqual(1)
      expect(window.open).toHaveBeenCalledWith('http://example.com/multiNotification')
    it 'should open the homepage when a multi notification button is clicked', inject ($controller, Articles) ->
      notificationTest = 2
      spyOn(chrome.notifications.onButtonClicked, 'addListener').andCallThrough()
      spyOn(Articles, 'markAsRead')
      spyOn(Articles, 'markAllAsRead')
      spyOn(window, 'open')
      localStorage['notification'] = angular.toJson {type: 'multi', link: 'http://example.com/multiNotification'}
      $scope = {}
      backgroundCtrl = $controller 'backgroundCtrl', {$scope: $scope}
      expect(Articles.markAllAsRead).toHaveBeenCalledWith()
      expect(Articles.markAsRead).not.toHaveBeenCalled()
      expect(window.open).toHaveBeenCalledWith(GlobalConfig.homepage)
      expect(chrome.notifications.onButtonClicked.addListener.callCount).toEqual(1)
    it 'should mark all as read when a multi notification button is clicked', inject ($controller, Articles) ->
      notificationTest = 3
      spyOn(chrome.notifications.onButtonClicked, 'addListener').andCallThrough()
      spyOn(Articles, 'markAsRead')
      spyOn(Articles, 'markAllAsRead')
      spyOn(window, 'open')
      localStorage['notification'] = angular.toJson {type: 'multi', link: 'http://example.com/multiNotification'}
      $scope = {}
      backgroundCtrl = $controller 'backgroundCtrl', {$scope: $scope}
      expect(Articles.markAllAsRead).toHaveBeenCalledWith()
      expect(Articles.markAsRead).not.toHaveBeenCalled()
      expect(window.open).not.toHaveBeenCalled()
      expect(chrome.notifications.onButtonClicked.addListener.callCount).toEqual(1)