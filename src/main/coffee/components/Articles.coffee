'use strict'

Dispatch = require './Dispatch.coffee'
Http = require './Http.coffee'

getArticles = ->
  articles = JSON.parse if typeof localStorage['articles'] == 'undefined' then "[]" else localStorage['articles']
  if typeof articles == 'undefined' then return []
  articles.sort (a, b) -> # Sort by date descending
    b.date - a.date

putArticles = (articlesJson) ->
  localStorage['articles'] = JSON.stringify articlesJson.slice(0, 30)

getUnreadArticles = ->
  articles = getArticles()
  articles.filter (article) ->
    if article.unread then true else false

markAsRead = (articleLink) ->
  articles = getArticles()
  for article in articles
    if article.link == articleLink
      article.unread = false
  putArticles articles
  Dispatch.notifyBadge getUnreadArticles()

markAllAsRead = ->
  articles = getArticles()
  article.unread = false for article in articles
  putArticles articles
  Dispatch.notifyBadge this.getUnreadArticles()

fetchLatestArticles = (cb) ->
  Http.get GlobalConfig.url, ->
    dom = new DOMParser().parseFromString this.responseText, 'application/xml'
    if dom.getElementsByTagName('parsererror').length > 0 then return cb []
    channel = dom.getElementsByTagName('channel')
    if channel.length == 0 then return cb []
    items = channel[0].getElementsByTagName('item')
    if items.length == 0 then return cb []
    articles = for item in items
      thumbnail = item.querySelector('thumbnail')
      article =
        title: item.querySelector('title').textContent
        author: item.querySelector('creator').textContent
        link: item.querySelector('link').textContent
        date: Date.parse item.querySelector('pubDate').textContent
        unread: true
      if thumbnail != null then article.thumbnail = thumbnail.getAttribute('url')
      article
    putLatestArticlesAndNotify articles
    cb articles
  , ->
    console.log 'ERRORORORO'
    cb []

putLatestArticlesAndNotify = (articles) ->
  newArticles = []
  if typeof localStorage['unread'] != 'undefined' # Catch upgrading users and don't notify
    for article in articles
      article.unread = false
    localStorage.removeItem 'unread'
  existingArticles = getArticles()
  yesterday = new Date()
  yesterday.setDate(yesterday.getDate() - 1)
  yesterday = yesterday.getTime()
  if existingArticles.length > 0
    latestNewArticleSlice = -1
    for start in [0..articles.length - 1] by 1
      if existingArticles[0].link == articles[start].link # Our latest saved article is at index i in the feed's updated list
        latestNewArticleSlice = start
        for j in [start..articles.length - 1] by 1
          if articles[j].date > yesterday # Article is less than a day old, so update title and thumbnail if it exists
            existingArticles[j - start].title = articles[j].title
            if typeof articles[j].thumbnail != 'undefined'
              existingArticles[j - start].thumbnail = articles[j].thumbnail
          else # Exit as soon as we hit an article more than a day old
            break
        break
    # TODO fix this condition: what happens when all articles are too old?
    if latestNewArticleSlice < 0 # Clear the notification badge and don't do anything
#        console.log 'Clearing the badge'
#        Messenger.notify.badge []
#        return
      newArticles = articles
    else
      newArticles = articles.slice(0, latestNewArticleSlice)
  else
    newArticles = articles

  uniqueArticles = checkExistingArticles(existingArticles, newArticles)
  putArticles uniqueArticles.concat existingArticles
  unreadArticles = getUnreadArticles()
  Dispatch.notifyBadge unreadArticles
  Dispatch.notifyNotification uniqueArticles

checkExistingArticles = (existing, newArticles) ->
  uniqueArticles = []
  paths = existing.map (article) -> article.link
  for i in [0..newArticles.length - 1] by 1
    if paths.indexOf(newArticles[i].link) == -1
      uniqueArticles.push(newArticles[i])
  uniqueArticles

fetchLatestOnTimeout = ->
  setTimeout ->
    fetchLatestArticles ->
      fetchLatestOnTimeout()
  , localStorage['pollInterval']

module.exports =
  getArticles: getArticles
  putArticles: putArticles
  getUnreadArticles: getUnreadArticles
  markAllAsRead: markAllAsRead
  markAsRead: markAsRead
  fetchLatestArticles: fetchLatestArticles
  fetchLatestOnTimeout: fetchLatestOnTimeout
  putLatestArticlesAndNotify: putLatestArticlesAndNotify
  checkExistingArticles: checkExistingArticles