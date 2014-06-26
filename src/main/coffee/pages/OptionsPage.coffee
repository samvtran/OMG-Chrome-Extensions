###*
  @jsx React.DOM
###
'use strict'

Notifier = require '../components/Notifier.coffee'

module.exports = React.createClass
  getInitialState: ->
    notificationsEnabled: if localStorage['notificationsEnabled'] == "true" then true else false
  handleShowExampleNotification: ->
    Notifier.singleNotify
      title: 'An Example Article'
      author: 'Example Author'
      thumbnail: 'images/placeholder350.jpg'
      link: GlobalConfig.homepage
    setTimeout ->
      Notifier.dismissAll()
    , 5000
  handleNotificationsEnabled: (e) ->
    localStorage['notificationsEnabled'] = e.target.checked
    this.setState notificationsEnabled: e.target.checked
  render: ->
    `<div className="pane">
      <header>
        <a ref="link" target="_blank" href={GlobalConfig.homepage} className="logo" title={"Visit the " + GlobalConfig.name + " website"}>
          <img className="logo" src="images/icon_logo128.png" height="48" width="48" />
        </a>
        <h1 ref="globalHeader">{GlobalConfig.name} Extension Options</h1>
      </header>
      <h2>Options</h2>
        <p>
          <input ref="toggleNotifications" type="checkbox" checked={this.state.notificationsEnabled} id="notifications-enabled" onChange={this.handleNotificationsEnabled} />
          <label htmlFor="notifications-enabled">New Article Desktop Notifications</label>
          <a ref="testNotification" className="example" onClick={this.handleShowExampleNotification} href="#">Example</a>
        </p>
      <h2>About The Extension</h2>
      <div className="pane">
        <p>This extension is released under the Apache License 2.0 with source code available on <a href="https://github.com/samvtran/OMG-Chrome-Extensions" title="OMG! Extensions on GitHub">GitHub</a>.</p>
      </div>
      <h2 ref="aboutTitle">About {GlobalConfig.name}</h2>
      <div className="pane" dangerouslySetInnerHTML={{__html: GlobalConfig.intro}}></div>
    </div>`