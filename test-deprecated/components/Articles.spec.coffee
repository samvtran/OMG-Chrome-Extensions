'use strict'

TestUtils = React.addons.TestUtils
Articles = require '../../src/main/coffee/components/Articles.coffee'
_ = require 'lodash'
describe 'Articles Service', ->
  randomOrder = -> testJson.slice(0).sort -> 0.5 - Math.random()
  onFinish = ->
  Dispatch = {}

  beforeEach ->
    Dispatch =
      notifyBadge: ->
      notifyNotification: ->
    Articles.__set__('Dispatch', Dispatch)
    localStorage['pollInterval'] = '100'
    localStorage.removeItem 'unread'
    localStorage.removeItem 'articles'
    jasmine.Ajax.install()
    onFinish = jasmine.createSpy 'onFinish'
  afterEach ->
    jasmine.Ajax.uninstall()

  it 'should retrieve a list of articles from the server and parse the articles properly', ->
    Articles.__set__ 'putLatestArticlesAndNotify', ->

    Articles.fetchLatestArticles (articles) ->
      expect(articles.length).toEqual 18
      onFinish()

    expect(jasmine.Ajax.requests.mostRecent().url).toEqual GlobalConfig.url

    jasmine.Ajax.requests.mostRecent().response
      status: 200
      contentType: 'application/xml'
      responseText: testXML

    expect(onFinish).toHaveBeenCalled()

  it 'should resolve with an empty array if no articles are found', ->
    Articles.fetchLatestArticles (articles) ->
      expect(articles.length).toEqual 0
      onFinish()

    expect(jasmine.Ajax.requests.mostRecent().url).toBe GlobalConfig.url

    jasmine.Ajax.requests.mostRecent().response
      status: 200
      contentType: 'application/xml'
      responseText: ''

    expect(onFinish).toHaveBeenCalled()

  it 'should be resilient to HTTP errors and resolve anyway', ->
    Articles.fetchLatestArticles (articles) ->
      expect(articles.length).toEqual 0
      onFinish()

    expect(jasmine.Ajax.requests.mostRecent().url).toBe GlobalConfig.url

    jasmine.Ajax.requests.mostRecent().response
      status: 404

    expect(onFinish).toHaveBeenCalled()

  it 'should fetch the latest articles and restart on a timer', ->
    spyOn(window, 'setTimeout').and.callFake (fn) ->
      fn()

    Articles.__set__ 'putLatestArticlesAndNotify', ->
    Articles.fetchLatestOnTimeout()
    jasmine.Ajax.requests.mostRecent().response
      status: 200
      contentType: 'application/xml'
      responseText: testXML
    expect(window.setTimeout.calls.count()).toEqual 2

  it 'should be resilient to HTTP errors and continue fetching on a timer', ->
    spyOn(window, 'setTimeout').and.callFake (fn) ->
      fn()

    Articles.__set__ 'putLatestArticlesAndNotify', ->
    Articles.fetchLatestOnTimeout()
    jasmine.Ajax.requests.mostRecent().response
      status: 404
    expect(window.setTimeout.calls.count()).toEqual 2

  it 'should get articles and return an empty array if no articles are defined', ->
    expect(Articles.getArticles()).toEqual []

  it 'should sort by date descending when getting a list of articles', ->
    localStorage['articles'] = JSON.stringify randomOrder()
    articles = Articles.getArticles()
    expect(articles).toEqual testJson
    expect(articles.length).toEqual 18

  it 'should return a list of unread articles sorted by date descending', ->
    localStorage['articles'] = JSON.stringify randomOrder()
    unread = Articles.getUnreadArticles()
    expect(unread.length).toEqual 2
    expect(unread[0]).toEqual testJson[0]
    expect(unread[1]).toEqual testJson[testJson.length - 1]

  it 'should mark an article as read when given the link', ->
    localStorage['articles'] = JSON.stringify randomOrder()
    spyOn(Dispatch, 'notifyBadge')
    Articles.markAsRead testJson[0].link
    unread = Articles.getUnreadArticles()
    expect(unread.length).toEqual 1
    expect(unread[0].link).toEqual testJson[testJson.length - 1].link
    expect(Dispatch.notifyBadge.calls.count()).toEqual 1
    expect(Dispatch.notifyBadge).toHaveBeenCalledWith [testJson[testJson.length - 1]]

  it 'should mark all articles as read', ->
    localStorage['articles'] = JSON.stringify randomOrder()
    spyOn(Dispatch, 'notifyBadge')
    Articles.markAllAsRead()
    unread = Articles.getUnreadArticles()
    expect(unread.length).toEqual 0
    expect(Dispatch.notifyBadge).toHaveBeenCalledWith []

  it 'should put articles into LocalStorage', ->
    Articles.putArticles testJson
    expect(Articles.getArticles()).toEqual testJson

  it 'should put the latest articles into LocalStorage and notify', ->
    spyOn(Dispatch, 'notifyBadge')
    spyOn(Dispatch, 'notifyNotification')
    Articles.putLatestArticlesAndNotify testJson

    expect(Articles.getArticles()).toEqual testJson
    expect(Dispatch.notifyBadge.calls.count()).toEqual 1
    expect(Dispatch.notifyNotification.calls.count()).toEqual 1
    expect(Dispatch.notifyBadge).toHaveBeenCalledWith [testJson[0], testJson[testJson.length - 1]]
    expect(Dispatch.notifyNotification).toHaveBeenCalledWith testJson

  it 'should update articles less than 24 hours old', ->
    testTitle = 'foobar'
    now = new Date().getTime()

    existing = _.cloneDeep testJson
    toReplace = _.cloneDeep testJson
    existing[0].title = testTitle
    existing[0].date = now
    toReplace[0].date = now
    Articles.putArticles(existing)

    expect(Articles.getArticles()[0].title).toEqual testTitle
    Articles.putLatestArticlesAndNotify toReplace
    expect(Articles.getArticles()[0].title).toEqual testJson[0].title

  it 'should replace an article\'s thumbnail if less than 24 hours old', ->
    now = new Date().getTime()

    existing = _.cloneDeep testJson
    toReplace = _.cloneDeep testJson
    delete existing[0].thumbnail
    existing[0].date = now
    toReplace[0].date = now
    Articles.putArticles(existing)

    expect(Articles.getArticles()[0].thumbnail).toBeFalsy()
    Articles.putLatestArticlesAndNotify toReplace
    expect(Articles.getArticles()[0].thumbnail).toEqual testJson[0].thumbnail

  it 'should bypass notifications and remove the unread LocalStorage item if a user is upgrading the extension', ->
    localStorage['unread'] = 0
    expect(testJson[0].unread).toEqual true
    expect(testJson[testJson.length - 1].unread).toEqual true
    Articles.putLatestArticlesAndNotify(testJson)
    expect(localStorage['unread']).toBeFalsy()
    existing = Articles.getArticles()
    expect(existing[0].unread).toEqual false
    expect(existing[existing.length - 1].unread).toEqual false

  it 'should append articles if the latest article is too old and can\'t be found', ->
    date = testJson[testJson.length - 1].date - 1
    Articles.putArticles [{title: 'Article 2', author: 'Keith the Koala', link: 'http://example.com', date: date }]
    expect(Articles.getArticles().length).toEqual 1
    Articles.putLatestArticlesAndNotify testJson
    existing = Articles.getArticles()
    expect(existing.length).toEqual testJson.length + 1
    expect(existing[existing.length - 1].title).toEqual 'Article 2'
    expect(existing[0].title).toEqual testJson[0].title

  it 'should not add articles if they exist in the database already', ->
    returned = Articles.checkExistingArticles testDeletedArticleJson, testJson
    expect(returned.length).toEqual 1
    expect(returned[0].title).toEqual testJson[0].title

  it 'should not add articles if an article was unpublished/deleted', ->
    returned = Articles.checkExistingArticles testJson, testDeletedArticleJson
    expect(returned.length).toEqual 0

###it 'should recover from a network error', ->
  onFinish = jasmine.createSpy 'onFinish'
  Articles.__set__ 'putLatestArticlesAndNotify', ->
    console.log 'fetching...'

  Articles.fetchLatestArticles onFinish

  expect(jasmine.Ajax.requests.mostRecent().url).toBe GlobalConfig.url

  jasmine.Ajax.requests.mostRecent().response {}

  expect(onFinish).toHaveBeenCalled()###