describe 'optionsCtrl', ->
  optionsValues = {}

  beforeEach -> module 'omgOptions'
  beforeEach inject ($rootScope, $compile) ->
    optionsValues.element = angular.element '<input ng-model="notificationsEnabled" type="checkbox" id="notifications-enabled">'
    $compile(optionsValues.element)($rootScope)
    $rootScope.$digest()

  it 'should check and uncheck the notificationsEnabled checkbox', inject ($controller, $rootScope) ->
    $scope = $rootScope
    optionCtrl = $controller 'optionCtrl', {$scope: $scope}
    $scope.$apply()
    expect(optionsValues.element[0].checked).toBeTruthy()

  it 'should uncheck the notificationsEnabled checkbox', inject ($controller, $rootScope) ->
    localStorage['notificationsEnabled'] = false
    $scope = $rootScope
    optionCtrl = $controller 'optionCtrl', {$scope: $scope}
    $scope.$apply()
    expect(optionsValues.element[0].checked).toBeFalsy()
    localStorage['notificationsEnabled'] = true

  it 'should check and uncheck the notificationsEnabled checkbox when clicked', inject ($controller, $rootScope) ->
    localStorage['notificationsEnabled'] = false
    $scope = $rootScope
    optionCtrl = $controller 'optionCtrl', {$scope: $scope}
    $scope.$apply()
    expect(optionsValues.element[0].checked).toBeFalsy()
    ev = document.createEvent("MouseEvent")
    ev.initMouseEvent(
      "click",
      true, true,
      window, null,
      0, 0, 0, 0,
      false, false, false, false,
      0, null
    )
    optionsValues.element[0].dispatchEvent(ev)
    $scope.$apply()
    expect(optionsValues.element[0].checked).toBeTruthy()
    ev = document.createEvent("MouseEvent")
    ev.initMouseEvent(
      "click",
      true, true,
      window, null,
      0, 0, 0, 0,
      false, false, false, false,
      0, null
    )
    optionsValues.element[0].dispatchEvent(ev)
    $scope.$apply()
    expect(optionsValues.element[0].checked).toBeFalsy()
    localStorage['notificationsEnabled'] = true

  it 'should show an example notification when prompted', inject ($controller, $rootScope) ->
    $scope = $rootScope
    optionCtrl = $controller 'optionCtrl', {$scope: $scope}
    spyOn(webkitNotifications, 'createNotification').andCallFake (image, text) ->
      expect(image).toEqual('/images/icon_logo48.png')
      expect(text).toEqual('Example notification')
      {
        show: ->
      }
    $scope.showExampleNotification()
    expect(webkitNotifications.createNotification).toHaveBeenCalled()