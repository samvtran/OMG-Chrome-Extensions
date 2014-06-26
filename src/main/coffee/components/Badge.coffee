'use strict'

module.exports =
  notify: (unreadArticles) ->
    if unreadArticles.length == 0
      chrome.browserAction.setBadgeText text: ""
      chrome.browserAction.setIcon path: 'images/icon_inactive38.png'
    else
      chrome.browserAction.setBadgeText text: "#{unreadArticles.length}"
      chrome.browserAction.setIcon path: 'images/icon_active38.png'