'use strict'

describe 'Setup', ->
  it 'sets the pollInterval to 900000ms', ->
    localStorage.removeItem 'pollInterval'
    expect(localStorage['pollInternval']).toBeFalsy()
    setup();
    expect(localStorage['pollInterval']).toBe('900000')

  it 'enables notifications', ->
    localStorage.removeItem 'notificationsEnabled'
    expect(typeof localStorage['notificationsEnabled']).toBe('undefined')
    setup();
    expect(localStorage['notificationsEnabled']).toBe('true')

describe 'omgUtil module', ->
  beforeEach ->
    module 'omgUtil'

  addListenerCalls = 1
  chrome.runtime =
    onMessage:
      addListener: (req) ->
        if addListenerCalls == 1
          req({type: 'badge', articles: []})
        else if addListenerCalls == 2
          req({type: 'bodge', articles: []})
        else if addListenerCalls == 3
          req({type: 'notification', articles: []})
        else if addListenerCalls == 4
          req({type: 'botificationes', articles: []})
        addListenerCalls++

  spyOn(chrome.runtime.onMessage, 'addListener')
  describe 'Messenger service', ->
    it 'should create an event for type badge', inject (Messenger) ->
      chrome.runtime.sendMessage = ->
      spyOn(chrome.runtime, 'sendMessage').andCallFake (obj) ->
        expect(obj.type).toEqual('badge')
      Messenger.notify.badge([])
    it 'should create an event for type notification', inject (Messenger) ->
      chrome.runtime.sendMessage = ->
      spyOn(chrome.runtime, 'sendMessage').andCallFake (obj) ->
        expect(obj.type).toEqual('notification')
      Messenger.notify.notification([])
  describe 'Badge service', ->
    setIconCalls = 1
    setBadgeTextCalls = 1
    chrome.browserAction =
      setIcon: (obj) ->
        if setIconCalls <= 2
          expect(obj.path).toEqual('images/icon_inactive38.png')
        else if setIconCalls <= 4
          expect(obj.path).toEqual('images/icon_active38.png')
        setIconCalls++
      setBadgeText: (obj) ->
        if setBadgeTextCalls <= 2
          expect(obj.text).toEqual('')
        else if setBadgeTextCalls == 3
          expect(obj.text).toEqual('4')
        setBadgeTextCalls++

    spyOn(chrome.browserAction, 'setIcon')

    it 'should accept an empty array and set the badge text to an empty string', inject (Badge) ->
      Badge.notify []

    it 'should accept an arbitrarily sized array and use the length as the badge text', inject (Badge) ->
      Badge.notify [1, 2, 3, 4]

  describe 'Notifier service', ->
    chrome.browserAction =
      setIcon: ->
      setBadgeText: ->

    spyOn(chrome.browserAction, 'setIcon')

    it 'should accept an empty array and not issue a notification', inject (Notifier) ->
      Notifier.notify([])
    it 'should not issue a notification if notifications are disabled', inject (Notifier) ->
      localStorage['notificationsEnabled'] = false
      Notifier.notify([])
      localStorage['notificationsEnabled'] = true
    describe 'should show a single-article notification', ->
      it 'should accept an array of size one and prompt for a single-article notification', inject (Notifier) ->
        spyOn(webkitNotifications, 'createNotification').andCallFake (icon, title, message) ->
          expect(icon).toEqual("images/icon_logo48.png")
          expect(title).toEqual("New article on #{GlobalConfig.name}")
          expect(message).toEqual("Article 1")
          {
            addEventListener: (type, callback) -> callback()
            show: ->
            cancel: ->
          }
        spyOn(window, 'setTimeout').andCallFake((callback, timer) ->
          expect(timer).toEqual(5000)
          callback()
        )
        Notifier.notify([{title: 'Article 1', author: 'Paddington Bear', link: 'http://www.omgubuntu.co.uk'}])
        expect(webkitNotifications.createNotification).toHaveBeenCalled()
        expect(window.setTimeout).toHaveBeenCalled()
      it 'should create a chrome.notification if chrome.notification is available', inject (Notifier) ->
        chrome.notifications =
          onClicked:
            addListener: ->
          onButtonClicked:
            addListener: ->
          create: ->
          clear: ->
          addEventListener: ->

        spyOn(window, 'open')
        spyOn webkitNotifications, 'createNotification'
        spyOn(chrome.notifications, 'clear').andCallFake((id, callback) -> callback())
        spyOn(chrome.notifications, 'create').andCallFake (id, options, callback) ->
          callback()
          expect(options.type).toEqual('basic')
          expect(options.iconUrl).toEqual("images/icon_logo128.png")
          expect(options.title).toEqual("New article on #{GlobalConfig.name}")
          expect(options.message).toEqual("Article 1")
        Notifier.notify([{title: 'Article 1', author: 'Paddington Bear', link: 'http://www.omgubuntu.co.uk'}])
        expect(chrome.notifications.create).toHaveBeenCalled()
        expect(webkitNotifications.createNotification).not.toHaveBeenCalled()
      it 'should create an image notification if a thumbnail exists', inject (Notifier) ->
        chrome.notifications =
          onClicked:
            addListener: ->
          onButtonClicked:
            addListener: ->
          create: ->
          clear: ->
        spyOn(window, 'open')
        spyOn webkitNotifications, 'createNotification'
        spyOn(chrome.notifications.onButtonClicked, 'addListener').andCallFake((callback) -> callback(0, 1))
        spyOn(chrome.notifications, 'clear').andCallFake((id, callback) -> callback())
        spyOn(chrome.notifications, 'create').andCallFake (id, options, callback) ->
          expect(options.iconUrl).toEqual("images/icon_logo128.png")
          expect(options.title).toEqual("New article on #{GlobalConfig.name}")
          expect(options.message).toEqual("Article 1")
          expect(options.type).toEqual('image')
          expect(options.imageUrl).toEqual('http://example.com/test.jpg')
        Notifier.notify([{title: 'Article 1', author: 'Paddington Bear', link: 'http://www.omgubuntu.co.uk', thumbnail: 'http://example.com/test.jpg'}])
        expect(window.open).not.toHaveBeenCalled()
        expect(chrome.notifications.create).toHaveBeenCalled()
        expect(webkitNotifications.createNotification).not.toHaveBeenCalled()
    describe 'should show multi-article notification', ->
      it 'should not issue a notification if notifications are disabled', inject (Notifier) ->
        localStorage['notificationsEnabled'] = false
        Notifier.multiNotify [
          {title: 'Article 1', author: 'Paddington Bear', link: 'http://www.omgubuntu.co.uk'}
          {title: 'Article 2', author: 'Keith the Koala', link: 'http://www.omgchrome.com'}
        ]
        spyOn webkitNotifications, 'createNotification'
        expect(webkitNotifications.createNotification).not.toHaveBeenCalled()
        localStorage['notificationsEnabled'] = true
      it 'should accept an array of size > 1 and prompt for a multi-article notification', inject (Notifier) ->
        notificationsCreateCalled = 1
        chrome.notifications =
          create: ->
          onClicked:
            addListener: (callback) -> callback()
          onButtonClicked:
            addListener: (callback) ->
              if notificationsCreateCalled == 1
                callback(0, 0)
              else if notificationsCreateCalled == 2
                callback(0, 1)
          clear: (id, callback) -> callback()

        spyOn(chrome.notifications, 'create').andCallFake (id, options, callback)->
          callback()
          if notificationsCreateCalled == 1
            expect(options.message).toEqual('"Article 1" and 1 other')
          else if notificationsCreateCalled == 2
            expect(options.message).toEqual('"Article 1" and 2 others')
          notificationsCreateCalled++
        Notifier.notify [
          {title: 'Article 1', author: 'Paddington Bear', link: 'http://www.omgubuntu.co.uk'}
          {title: 'Article 2', author: 'Keith the Koala', link: 'http://www.omgchrome.com'}
        ]
        Notifier.notify [
          {title: 'Article 1', author: 'Paddington Bear', link: 'http://www.omgubuntu.co.uk'}
          {title: 'Article 2', author: 'Keith the Koala', link: 'http://www.omgchrome.com'}
          {title: 'Article 3', author: 'Keith the Koala', link: 'http://www.omgchrome.com'}
        ]
      it 'should create a webkit.notification if chrome.notification is undefined', inject (Notifier) ->
        spyOn(window, 'setTimeout').andCallFake (callback) -> callback()
        spyOn(webkitNotifications, 'createNotification').andCallFake ->
          {
            addEventListener: (type, callback) -> callback()
            show: ->
            cancel: ->
          }
        chrome.notifications = undefined
        Notifier.notify [
          {title: 'Article 1', author: 'Paddington Bear', link: 'http://www.omgubuntu.co.uk'}
          {title: 'Article 2', author: 'Keith the Koala', link: 'http://www.omgchrome.com'}
        ]

  describe 'eatClick directive', ->
    eatClickValues = {}
    beforeEach inject ($rootScope, $compile) ->
      eatClickValues.element = angular.element '<a href="boo" eat-click>Boourns!</a>'
      $compile(eatClickValues.element)($rootScope)
      $rootScope.$digest()

    it 'prevents a click from bubbling any default events', inject (eatClickDirective) ->
      ev = document.createEvent("MouseEvent")
      ev.initMouseEvent(
        "click",
        true, true,
        window, null,
        0, 0, 0, 0,
        false, false, false, false,
        0, null
      )
      expect(eatClickValues.element[0].onclick()).toBeFalsy()
      expect(eatClickValues.element[0].dispatchEvent(ev)).toBeFalsy()
