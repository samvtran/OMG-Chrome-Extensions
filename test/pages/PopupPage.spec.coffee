###*
  @jsx React.DOM
###
'use strict'

ArticlesList = require '../../src/main/coffee/components/Articles.coffee'
Notifier = require '../../src/main/coffee/components/Notifier.coffee'
Article = require '../../src/main/coffee/ui/Article.coffee'

PopupPage = require '../../src/main/coffee/pages/PopupPage.coffee'
TestUtils = React.addons.TestUtils
_ = require 'lodash'

describe 'Popup Page', ->
  renderDoc = ->
    div = document.createElement 'div'
    React.renderComponent `<PopupPage />`, div
  #TestUtils.renderIntoDocument `<PopupPage />`

  beforeEach ->
    localStorage['articles'] = JSON.stringify testJson
#    TestUtils.mockComponent Article

  it 'should fetch the list articles', ->
    doc = renderDoc()
    list = doc.state.articleList
    expect(list.length).toEqual 18
    for i in [0..list.length - 1] by 1
      articleObj = list[i]
#      expect(TestUtils.isComponentOfType articleObj, Article).toEqual true
      expect(articleObj.title).toEqual testJson[i].title

  it 'should mark all articles as read', ->
    markAllAsReadFn = spyOn(ArticlesList, 'markAllAsRead')
    getArticles = spyOn(ArticlesList, 'getArticles').and.callThrough()
    doc = renderDoc()
    markAllAsRead = doc.refs.markAllAsRead
    TestUtils.Simulate.click markAllAsRead.getDOMNode()
    expect(markAllAsReadFn).toHaveBeenCalled()
    articles = ArticlesList.getArticles()
    expect(article.unread).toEqual false for article in articles

  it 'should refresh the article list, showing the refresh icon until finish', ->
    fetchLatest = spyOn(ArticlesList, 'fetchLatestArticles').and.callFake (cb) -> cb()
    doc = renderDoc()
    refresh = doc.refs.refresh
    getArticles = spyOn(PopupPage.__get__('ArticlesList'), 'getArticles').and.callFake ->
      articles = _.cloneDeep testJson
      articles.unshift {title: "article", link: "http://example.com", unread: true, date: 1375996124000}
      articles
    expect(doc.state.refreshing).toEqual false
    TestUtils.Simulate.click refresh.getDOMNode()
    expect(fetchLatest).toHaveBeenCalled()
    expect(doc.state.articleList.length).toEqual 19
    expect(doc.state.articleList[0].title).toEqual 'article'

  it 'should open the options page', ->
    createTab = spyOn(chrome.tabs, 'create').and.callFake ->
    doc = renderDoc()
    options = doc.refs.options
    TestUtils.Simulate.click options
    expect(createTab).toHaveBeenCalledWith url: 'options.html'

  it 'should open the homepage when the logo is clicked', ->
    createTab = spyOn(chrome.tabs, 'create').and.callFake ->
    doc = renderDoc()
    goToHome = doc.refs.goToHome
    TestUtils.Simulate.click goToHome
    expect(createTab).toHaveBeenCalledWith url: GlobalConfig.homepage