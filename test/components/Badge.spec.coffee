'use strict'

Badge = require '../../src/main/coffee/components/Badge.coffee'

describe 'Badge Service', ->
  it 'should accept an empty array and set the badge text to an empty string', ->
    setBadgeText = spyOn chrome.browserAction, 'setBadgeText'
    setIcon = spyOn chrome.browserAction, 'setIcon'
    Badge.notify []
    expect(setBadgeText).toHaveBeenCalledWith text: ""
    expect(setIcon).toHaveBeenCalledWith path: 'images/icon_inactive38.png'

  it 'should accept an arbitrarily sized array and use the length as the badge text', ->
    setBadgeText = spyOn chrome.browserAction, 'setBadgeText'
    setIcon = spyOn chrome.browserAction, 'setIcon'
    Badge.notify [1, 2, 3, 4]
    expect(setBadgeText).toHaveBeenCalledWith text: "4"
    expect(setIcon).toHaveBeenCalledWith path: 'images/icon_active38.png'