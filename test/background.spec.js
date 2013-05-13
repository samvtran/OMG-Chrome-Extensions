/**
 *  TODO: Put most of the beforeEach inside each test so we can test
 *  chrome.browserAction for unread === 0 and > 0
 *
 *  TODO: Spy on database and article services to make sure everything works
 */
'use strict'
var testFeed = "http://feeds.feedburner.com/d0od?format=xml"
describe('BackgroundCtrl', function() {
  var mainScope, backgroundCtrl, $httpBackend;

  beforeEach(module('omgBackground'));

  beforeEach(inject(function($rootScope, $controller, _$httpBackend_) {
    chrome.browserAction = {
      setBadgeText: function() {},
      setIcon: function() {}
    }

    spyOn(chrome.browserAction, 'setBadgeText');
    spyOn(chrome.browserAction, 'setIcon');

    mainScope = $rootScope.$new();

    $httpBackend = _$httpBackend_;
    $httpBackend.when('GET', testFeed).respond(['']);
    $httpBackend.expectGET(testFeed);
    backgroundCtrl = $controller('backgroundCtrl', {$scope: mainScope});

    $httpBackend.flush();
  }));

  it('initialises a database, gets latest articles, and gets articles on timeout', inject(function() {
    // TODO test badge
  }));
});