###*
  @jsx React.DOM
###
'use strict'

PopupPage = require './pages/PopupPage.coffee'

React.renderComponent `<PopupPage />`, document.getElementById 'popup'