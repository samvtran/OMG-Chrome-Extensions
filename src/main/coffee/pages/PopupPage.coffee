###*
  @jsx React.DOM
###
'use strict'

ArticlesList = require '../components/Articles.coffee'
Notifier = require '../components/Notifier.coffee'
Article = require '../ui/Article.coffee'

module.exports = React.createClass
  getInitialState: ->
    refreshing: false
    articleList: ArticlesList.getArticles()
  handleRefresh: (e) ->
    e.preventDefault()
    if this.state.refreshing then return
    this.setState refreshing: true
    that = this
    ArticlesList.fetchLatestArticles ->
      that.setState
        articleList: ArticlesList.getArticles()
        refreshing: false
  handleOpenHomepage: (e) ->
    e.preventDefault()
    chrome.tabs.create url: GlobalConfig.homepage
  handleOpenOptions: (e) ->
    e.preventDefault()
    chrome.tabs.create url: "options.html"
  handleMarkAllAsRead: (e) ->
    e.preventDefault()
    ArticlesList.markAllAsRead()
    Notifier.dismissAll()
    this.refreshList()
  refreshList: ->
    this.setState
      articleList: ArticlesList.getArticles()
  render: ->
    refreshFn = this.refreshList

    list = (`<Article article={item} key={i} refreshList={refreshFn} />` for i, item of this.state.articleList)

    `<div>
      <header className="popup-header">
        <a href="#" ref="goToHome" onClick={this.handleOpenHomepage} className="logo" title={"Visit " + GlobalConfig.name}><img className="logo" src="images/logotype.png" height="48" width="48" /><span className="hide">{GlobalConfig.name}</span></a>
        <a href="#" ref="refresh" className="refresh" onClick={this.handleRefresh}><i className={this.state.refreshing ? 'omgicon-time' : 'omgicon-refresh'} ng-class="{true: 'omgicon-time', false: 'omgicon-refresh'}[refreshing==true]"></i><span className="hide">Refresh</span></a>
      </header>
      <section className="latest-news" ref="articleList">
        {list}
      </section>
      <footer className="popup-footer">
        <a ref="options" title={"Change " + GlobalConfig.name + " options"} href="#" onClick={this.handleOpenOptions}>Options</a>
        <a ref="markAllAsRead" className="right" href="#" onClick={this.handleMarkAllAsRead}>Mark All As Read</a>
      </footer>
    </div>`