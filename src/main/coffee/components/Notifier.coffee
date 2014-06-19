'use strict'

module.exports =
  richNotificationId: "#{GlobalConfig.tag}ExtensionNotification"
  dismissAll: ->
    if this.hasRichNotifications() then chrome.notifications.clear this.richNotificationId, ->
  hasRichNotifications: ->
    typeof chrome.notifications != 'undefined'
  notify: (unreadArticles) ->
    if localStorage['notificationsEnabled'] == "false" then return
    if unreadArticles.length is 0 then return
    if unreadArticles.length is 1
      this.singleNotify(unreadArticles[0])
    else
      this.multiNotify(unreadArticles)
  singleNotify: (article) ->
    if this.hasRichNotifications()
      options =
        type: 'basic'
        title: "New article on #{GlobalConfig.name}"
        message: article.title
        iconUrl: 'images/icon_logo128.png'
        expandedMessage: "#{article.title} by #{article.author}"
        buttons: [
          {
            title: 'Read'
            iconUrl: 'images/read.png'
          }
          {
            title: 'Mark As Read'
            iconUrl: 'images/mark_as_read.png'
          }
        ]
      if typeof article.thumbnail != 'undefined'
        options.type = 'image'
        options.imageUrl = article.thumbnail
      localStorage['notification'] = JSON.stringify {type: 'single', link: article.link}
      chrome.notifications.create this.richNotificationId, options, ->
    else if typeof webkitNotifications != 'undefined'
      notification = webkitNotifications.createNotification('images/icon_logo48.png',
        "New article on #{GlobalConfig.name}", article.title)
      notification.addEventListener 'click', ->
        notification.cancel()
        Articles.markAsRead article.link
        window.open article.link
      notification.show()
      setTimeout ->
        notification.cancel()
      , 5000
  multiNotify: (articles) ->
    articleList = articles.map (article) ->
      {
      title: article.title
      message: ''
      }
    if localStorage['notificationsEnabled'] is "false" then return
    messageText = "\"#{articles[0].title}\" and #{articles.length - 1} "
    messageText += if articles.length - 1 == 1 then "other" else "others"
    if this.hasRichNotifications()
      options =
        type: 'list'
        title: "#{articles.length} new articles on #{GlobalConfig.name}"
        message: messageText
        iconUrl: 'images/icon_logo128.png'
        items: articleList
        buttons: [
          {
            title: 'Read'
            iconUrl: 'images/read.png'
          }
          {
            title: 'Mark All As Read'
            iconUrl: 'images/mark_as_read.png'
          }
        ]
      localStorage['notification'] = JSON.stringify {type: 'multi', link: GlobalConfig.homepage}
      chrome.notifications.create this.richNotificationId, options, ->
    else if typeof webkitNotifications != 'undefined'
      notification = webkitNotifications.createNotification('images/icon_logo48.png',
        "#{articles.length} new articles on #{GlobalConfig.name}", messageText)
      notification.addEventListener 'click', ->
        notification.cancel()
        Articles.markAllAsRead()
        window.open GlobalConfig.homepage
      notification.show()
      setTimeout ->
        notification.cancel()
      , 5000