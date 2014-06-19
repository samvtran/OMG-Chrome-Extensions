###*
  @jsx React.DOM
###
'use strict'

ArticlesList = require './components/Articles.coffee'
Notifier = require './components/Notifier.coffee'
Article = require './ui/Article.coffee'

PopupPage = React.createClass
  getInitialState: ->
    refreshing: false
    articleList: this.populateArticles()
  populateArticles: ->
    ArticlesList.getArticles().map (item, i) ->
      `<Article article={item} key={i} />`
  handleRefresh: (e) ->
    e.preventDefault()
    if this.state.refreshing then return
    this.setState
      articleList: this.state.articleList
      refreshing: true
    that = this
    ArticlesList.fetchLatestArticles ->
      that.setState
        articlesList: ArticlesList.getArticles()
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
    this.setState
      articleList: this.populateArticles()
      refreshing: this.state.refreshing
  render: ->
    `<div>
      <header className="popup-header">
        <a href="#" onClick={this.handleOpenHomepage} className="logo" title={"Visit " + GlobalConfig.name}><img className="logo" src="images/logotype.png" height="48" width="48" /><span className="hide">{GlobalConfig.name}</span></a>
        <a href="#" className="refresh" onClick={this.handleRefresh}><i className={this.state.refreshing ? 'omgicon-time' : 'omgicon-refresh'} ng-class="{true: 'omgicon-time', false: 'omgicon-refresh'}[refreshing==true]"></i><span className="hide">Refresh</span></a>
      </header>
      <section className="latest-news">
        {this.state.articleList}
      </section>
      <footer className="popup-footer">
        <a title={"Change " + GlobalConfig.name + " options"} href="#" onClick={this.handleOpenOptions}>Options</a>
        <a className="right" href="#" onClick={this.handleMarkAllAsRead}>Mark All As Read</a>
      </footer>
    </div>`

React.renderComponent `<PopupPage />`, document.getElementById 'popup'