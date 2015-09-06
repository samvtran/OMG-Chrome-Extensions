'use strict'

Dispatch = require '../../src/main/coffee/components/Dispatch.coffee'

describe 'Dispatch Service', ->
  it 'should create an event for type badge', ->
    sendMessage = spyOn chrome.runtime, 'sendMessage'
    Dispatch.notifyBadge [1]
    expect(sendMessage).toHaveBeenCalledWith type: 'badge', articles: [1]

  it 'should create an event for type notification', ->
    sendMessage = spyOn chrome.runtime, 'sendMessage'
    Dispatch.notifyNotification [1]
    expect(sendMessage).toHaveBeenCalledWith type: 'notification', articles: [1]