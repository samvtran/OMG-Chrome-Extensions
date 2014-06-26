'use strict'

module.exports =
  get: (url, success, error) ->
    request = new XMLHttpRequest()
    request.onload = success
    request.onerror = error
    request.open 'get', url, true
    request.send()