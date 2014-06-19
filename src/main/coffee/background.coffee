'use strict'

Notifier = require './components/Notifier.coffee'
Articles = require './components/Articles.coffee'
Badger = require './components/Badge.coffee'

do setup = ->
  if typeof localStorage['pollInterval'] is 'undefined'
    localStorage['pollInterval'] = 900000

  if typeof localStorage['notificationsEnabled'] is 'undefined'
    localStorage['notificationsEnabled'] = true

if Notifier.hasRichNotifications()
  chrome.notifications.onShowSettings.addListener ->
    chrome.windows.create url: '/options.html', focused: true

Articles.fetchLatestArticles ->
  Articles.fetchLatestOnTimeout()

chrome.notifications.onClicked.addListener ->
  notification = JSON.parse localStorage['notification']
  if notification.type == 'single'
    window.open notification.link
    Articles.markAsRead notification.link
  else
    window.open notification.link
    Articles.markAllAsRead()
  chrome.notifications.clear Notifier.richNotificationId, ->

chrome.notifications.onButtonClicked.addListener (id, idx) ->
  notification = JSON.parse localStorage['notification']
  if notification.link == GlobalConfig.homepage
    # this is an example, so don't do anything
  else if notification.type == 'single'
    if idx == 0
      window.open notification.link
      Articles.markAsRead notification.link
    else
      Articles.markAsRead notification.link
  else
    if idx == 0
      window.open GlobalConfig.homepage
      Articles.markAllAsRead()
    else
      Articles.markAllAsRead()
  chrome.notifications.clear Notifier.richNotificationId, ->

chrome.runtime.onMessage.addListener (request) ->
  if request.type == 'badge'
    Badger.notify request.articles
  else if request.type == 'notification'
    Notifier.notify request.articles