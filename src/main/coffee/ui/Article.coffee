###*
  @jsx React.DOM
###
'use strict'

Articles = require '../components/Articles.coffee'

module.exports = React.createClass
  propTypes:
    article: React.PropTypes.object.isRequired
  handleOpenArticle: (e) ->
    e.preventDefault()
    Articles.markAsRead this.props.article.link
    chrome.tabs.create url: this.props.article.link
  render: ->
    article = this.props.article
    thumbnail = if typeof article.thumbnail != 'undefined' then article.thumbnail else 'images/placeholder100.png'
    `<article>
        <div className={"unread-indicator" + (article.unread ? '' : ' hide')}><i title="Unread" className="omgicon-bookmark"> </i></div>
        <div className="thumbnail-wrapper"><a href="#" onClick={this.handleOpenArticle}><img src={thumbnail} alt={article.title} /></a></div>
        <h3><a href="#" onClick={this.handleOpenArticle}>{article.title}</a></h3>
      </article>`