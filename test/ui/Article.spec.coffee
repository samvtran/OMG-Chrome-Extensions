###*
  @jsx React.DOM
###
'use strict'

TestUtils = React.addons.TestUtils
Article = require '../../src/main/coffee/ui/Article.coffee'
_ = require 'lodash'

describe 'Article Component', ->
  testArticle =
    title: 'Test Article Title'
    thumbnail: 'http://example.com/test.jpg'
    date: new Date().getTime()
    author: "Keith Koala"
    link: "http://www.example.com/test"
    unread: true

  renderDoc = (article, refresh) ->
    refresh = if typeof refresh != 'undefined' then refresh else ->
    TestUtils.renderIntoDocument `<Article article={article} refreshList={refresh} />`

  it 'should show the title and thumbnail of an article', ->
    doc = renderDoc testArticle
    expect(doc.refs.title.props.children).toEqual testArticle.title
    expect(doc.refs.thumbnail.props.src).toEqual testArticle.thumbnail

  it 'should show the unread indicator if the article is unread', ->
    doc = renderDoc testArticle
    expect(doc.refs.unread.props.className).toEqual "unread-indicator"

  it 'should hide the unread indicator if the article is read', ->
    readArticle = _.assign {}, testArticle, unread: false
    doc = renderDoc readArticle
    expect(doc.refs.unread.props.className).toEqual "unread-indicator hide"

  it 'should show the default thumbnail if it doesn\'t exist', ->
    noThumbnailArticle = _.clone testArticle
    delete noThumbnailArticle.thumbnail
    doc = renderDoc noThumbnailArticle
    expect(doc.refs.thumbnail.props.src).toEqual 'images/placeholder100.png'

  it 'should mark the article as read if the thumbnail is clicked and open the article', ->
    refresh = jasmine.createSpy 'refresh'
    markedAsRead = jasmine.createSpy 'markedAsRead'
    Article.__set__ 'Articles.markAsRead', markedAsRead
    chromeTabCreate = spyOn(chrome.tabs, 'create')

    doc = renderDoc testArticle, refresh
    thumbnail = doc.refs.thumbnail
    TestUtils.Simulate.click thumbnail.getDOMNode()

    expect(markedAsRead.calls.count()).toEqual 1
    expect(chromeTabCreate).toHaveBeenCalled()
    expect(refresh).not.toHaveBeenCalled()
    expect(markedAsRead).toHaveBeenCalledWith testArticle.link

  it 'should mark the article as read if the title is clicked and open the article', ->
    refresh = jasmine.createSpy 'refresh'
    markedAsRead = jasmine.createSpy 'markedAsRead'
    Article.__set__ 'Articles.markAsRead', markedAsRead
    chromeTabCreate = spyOn(chrome.tabs, 'create')

    doc = renderDoc testArticle, refresh
    title = doc.refs.title
    TestUtils.Simulate.click title.getDOMNode()

    expect(markedAsRead.calls.count()).toEqual 1
    expect(chromeTabCreate).toHaveBeenCalled()
    expect(refresh).not.toHaveBeenCalled()
    expect(markedAsRead).toHaveBeenCalledWith testArticle.link

  it 'should mark the article as read if the background is clicked', ->
    refresh = jasmine.createSpy 'refresh'
    markedAsRead = jasmine.createSpy 'markedAsRead'
    Article.__set__ 'Articles.markAsRead', markedAsRead
    chromeTabCreate = spyOn(chrome.tabs, 'create')

    doc = renderDoc testArticle, refresh
    TestUtils.Simulate.click doc.getDOMNode()

    expect(markedAsRead.calls.count()).toEqual 1
    expect(chromeTabCreate).not.toHaveBeenCalled()
    expect(refresh).toHaveBeenCalled()
    expect(markedAsRead).toHaveBeenCalledWith testArticle.link