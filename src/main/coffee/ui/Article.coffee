###*
  @jsx React.DOM
###
'use strict'

Articles = require '../components/Articles.coffee'

module.exports = React.createClass
  propTypes:
    article: React.PropTypes.object.isRequired
    refreshList: React.PropTypes.func.isRequired
  handleOpenArticle: (e) ->
    e.preventDefault()
    e.stopPropagation()
    Articles.markAsRead this.props.article.link
    chrome.tabs.create url: this.props.article.link
  handleMarkAsRead: (e) ->
    e.preventDefault()
    if !this.props.article.unread then return
    Articles.markAsRead this.props.article.link
    this.props.refreshList()
  render: ->
    article = this.props.article
    thumbnail = if typeof article.thumbnail != 'undefined' then article.thumbnail else 'images/placeholder100.png'
    `<article onClick={this.handleMarkAsRead}>
        <div ref="unread" className={"unread-indicator" + (article.unread ? '' : ' hide')}><i title="Unread" className="omgicon-bookmark"> </i></div>
        <div className="thumbnail-wrapper"><a href="#" onClick={this.handleOpenArticle}><img src={thumbnail} alt={article.title} ref="thumbnail" /></a></div>
        <h3><a href="#" ref="title" onClick={this.handleOpenArticle}>{article.title}</a></h3>
      </article>`