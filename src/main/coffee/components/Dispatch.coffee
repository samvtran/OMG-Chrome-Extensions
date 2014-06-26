'use strict'

module.exports =
  notifyBadge: (articles) ->
    chrome.runtime.sendMessage type: 'badge', articles: articles
  notifyNotification: (articles) ->
    chrome.runtime.sendMessage type: 'notification', articles: articles