###*
  @jsx React.DOM
###
'use strict'

OptionsPage = require './pages/OptionsPage.coffee'
React.renderComponent `<OptionsPage />`, document.getElementById 'options'