describe 'Articles service', ->
  beforeEach ->
    module 'omgUtil'
    mockMessenger =
      notify:
        badge: ->
        notification: ->
    angular.mock.module ($provide) ->
      $provide.value 'Messenger', mockMessenger
      null

  # first and last are unread
  articles = [{"title":"Quick access to Google voice search in Chrome","author":"Tom Slominski","link":"http://www.omgchrome.com/quick-access-to-google-voice-search-in-chrome/","date":1376227712000,"unread":true,"thumbnail":"http://www.omgchrome.com/wp-content/uploads/2013/08/thumb-350x200.png"},{"title":"Amazon Underestimates Chromecast Demand, Forecasts 2-3 Month Delay For Orders","author":"Joey-Elijah Sneddon","link":"http://www.omgchrome.com/chromecast-orders-delayed-by-2-3-months-on-amazon/","date":1375996122000,"unread":false,"thumbnail":"http://www.omgchrome.com/wp-content/uploads/2013/07/chrome-350x200.jpg"},{"title":"Acer Looks to ‘Grow Non-Windows Business’ with Chromebooks, Android Tablets","author":"Joey-Elijah Sneddon","link":"http://www.omgchrome.com/acer-to-dial-back-windows-ramp-up-chromebook-android-devices/","date":1375977615000,"unread":false,"thumbnail":"http://www.omgchrome.com/wp-content/uploads/2013/03/acer1-350x200.jpg"},{"title":"First Update for Chromecast now Available, Beta & Dev Channels","author":"Ed Hewitt","link":"http://www.omgchrome.com/first-update-for-chromecast-now-available-beta-dev-channels/","date":1375373349000,"unread":false},{"title":"Multiple Fixes land in Chrome and Chrome OS 28 Today","author":"Ed Hewitt","link":"http://www.omgchrome.com/multiple-fixes-land-in-chrome-and-chrome-os-28-today/","date":1375206150000,"unread":false,"thumbnail":"http://www.omgchrome.com/wp-content/uploads/2013/03/chrome-udate-350x200.jpg"},{"title":"Chromecast Hacked To Run Gameboy Emulator","author":"Joey-Elijah Sneddon","link":"http://www.omgchrome.com/chromecast-hack-gameboy-emulator/","date":1375121472000,"unread":false,"thumbnail":"http://www.omgchrome.com/wp-content/uploads/2013/07/chrome-350x200.jpg"},{"title":"Photosphere Extension for Google Chrome","author":"Joey-Elijah Sneddon","link":"http://www.omgchrome.com/android-photosphere-viewer-for-google-chrome/","date":1375096871000,"unread":false,"thumbnail":"http://www.omgchrome.com/wp-content/uploads/2013/07/photo-350x200.jpg"},{"title":"Hands On With The Google Chromecast","author":"Sam Tran","link":"http://www.omgchrome.com/hands-on-with-the-chromecast/","date":1375004653000,"unread":false,"thumbnail":"http://www.omgchrome.com/wp-content/uploads/2013/07/chromcas-350x200.jpg"},{"title":"Chrome OS Adding Expose-Style Window Picker Feature","author":"Joey-Elijah Sneddon","link":"http://www.omgchrome.com/chrome-os-to-get-expose-like-feature/","date":1374782900000,"unread":false,"thumbnail":"http://www.omgchrome.com/wp-content/uploads/2013/07/thumb_placeholder-350x200.jpg"},{"title":"Google Releases Chromecast Android App","author":"Ed Hewitt","link":"http://www.omgchrome.com/google-releases-chromecast-android-app/","date":1374762973000,"unread":false,"thumbnail":"http://www.omgchrome.com/wp-content/uploads/2013/07/chrome-350x200.jpg"},{"title":"What Are Packaged Apps?","author":"Sam Tran","link":"http://www.omgchrome.com/what-are-packaged-app/","date":1374751146000,"unread":false,"thumbnail":"http://www.omgchrome.com/wp-content/uploads/2013/07/what-are-packaged-apps-350x200.png"},{"title":"Official Chromecast Browser Extension Hits Chrome Web Store","author":"Joey-Elijah Sneddon","link":"http://www.omgchrome.com/official-chromecast-extension-hits-chrome-web-store/","date":1374700655000,"unread":false,"thumbnail":"http://www.omgchrome.com/wp-content/uploads/2013/07/chrome-350x200.jpg"},{"title":"Google Launches $35 ‘Chromecast’ – HDMI Dongle For Streaming Content from Chrome to TV","author":"Joey-Elijah Sneddon","link":"http://www.omgchrome.com/google-announce-chromecast-chromekey/","date":1374684815000,"unread":false,"thumbnail":"http://www.omgchrome.com/wp-content/uploads/2013/07/chrome-350x200.jpg"},{"title":"Wunderlist Launches as Packaged App on Chrome Web Store","author":"Joey-Elijah Sneddon","link":"http://www.omgchrome.com/wunderlist-launches-as-packaged-app/","date":1374163988000,"unread":false,"thumbnail":"http://www.omgchrome.com/wp-content/uploads/2013/07/wunderlist-packaged-350x200.jpg"},{"title":"Google Chrome for iOS Sees Big Improvements in Latest Update","author":"Joey-Elijah Sneddon","link":"http://www.omgchrome.com/google-chrome-iphone-update/","date":1374088268000,"unread":false,"thumbnail":"http://www.omgchrome.com/wp-content/uploads/2013/06/ios-350x200.jpg"},{"title":"Pocket App Comes to Chrome, Lets You Read Articles Offline","author":"Joey-Elijah Sneddon","link":"http://www.omgchrome.com/pocket-goes-packaged-app-runs-offline/","date":1374061099000,"unread":false,"thumbnail":"http://www.omgchrome.com/wp-content/uploads/2013/07/picketap-350x200.jpg"},{"title":"Chromebook Sales to Rise 300% This Year, ASUS To Join the Fun","author":"Joey-Elijah Sneddon","link":"http://www.omgchrome.com/new-chromebooks-lenovo-hp-sales-surge/","date":1374059126000,"unread":false,"thumbnail":"http://www.omgchrome.com/wp-content/uploads/2013/04/cr-350x200.jpg"},{"title":"3 Minor Chrome OS UI Changes on the Way","author":"Joey-Elijah Sneddon","link":"http://www.omgchrome.com/chrome-os-ui-changes-on-the-way/","date":1373912512000,"unread":true,"thumbnail":"http://www.omgchrome.com/wp-content/uploads/2013/07/chromeos-status-bar-350x200.jpg"}]
  deletedArticles = [{"title":"Amazon Underestimates Chromecast Demand, Forecasts 2-3 Month Delay For Orders","author":"Joey-Elijah Sneddon","link":"http://www.omgchrome.com/chromecast-orders-delayed-by-2-3-months-on-amazon/","date":1375996122000,"unread":false,"thumbnail":"http://www.omgchrome.com/wp-content/uploads/2013/07/chrome-350x200.jpg"},{"title":"Acer Looks to ‘Grow Non-Windows Business’ with Chromebooks, Android Tablets","author":"Joey-Elijah Sneddon","link":"http://www.omgchrome.com/acer-to-dial-back-windows-ramp-up-chromebook-android-devices/","date":1375977615000,"unread":false,"thumbnail":"http://www.omgchrome.com/wp-content/uploads/2013/03/acer1-350x200.jpg"},{"title":"First Update for Chromecast now Available, Beta & Dev Channels","author":"Ed Hewitt","link":"http://www.omgchrome.com/first-update-for-chromecast-now-available-beta-dev-channels/","date":1375373349000,"unread":false},{"title":"Multiple Fixes land in Chrome and Chrome OS 28 Today","author":"Ed Hewitt","link":"http://www.omgchrome.com/multiple-fixes-land-in-chrome-and-chrome-os-28-today/","date":1375206150000,"unread":false,"thumbnail":"http://www.omgchrome.com/wp-content/uploads/2013/03/chrome-udate-350x200.jpg"},{"title":"Chromecast Hacked To Run Gameboy Emulator","author":"Joey-Elijah Sneddon","link":"http://www.omgchrome.com/chromecast-hack-gameboy-emulator/","date":1375121472000,"unread":false,"thumbnail":"http://www.omgchrome.com/wp-content/uploads/2013/07/chrome-350x200.jpg"},{"title":"Photosphere Extension for Google Chrome","author":"Joey-Elijah Sneddon","link":"http://www.omgchrome.com/android-photosphere-viewer-for-google-chrome/","date":1375096871000,"unread":false,"thumbnail":"http://www.omgchrome.com/wp-content/uploads/2013/07/photo-350x200.jpg"},{"title":"Hands On With The Google Chromecast","author":"Sam Tran","link":"http://www.omgchrome.com/hands-on-with-the-chromecast/","date":1375004653000,"unread":false,"thumbnail":"http://www.omgchrome.com/wp-content/uploads/2013/07/chromcas-350x200.jpg"},{"title":"Chrome OS Adding Expose-Style Window Picker Feature","author":"Joey-Elijah Sneddon","link":"http://www.omgchrome.com/chrome-os-to-get-expose-like-feature/","date":1374782900000,"unread":false,"thumbnail":"http://www.omgchrome.com/wp-content/uploads/2013/07/thumb_placeholder-350x200.jpg"},{"title":"Google Releases Chromecast Android App","author":"Ed Hewitt","link":"http://www.omgchrome.com/google-releases-chromecast-android-app/","date":1374762973000,"unread":false,"thumbnail":"http://www.omgchrome.com/wp-content/uploads/2013/07/chrome-350x200.jpg"},{"title":"What Are Packaged Apps?","author":"Sam Tran","link":"http://www.omgchrome.com/what-are-packaged-app/","date":1374751146000,"unread":false,"thumbnail":"http://www.omgchrome.com/wp-content/uploads/2013/07/what-are-packaged-apps-350x200.png"},{"title":"Official Chromecast Browser Extension Hits Chrome Web Store","author":"Joey-Elijah Sneddon","link":"http://www.omgchrome.com/official-chromecast-extension-hits-chrome-web-store/","date":1374700655000,"unread":false,"thumbnail":"http://www.omgchrome.com/wp-content/uploads/2013/07/chrome-350x200.jpg"},{"title":"Google Launches $35 ‘Chromecast’ – HDMI Dongle For Streaming Content from Chrome to TV","author":"Joey-Elijah Sneddon","link":"http://www.omgchrome.com/google-announce-chromecast-chromekey/","date":1374684815000,"unread":false,"thumbnail":"http://www.omgchrome.com/wp-content/uploads/2013/07/chrome-350x200.jpg"},{"title":"Wunderlist Launches as Packaged App on Chrome Web Store","author":"Joey-Elijah Sneddon","link":"http://www.omgchrome.com/wunderlist-launches-as-packaged-app/","date":1374163988000,"unread":false,"thumbnail":"http://www.omgchrome.com/wp-content/uploads/2013/07/wunderlist-packaged-350x200.jpg"},{"title":"Google Chrome for iOS Sees Big Improvements in Latest Update","author":"Joey-Elijah Sneddon","link":"http://www.omgchrome.com/google-chrome-iphone-update/","date":1374088268000,"unread":false,"thumbnail":"http://www.omgchrome.com/wp-content/uploads/2013/06/ios-350x200.jpg"},{"title":"Pocket App Comes to Chrome, Lets You Read Articles Offline","author":"Joey-Elijah Sneddon","link":"http://www.omgchrome.com/pocket-goes-packaged-app-runs-offline/","date":1374061099000,"unread":false,"thumbnail":"http://www.omgchrome.com/wp-content/uploads/2013/07/picketap-350x200.jpg"},{"title":"Chromebook Sales to Rise 300% This Year, ASUS To Join the Fun","author":"Joey-Elijah Sneddon","link":"http://www.omgchrome.com/new-chromebooks-lenovo-hp-sales-surge/","date":1374059126000,"unread":false,"thumbnail":"http://www.omgchrome.com/wp-content/uploads/2013/04/cr-350x200.jpg"},{"title":"3 Minor Chrome OS UI Changes on the Way","author":"Joey-Elijah Sneddon","link":"http://www.omgchrome.com/chrome-os-ui-changes-on-the-way/","date":1373912512000,"unread":true,"thumbnail":"http://www.omgchrome.com/wp-content/uploads/2013/07/chromeos-status-bar-350x200.jpg"}]
  randomOrder = articles.slice(0).sort -> 0.5 - Math.random()

  it 'should retrieve a list of articles from the server and return a list of articles', inject (Articles, $httpBackend) ->
    $httpBackend.when('GET', GlobalConfig.url).respond([testData])
    articlesActionComplete = false

    Articles.fetchLatestArticles().then (retrievedArticles) ->
      expect(retrievedArticles[0]).toEqual(articles[0])
      articlesActionComplete = true

    $httpBackend.flush()

    waitsFor ->
      return articlesActionComplete
    , "Couldn't retrieve the latest list of articles", 2500

  it 'should resolve with an empty array if no articles are found', inject (Articles, $httpBackend) ->
    $httpBackend.when('GET', GlobalConfig.url).respond([])
    articlesActionComplete = false

    Articles.fetchLatestArticles().then (retrievedArticles) ->
      expect(retrievedArticles).toEqual([])
      articlesActionComplete = true

    $httpBackend.flush()

    waitsFor ->
      return articlesActionComplete
    , "Couldn't retrieve the latest list of articles and resolve to []", 2500

  it 'should be resilient to parsing errors and resolve anyway', inject (Articles, $httpBackend) ->
    $httpBackend.when('GET', GlobalConfig.url).respond(404, [])
    articlesActionComplete = false

    Articles.fetchLatestArticles().then (retrievedArticles) ->
      expect(retrievedArticles).toEqual([])
      articlesActionComplete = true

    $httpBackend.flush()

    waitsFor ->
      return articlesActionComplete
    , "Couldn't error out retrieving the latest list of articles and resolving properly", 2500

  it 'should fetch the latest articles and restart on a timer', inject (Articles, $httpBackend) ->
    $httpBackend.when('GET', GlobalConfig.url).respond(testData)
    localStorage['pollInterval'] = '100'

    spyOn(window, 'setTimeout').andCallThrough()
    spyOn(Articles, 'fetchLatestArticlesOnTimeout').andCallThrough()
    Articles.fetchLatestArticlesOnTimeout()
    waits(150)
    runs ->
      $httpBackend.flush()
      $httpBackend.verifyNoOutstandingRequest()
      expect(window.setTimeout.callCount).toEqual(2)

    localStorage['pollInterval'] = '900000'

  it 'should be resilient to network errors and continue fetching on a timer', inject (Articles, $httpBackend) ->
    $httpBackend.when('GET', GlobalConfig.url).respond(404, [])
    localStorage['pollInterval'] = '100'

    spyOn(window, 'setTimeout').andCallThrough()
    spyOn(Articles, 'fetchLatestArticlesOnTimeout').andCallThrough()
    Articles.fetchLatestArticlesOnTimeout()
    waits(150)
    runs ->
      $httpBackend.flush()
      $httpBackend.verifyNoOutstandingRequest()
      expect(window.setTimeout.callCount).toEqual(2)

    localStorage['pollInterval'] = '900000'

  it 'should get articles and return an empty array if no articles are defined', inject (Articles) ->
    localStorage.removeItem 'articles'
    expect(Articles.getArticles()).toEqual([])
  it 'should sort by date descending when getting a list of articles', inject (Articles) ->
    localStorage['articles'] = angular.toJson randomOrder
    expect(Articles.getArticles()).toEqual(articles)
  it 'should return a list of unread articles sorted by date descending', inject (Articles) ->
    unreadArticles = Articles.getUnreadArticles()
    expect(unreadArticles.length).toEqual(2)
    expect(unreadArticles[0]).toEqual(articles[0])
    expect(unreadArticles[1]).toEqual(articles.slice(-1)[0])
  it 'should mark an article as read when given the link', inject (Articles) ->
    expect(Articles.getArticles()[0].unread).toBeTruthy()
    Articles.markAsRead(articles[0].link)
    expect(Articles.getArticles()[0].unread).toBeFalsy()
  it 'should mark an article as read when given an index', inject (Articles) ->
    expect(Articles.getArticles()[articles.length - 1].unread).toBeTruthy()
    Articles.markAsReadAtIndex(articles.length - 1)
    expect(Articles.getArticles()[articles.length - 1].unread).toBeFalsy()
  it 'should mark all articles as read', inject (Articles) ->
    articles[3].unread = true
    articles[8].unread = true
    localStorage['articles'] = angular.toJson articles
    Articles.markAllAsRead()
    articlesMarkedAsRead = angular.fromJson localStorage['articles']
    expect(articlesMarkedAsRead[3].unread).toBeFalsy()

  it 'should put articles into LocalStorage', inject (Articles) ->
    localStorage.removeItem 'articles'
    expect(localStorage['articles']).toBeFalsy()
    Articles.putArticles(articles)
    expect(Articles.getArticles()).toEqual(articles)

  it 'should put the latest articles into LocalStorage and notify', inject (Articles) ->
    localStorage.removeItem 'articles'
    Articles.putLatestArticlesAndNotify(articles)
    expect(Articles.getArticles()).toEqual(articles)

  it 'should update articles less than 24 hours old', inject (Articles) ->
    existingArticles = Articles.getArticles()
    expect(existingArticles[0].title).toEqual(articles[0].title)
    existingArticles[0].title = 'foobar'
    now = new Date().getTime()
    existingArticles[0].date = now
    articles[0].date = now
    Articles.putArticles(existingArticles)
    expect(Articles.getArticles()[0].title).toEqual('foobar')
    Articles.putLatestArticlesAndNotify(articles)
    expect(Articles.getArticles()[0].title).toEqual(articles[0].title)

  it 'should bypass notifications and remove the unread LocalStorage item if a user is upgrading the extension', inject (Articles) ->
    localStorage.removeItem 'articles'
    localStorage['unread'] = 0
    articles[0].unread = true
    articles[4].unread = true
    articles[8].unread = true
    Articles.putLatestArticlesAndNotify(articles)
    expect(localStorage['unread']).toBeFalsy()
    expect(Articles.getArticles()[4].unread).toBeFalsy()

  it 'should append articles if the latest article is too old and can\'t be found', inject (Articles) ->
    Articles.putArticles([{title: 'Article 2', author: 'Keith the Koala', link: 'http://www.ohso.io'}])
    expect(Articles.getArticles().length).toEqual(1)
    Articles.putLatestArticlesAndNotify(articles)
    expect(Articles.getArticles().length).toEqual(articles.length + 1)

  it 'should replace an article\'s title with a new version and thumbnail if one exists', inject (Articles) ->
    articles[0].date = new Date().getTime()
    articles[0].title = 'foobar'
    articles[1].date = articles[0].date - 100000
    delete articles[0].thumbnail
    Articles.putArticles(articles)
    expect(Articles.getArticles()[0].thumbnail).toBeFalsy()
    expect(Articles.getArticles()[0].title).toEqual('foobar')
    articles[0].thumbnail = 'http://example.com/example.jpg'
    articles[0].title = 'baz'
    delete articles[1].thumbnail
    Articles.putLatestArticlesAndNotify(articles)
    expect(Articles.getArticles()[1].thumbnail).toBeTruthy()
    expect(Articles.getArticles()[0].thumbnail).toEqual('http://example.com/example.jpg')
    expect(Articles.getArticles()[0].title).toEqual('baz')

  it 'should not add articles if they exist in the database already', inject (Articles) ->
    returnedArticles = Articles.checkExistingArticles(deletedArticles, articles)
    expect(returnedArticles.length).toEqual(1)

  it 'should not add articles if an article was unpublished/deleted', inject (Articles) ->
    returnedArticles = Articles.checkExistingArticles(articles, deletedArticles)
    expect(returnedArticles.length).toEqual(0)