###*
  @jsx React.DOM
###
'use strict'

TestUtils = React.addons.TestUtils
OptionsPage = require '../../src/main/coffee/pages/OptionsPage.coffee'

describe 'Options Page', ->
  renderDoc = ->
    TestUtils.renderIntoDocument `<OptionsPage />`

  beforeEach ->
    localStorage['notificationsEnabled'] = true

  it 'should check the notifications checkbox when enabled', ->
    expect(renderDoc().refs.toggleNotifications.props.checked).toBe true

  it 'should uncheck the notifications checkbox when disabled', ->
    localStorage['notificationsEnabled'] = false
    expect(renderDoc().refs.toggleNotifications.props.checked).toBe false

  it 'should toggle the notificationsEnabled checkbox when clicked', ->
    doc = renderDoc()
    checkbox = doc.refs.toggleNotifications
    expect(checkbox.props.checked).toBe true
    TestUtils.Simulate.change checkbox.getDOMNode(),
      target:
        name: checkbox.props.name
        checked: false

    expect(checkbox.props.checked).toBe false
    expect(localStorage['notificationsEnabled']).toBe 'false'

    TestUtils.Simulate.change checkbox.getDOMNode(),
      target:
        name: checkbox.props.name
        checked: true

    expect(checkbox.props.checked).toBe true
    expect(localStorage['notificationsEnabled']).toBe 'true'

  it 'should show an example notification when prompted', ->
    doc = renderDoc()
    testNotify = doc.refs.testNotification
    Notifier = singleNotify: ->
    OptionsPage.__set__ "Notifier", Notifier
    spyOn(Notifier, 'singleNotify').and.callFake (settings) ->

    TestUtils.Simulate.click testNotify.getDOMNode()

    expect(Notifier.singleNotify).toHaveBeenCalled()

  it 'should show the site name in the headers', ->
    doc = renderDoc()
    expect(doc.refs.globalHeader.props.children[0]).toBe GlobalConfig.name
    expect(doc.refs.aboutTitle.props.children[1]).toBe GlobalConfig.name
