###*
  @jsx React.DOM
###
'use strict'

TestUtils = React.addons.TestUtils
Articles = require '../../src/main/coffee/components/Articles.coffee'
Badger = require '../../src/main/coffee/components/Badge.coffee'
Notifier = require '../../src/main/coffee/components/Notifier.coffee'
bg = require '../../src/main/coffee/pages/BackgroundPage.coffee'

describe 'Background Page', ->
  beforeEach ->
    chrome.notifications =
      onClicked: addListener: ->
      onShowSettings: addListener: ->
      onButtonClicked: addListener: ->
      clear: ->

  it 'should set up poll interval and default notificationEnabled', ->
    localStorage.removeItem 'pollInterval'
    localStorage.removeItem 'notificationsEnabled'
    bg.go()
    expect(localStorage['pollInterval']).toBeTruthy()
    expect(localStorage['notificationsEnabled']).toEqual 'true'

  it 'should fetch the latest articles and started the backoff', ->
    fetch = spyOn(Articles, 'fetchLatestArticles').and.callFake (cb) -> cb()
    timeout = spyOn(window, 'setTimeout')
    bg.go()
    expect(fetch).toHaveBeenCalled()
    expect(timeout.calls.count()).toEqual 1

  it 'should open a single article when a single notification is clicked', ->
    localStorage['notification'] = JSON.stringify type: 'single', link: testJson[0].link
    addListener = spyOn(chrome.notifications.onClicked, 'addListener').and.callFake (cb) -> cb()
    windowOpen = spyOn(window, 'open').and.callFake ->
    markAsUnread = spyOn(Articles, 'markAsRead').and.callFake ->
    clearNotify = spyOn(chrome.notifications, 'clear').and.callFake ->
    bg.go()
    expect(addListener).toHaveBeenCalled()
    expect(windowOpen).toHaveBeenCalledWith testJson[0].link
    expect(markAsUnread).toHaveBeenCalledWith testJson[0].link
    expect(clearNotify).toHaveBeenCalled()

  it 'should not open anything if an example notification button was clicked', ->
    localStorage['notification'] = JSON.stringify type: 'single', link: GlobalConfig.homepage
    addListener = spyOn(chrome.notifications.onButtonClicked, 'addListener').and.callFake (cb) -> cb(0, 0)
    windowOpen = spyOn(window, 'open')
    markAsUnread = spyOn(Articles, 'markAsRead')
    clearNotify = spyOn(chrome.notifications, 'clear').and.callFake ->
    bg.go()
    expect(windowOpen).not.toHaveBeenCalled()
    expect(markAsUnread).not.toHaveBeenCalled()
    expect(clearNotify).toHaveBeenCalled()

  it 'should open a single article when the single notification button is clicked', ->
    exampleLink = 'http://example.com/koala'
    localStorage['notification'] = JSON.stringify type: 'single', link: exampleLink
    addListener = spyOn(chrome.notifications.onButtonClicked, 'addListener').and.callFake (cb) -> cb(0, 0)
    windowOpen = spyOn(window, 'open').and.callFake ->
    markAsUnread = spyOn(Articles, 'markAsRead').and.callFake ->
    clearNotify = spyOn(chrome.notifications, 'clear').and.callFake ->
    bg.go()
    expect(windowOpen).toHaveBeenCalledWith exampleLink
    expect(markAsUnread).toHaveBeenCalledWith exampleLink
    expect(clearNotify).toHaveBeenCalled()

  it 'should mark a single article as read when the single notification button is clicked', ->
    exampleLink = 'http://example.com/koala'
    localStorage['notification'] = JSON.stringify type: 'single', link: exampleLink
    addListener = spyOn(chrome.notifications.onButtonClicked, 'addListener').and.callFake (cb) -> cb(0, 1)
    windowOpen = spyOn(window, 'open').and.callFake ->
    markAsUnread = spyOn(Articles, 'markAsRead').and.callFake ->
    clearNotify = spyOn(chrome.notifications, 'clear').and.callFake ->
    bg.go()
    expect(windowOpen).not.toHaveBeenCalled()
    expect(markAsUnread).toHaveBeenCalledWith exampleLink
    expect(clearNotify).toHaveBeenCalled()

  it 'should open the homepage when a multi notification is clicked', ->
    localStorage['notification'] = JSON.stringify type: 'multi'
    addListener = spyOn(chrome.notifications.onClicked, 'addListener').and.callFake (cb) -> cb()
    windowOpen = spyOn(window, 'open').and.callFake ->
    markAsUnread = spyOn(Articles, 'markAllAsRead').and.callFake ->
    clearNotify = spyOn(chrome.notifications, 'clear').and.callFake ->
    bg.go()
    expect(addListener).toHaveBeenCalled()
    expect(windowOpen).toHaveBeenCalledWith GlobalConfig.homepage
    expect(markAsUnread).toHaveBeenCalled()
    expect(clearNotify).toHaveBeenCalled()

  it 'should open the homepage when the multi notification button is clicked', ->
    localStorage['notification'] = JSON.stringify type: 'multi'
    addListener = spyOn(chrome.notifications.onButtonClicked, 'addListener').and.callFake (cb) -> cb(0, 0)
    windowOpen = spyOn(window, 'open').and.callFake ->
    markAsUnread = spyOn(Articles, 'markAllAsRead').and.callFake ->
    clearNotify = spyOn(chrome.notifications, 'clear').and.callFake ->
    bg.go()
    expect(addListener).toHaveBeenCalled()
    expect(windowOpen).toHaveBeenCalledWith GlobalConfig.homepage
    expect(markAsUnread).toHaveBeenCalled()
    expect(clearNotify).toHaveBeenCalled()

  it 'should mark all as read when the multi notification button is clicked', ->
    localStorage['notification'] = JSON.stringify type: 'multi'
    addListener = spyOn(chrome.notifications.onButtonClicked, 'addListener').and.callFake (cb) -> cb(0, 1)
    windowOpen = spyOn(window, 'open').and.callFake ->
    markAsUnread = spyOn(Articles, 'markAllAsRead').and.callFake ->
    clearNotify = spyOn(chrome.notifications, 'clear').and.callFake ->
    bg.go()
    expect(addListener).toHaveBeenCalled()
    expect(windowOpen).not.toHaveBeenCalled()
    expect(markAsUnread).toHaveBeenCalled()
    expect(clearNotify).toHaveBeenCalled()

  it 'should delegate to the Badge service when receiving a badge message', ->
    addListener = spyOn(chrome.runtime.onMessage, 'addListener').and.callFake (cb) -> cb type: 'badge', articles: testJson
    badger = spyOn(Badger, 'notify').and.callFake ->
    notifier = spyOn(Notifier, 'notify').and.callFake ->
    bg.go()
    expect(addListener).toHaveBeenCalled()
    expect(notifier).not.toHaveBeenCalled()
    expect(badger).toHaveBeenCalledWith testJson

  it 'should delegate to the Notification service when receiving a notification message', ->
    addListener = spyOn(chrome.runtime.onMessage, 'addListener').and.callFake (cb) -> cb type: 'notification', articles: testJson
    badger = spyOn(Badger, 'notify').and.callFake ->
    notifier = spyOn(Notifier, 'notify').and.callFake ->
    bg.go()
    expect(addListener).toHaveBeenCalled()
    expect(badger).not.toHaveBeenCalled()
    expect(notifier).toHaveBeenCalledWith testJson