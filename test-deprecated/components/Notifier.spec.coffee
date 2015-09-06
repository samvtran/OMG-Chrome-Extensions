'use strict'

Notifier = require '../../src/main/coffee/components/Notifier.coffee'
_ = require 'lodash'

describe 'Notifier Service', ->
  beforeEach ->
    chrome.notifications = create: ->
    localStorage['notificationsEnabled'] = true

  it 'should not issue a notification if notifications are disabled', ->
    single = spyOn Notifier, 'singleNotify'
    multi = spyOn Notifier, 'multiNotify'
    localStorage['notificationsEnabled'] = false
    Notifier.notify testJson
    expect(single).not.toHaveBeenCalled()
    expect(multi).not.toHaveBeenCalled()

  it 'should accept an empty array and not issue a notification', ->
    single = spyOn Notifier, 'singleNotify'
    multi = spyOn Notifier, 'multiNotify'
    Notifier.notify []
    expect(single).not.toHaveBeenCalled()
    expect(multi).not.toHaveBeenCalled()

  it 'should return whether rich notifications are available', ->
    expect(Notifier.hasRichNotifications()).toEqual true
    delete chrome.notifications
    expect(Notifier.hasRichNotifications()).toEqual false

  it 'should issue a dismissal if rich notifications exist', ->
    clearNotify = jasmine.createSpy 'clearNotify'
    chrome.notifications = clear: clearNotify
    Notifier.dismissAll()
    expect(clearNotify).toHaveBeenCalledWith Notifier.richNotificationId, jasmine.any Function

  it 'should issue a single-article notification if an array is size 1', ->
    single = spyOn Notifier, 'singleNotify'
    multi = spyOn Notifier, 'multiNotify'
    Notifier.notify [1]
    expect(single).toHaveBeenCalledWith 1
    expect(multi).not.toHaveBeenCalled()

  it 'should issue a multi-article notification if an array is size greater than 1', ->
    single = spyOn Notifier, 'singleNotify'
    multi = spyOn Notifier, 'multiNotify'
    Notifier.notify [1, 2, 3]
    expect(single).not.toHaveBeenCalled()
    expect(multi).toHaveBeenCalledWith [1, 2, 3]

  describe 'Single-Article Notifications', ->
    it 'should not issue a notification if notifications are disabled', ->
      localStorage['notificationsEnabled'] = false
      shouldNotBeCalled = spyOn Notifier, 'hasRichNotifications'
      Notifier.singleNotify testJson[0]
      expect(shouldNotBeCalled).not.toHaveBeenCalled()

    it 'should issue a webkit notification if rich notifications aren\'t available', ->
      delete chrome.notifications
      webkitNotify = spyOn(webkitNotifications, 'createNotification').and.callFake ->
        addEventListener: ->
        show: ->
        cancel: ->
      Notifier.singleNotify testJson[0]
      expect(webkitNotify).toHaveBeenCalledWith 'images/icon_logo48.png', jasmine.any(String), testJson[0].title

    it 'should accept an array of size one and prompt for a single-article notification', ->
      richNotify = spyOn chrome.notifications, 'create'
      Notifier.singleNotify testJson[0]
      expect(richNotify).toHaveBeenCalledWith Notifier.richNotificationId,
        jasmine.objectContaining(type: 'image', message: testJson[0].title), jasmine.any Function
      expect(JSON.parse localStorage['notification']).toEqual type: 'single', link: testJson[0].link

    it 'should issue a basic notification if the thumbnail is missing', ->
      richNotify = spyOn chrome.notifications, 'create'
      articleWithoutThumbnail = _.clone testJson[0]
      delete articleWithoutThumbnail.thumbnail
      Notifier.singleNotify articleWithoutThumbnail
      expect(richNotify).toHaveBeenCalledWith Notifier.richNotificationId,
        jasmine.objectContaining(type: 'basic', message: testJson[0].title), jasmine.any Function

  describe 'Multi-Article Notifications', ->
    it 'should not issue a notification if notifications are disabled', ->
      localStorage['notificationsEnabled'] = false
      shouldNotBeCalled = spyOn Notifier, 'hasRichNotifications'
      Notifier.multiNotify testJson
      expect(shouldNotBeCalled).not.toHaveBeenCalled()

    it 'should accept an array of size > 1 and prompt for a multi-article notification', ->
      richNotify = spyOn chrome.notifications, 'create'
      Notifier.multiNotify testJson
      expect(richNotify).toHaveBeenCalledWith Notifier.richNotificationId,
        jasmine.objectContaining(type: 'list', title: "#{testJson.length} new articles on #{GlobalConfig.name}"),
        jasmine.any Function
      expect(JSON.parse localStorage['notification']).toEqual type: 'multi'

    it 'should create a webkit.notification if chrome.notification is undefined', ->
      delete chrome.notifications
      webkitNotify = spyOn(webkitNotifications, 'createNotification').and.callFake ->
        addEventListener: ->
        show: ->
        cancel: ->
      Notifier.multiNotify testJson
      expect(webkitNotify).toHaveBeenCalledWith 'images/icon_logo48.png',
        "#{testJson.length} new articles on #{GlobalConfig.name}", jasmine.any(String)