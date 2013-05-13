'use strict'

describe('first run', function() {
  it('sets unread to 0', function() {
    localStorage.removeItem('unread');
    expect(localStorage['unread']).toBeUndefined();
    setup();
    expect(localStorage['unread']).toBe('0');
  });

  it('sets the pollInterval to 600000ms', function() {
    localStorage.removeItem('pollInterval');
    expect(localStorage['pollInterval']).toBeUndefined();
    setup();
    expect(~~localStorage['pollInterval']).toBe(600000);
  });

  it('sets notificationsEnabled to true', function() {
    localStorage.removeItem('notificationsEnabled');
    expect(localStorage['notificationsEnabled']).toBeUndefined;
    setup();
    expect(localStorage['notificationsEnabled']).toBeTruthy();
  });
});

describe('omgUtil module', function() {
  beforeEach(function() {
    module('omgUtil');
    chrome.browserAction = {
      setBadgeText: function() {},
      setIcon: function() {}
    }

    spyOn(chrome.browserAction, 'setBadgeText');
    spyOn(chrome.browserAction, 'setIcon');
  });

  describe('the databaseService service', function() {
    it('deletes a database if one exists', inject(function(databaseService) {
      var deleteActionCompleted = false;
      var deleteAction = databaseService.clear();
      deleteAction.then(function(status) {
          console.log(status);
          deleteActionCompleted = true;
        });
      waitsFor(function() {
        return deleteActionCompleted;
      }, "databaseService couldn't clear the database", 5000);
    }));

    it('creates a database on the first run', inject(function(databaseService) {
      var completed = false;
      var openAction = databaseService.open().then(function(status) {
          console.log("Returned from dbservice: " + status);
          completed = true;
          expect(status.code).toEqual(databaseService.status.OPENED);
        });;

      waitsFor(function() {
        return completed;
      }, 'databaseService never opened an IndexedDB database', 5000);

      runs(function() {
        databaseService.getDb().then(function(db) {
          expect(db).toBeTruthy();
        });
      });
    }));

    it("doesn't reopen a database if one exists", inject(function(databaseService) {
      var firstOpenComplete = false;
      var firstOpen = databaseService.open().then(function(status) {
        firstOpenComplete = true;
      });

      waitsFor(function() {
        return firstOpenComplete;
      }, "Couldn't open the database the first time", 2500);

      runs(function() {
        var reopenAction = databaseService.open();
        var reOpenComplete = false;
        reopenAction.then(function(status) {
          reOpenComplete = true;
          expect(status.code).toEqual(databaseService.status.ALREADY_OPEN);
        });

        waitsFor(function() {
          return reOpenComplete;
        }, "Couldn't retrieve the opened database", 2500);
      });

    }));

    it('updates the database if out of date', function() {
      // TODO, but we haven't had to do this yet.
    });

    // it('queries the database after things are inserted', inject(function(databaseService) {
    //   var promise = databaseService.getDb();
    //   var promiseFulfilled = false;

    //   promise.then(function(db) {
    //     expect(db).toBeTruthy();
    //   });

    //   waitsFor(function() {
    //     return promise.then();
    //   }, "Couldn't open the database", 2500);

    // }));
  });

  /*
   * The following tests for the Articles service are split into three segments
   * as the response for the same endpoint differ amongst the three.
   *
   */

  // TODO check localstorage changes on addArticle
  // TODO adda a more regular RSS feed with broader test cases for catching parsing issues
  describe('Articles service', function() {
    var $httpBackend;
    beforeEach(inject(function($injector) {
      webkitNotifications = {
        createNotification: function() {
          console.log("This is where a notification sould go");
          expect(localStorage['notificationsEnabled']).toEqual('true');
        }
      };
      var mockwebkitNotification = {
        addEventListener: function() {},
        show: function() {},
        cancel: function() { notificationCancelled++; }
      };

      spyOn(webkitNotifications, 'createNotification').andReturn(mockwebkitNotification);

      $httpBackend = $injector.get('$httpBackend');
      $httpBackend.when('GET', 'http://www.omgchrome.com/feed').respond(['<?xml version="1.0" encoding="UTF-8"?><rss version="2.0"  xmlns:content="http://purl.org/rss/1.0/modules/content/"  xmlns:wfw="http://wellformedweb.org/CommentAPI/"  xmlns:dc="http://purl.org/dc/elements/1.1/"  xmlns:atom="http://www.w3.org/2005/Atom"  xmlns:sy="http://purl.org/rss/1.0/modules/syndication/"  xmlns:slash="http://purl.org/rss/1.0/modules/slash/"  >  <channel>    <title>OMG! Test!</title>    <description><![CDATA[<img src="http://localhost/false-expectations">Everything Testing. Daily.]]></description>    <language>en-US</language>    <item>      <title>Article 1</title>      <link>http://omgchrome.com/karma-testing</link>      <pubDate>Sat, 11 May 2013 11:42:19 +0000</pubDate>      <dc:creator>Joey-Elijah Sneddon</dc:creator>      <description><![CDATA[<img src="http://localhost/false-expectations">Lorem ipsum dolor sit amet, consectetur adipisicing elit. Consequatur, praesentium, possimus voluptate molestias vero obcaecati illo excepturi fuga minima iste?      ]]></description>    </item>    <item>      <title>Article 2</title>      <link>http://omgchrome.com/karma-testing</link>      <pubDate>Fri, 10 May 2013 15:17:19 +0000</pubDate>      <dc:creator>Joey-Elijah Sneddon</dc:creator>      <description><![CDATA[<img src="http://localhost/false-expectations">Officiis, minima culpa illo doloribus iure magni magnam omnis est autem accusantium. Repellat, quidem blanditiis quam similique nam temporibus beatae.      ]]></description>    </item>    <item>      <title>Article 3</title>      <link>http://omgchrome.com/karma-testing</link>      <pubDate>Fri, 10 May 2013 13:00:37 +0000</pubDate>      <dc:creator>Joey-Elijah Sneddon</dc:creator>      <description><![CDATA[<img src="http://localhost/false-expectations">Ipsam, facere, quis aperiam distinctio saepe rerum voluptatem architecto amet voluptates eaque reprehenderit consequuntur aut maiores iusto illo. Ipsum, earum.      ]]></description>    </item>    <item>      <title>Article 4</title>      <link>http://omgchrome.com/karma-testing</link>      <pubDate>Wed, 08 May 2013 18:09:52 +0000</pubDate>      <dc:creator>Joey-Elijah Sneddon</dc:creator>      <description><![CDATA[<img src="http://localhost/false-expectations">Nisi, ipsam, necessitatibus officia quod sunt assumenda aperiam debitis odio ipsum praesentium atque voluptates sit unde nihil nobis. Ex, necessitatibus?      ]]></description>    </item>    <item>      <title>Article 5</title>      <link>http://omgchrome.com/karma-testing</link>      <pubDate>Thu, 02 May 2013 18:06:53 +0000</pubDate>      <dc:creator>Joey-Elijah Sneddon</dc:creator>      <description><![CDATA[<img src="http://localhost/false-expectations">Excepturi, quod, itaque, reiciendis, nostrum libero hic placeat blanditiis cumque consectetur consequatur voluptatem ducimus quidem accusantium dolores temporibus mollitia natus.      ]]></description>    </item>    <item>      <title>Article 6</title>      <link>http://omgchrome.com/karma-testing</link>      <pubDate>Wed, 01 May 2013 17:30:31 +0000</pubDate>      <dc:creator>Joey-Elijah Sneddon</dc:creator>      <description><![CDATA[<img src="http://localhost/false-expectations">Nemo, atque temporibus labore nisi accusantium harum quidem nulla vero quia consequuntur illo excepturi laborum aliquid dolore officiis laudantium dignissimos.      ]]></description>    </item>    <item>      <title>Article 7</title>      <link>http://omgchrome.com/karma-testing</link>      <pubDate>Mon, 29 Apr 2013 15:26:11 +0000</pubDate>      <dc:creator>Joey-Elijah Sneddon</dc:creator>      <description><![CDATA[<img src="http://localhost/false-expectations">Id, natus ipsam accusantium deserunt atque fugiat ab dolorum corrupti maiores nihil quia laudantium accusamus soluta hic modi! Porro, reiciendis.      ]]></description>    </item>    <item>      <title>Article 8</title>      <link>http://omgchrome.com/karma-testing</link>      <pubDate>Mon, 29 Apr 2013 10:14:07 +0000</pubDate>      <dc:creator>Joey-Elijah Sneddon</dc:creator>      <description><![CDATA[<img src="http://localhost/false-expectations">Provident, necessitatibus, iure, laborum cum in sit eveniet sed sapiente est amet optio libero nam possimus quis voluptatum itaque dolorum.      ]]></description>    </item>    <item>      <title>Article 9</title>      <link>http://omgchrome.com/karma-testing</link>      <pubDate>Wed, 24 Apr 2013 11:00:29 +0000</pubDate>      <dc:creator>Joey-Elijah Sneddon</dc:creator>      <description><![CDATA[<img src="http://localhost/false-expectations">Autem facere provident ex maiores quis voluptatibus cum? Iure, ex ipsa voluptatibus obcaecati explicabo consequatur quis illo repellendus architecto porro!      ]]></description>    </item>    <item>      <title>Article 10</title>      <link>http://omgchrome.com/karma-testing</link>      <pubDate>Fri, 19 Apr 2013 09:24:10 +0000</pubDate>      <dc:creator>Joey-Elijah Sneddon</dc:creator>      <description><![CDATA[<img src="http://localhost/false-expectations">Dolore aut in nisi laudantium quod quaerat voluptatem. Quam, laborum, facere veritatis voluptate sequi optio aliquam iste quia pariatur fugit.      ]]></description>    </item>    <item>      <title>Article 11</title>      <link>http://omgchrome.com/karma-testing</link>      <pubDate>Mon, 15 Apr 2013 19:09:15 +0000</pubDate>      <dc:creator>Joey-Elijah Sneddon</dc:creator>      <description><![CDATA[<img src="http://localhost/false-expectations">Laboriosam non laudantium nostrum et enim porro sequi maiores quisquam nulla eius. Consequatur, doloremque, reiciendis enim rem fugit temporibus numquam?      ]]></description>    </item>    <item>      <title>Article 12</title>      <link>http://omgchrome.com/karma-testing</link>      <pubDate>Mon, 15 Apr 2013 16:00:49 +0000</pubDate>      <dc:creator>Joey-Elijah Sneddon</dc:creator>      <description><![CDATA[<img src="http://localhost/false-expectations">Perspiciatis, omnis, numquam, nisi, molestias id necessitatibus vel voluptatum at placeat error quae quo porro sunt modi culpa voluptas ratione.      ]]></description>    </item>    <item>      <title>Article 13</title>      <link>http://omgchrome.com/karma-testing</link>      <pubDate>Mon, 15 Apr 2013 13:11:27 +0000</pubDate>      <dc:creator>Joey-Elijah Sneddon</dc:creator>      <description><![CDATA[<img src="http://localhost/false-expectations">Quae, quidem, eos iusto possimus officiis voluptates excepturi harum dolorem eveniet nesciunt non pariatur reiciendis asperiores odit cum quos id.      ]]></description>    </item>    <item>      <title>Article 14</title>      <link>http://omgchrome.com/karma-testing</link>      <pubDate>Fri, 12 Apr 2013 15:44:36 +0000</pubDate>      <dc:creator>Joey-Elijah Sneddon</dc:creator>      <description><![CDATA[<img src="http://localhost/false-expectations">Velit nisi error nobis earum necessitatibus ad repudiandae fuga impedit. Possimus, ullam nisi totam harum officia ipsam dignissimos dicta quibusdam.      ]]></description>    </item>    <item>      <title>Article 15</title>      <link>http://omgchrome.com/karma-testing</link>      <pubDate>Thu, 11 Apr 2013 17:07:09 +0000</pubDate>      <dc:creator>Joey-Elijah Sneddon</dc:creator>      <description><![CDATA[<img src="http://localhost/false-expectations">Nulla, quibusdam esse totam laborum pariatur eum et rem in doloremque veritatis eos voluptatum dolore iure eligendi deleniti tenetur labore?      ]]></description>    </item>    <item>      <title>Article 16</title>      <link>http://omgchrome.com/karma-testing</link>      <pubDate>Thu, 11 Apr 2013 12:17:08 +0000</pubDate>      <dc:creator>Joey-Elijah Sneddon</dc:creator>      <description><![CDATA[<img src="http://localhost/false-expectations">Iure, aliquid, minus, officiis rem inventore eius delectus optio non sapiente dolorem distinctio similique eos cupiditate aspernatur tempora quaerat nulla.      ]]></description>    </item>    <item>      <title>Article 17</title>      <link>http://omgchrome.com/karma-testing</link>      <pubDate>Tue, 10 Apr 2013 20:29:48 +0000</pubDate>      <dc:creator>Joey-Elijah Sneddon</dc:creator>      <description><![CDATA[<img src="http://localhost/false-expectations">Eveniet, cumque est quas deserunt perspiciatis ducimus omnis perferendis libero aspernatur magnam commodi autem reiciendis vero ipsam molestiae nesciunt dicta.      ]]></description>    </item>    <item>      <title>Article 18</title>      <link>http://omgchrome.com/karma-testing</link>      <pubDate>Tue, 09 Apr 2013 20:29:48 +0000</pubDate>      <dc:creator>Joey-Elijah Sneddon</dc:creator>      <description><![CDATA[Alias, incidunt, sapiente, laboriosam hic inventore deleniti quibusdam est provident architecto earum mollitia rerum optio ipsum quos commodi maxime dolorem!      ]]></description>    </item>  </channel></rss>']);



    }));

    it('retrieves the latest articles from the RSS feed', inject(function(Articles, $rootScope) {
      var articlesActionComplete = false;
      $httpBackend.expectGET('http://www.omgchrome.com/feed');
      var articlesAction = Articles.getLatestArticles().then(function() {
        console.log("Finished fetching articles");
        articlesActionComplete = true;
      }, function() {
        console.log("ERrored out");
        articlesActionComplete = true;
      });

      $httpBackend.flush();

      waitsFor(function() {
        return articlesActionComplete;
      }, "Couldn't retrieve the latest articles", 2500);
    }));

    // addArticle.onerror
    it("retrieves the latest articles again, but doesn't add them because they exist", inject(function(Articles, $rootScope) {
      var articlesActionComplete = false;
      $httpBackend.expectGET('http://www.omgchrome.com/feed');
      var articlesAction = Articles.getLatestArticles().then(function() {
        articlesActionComplete = true;
      });
      $httpBackend.flush();

      waitsFor(function() {
        return articlesActionComplete;
      }, "Couldn't retrieve the latest articles", 2500);
    }));

    // TODO need 20 entries
    // it("gets the articles from the database", inject(function(Articles) {
    //   Articles.getArticles().then(function(articles) {
    //     console.log(articles);
    //     expect(articles).toBeDefined();
    //   });
    // }));
  });

  describe('Articles service rss failure', function() {
    var $httpBackend;
    beforeEach(inject(function($injector) {
      $httpBackend = $injector.get('$httpBackend');
      $httpBackend.when('GET', 'http://www.omgchrome.com/feed').respond(['<rss></rss>']);
    }));
    it('errors out when no articles are received', inject(function(Articles) {
      var failActionComplete = false;
      $httpBackend.expectGET('http://www.omgchrome.com/feed');
      var failAction = Articles.getLatestArticles().then(function() {}, function(status) {
        failActionComplete = true;
        expect(status.response).toBeTruthy();
      });
      $httpBackend.flush();

      waitsFor(function() {
        return failActionComplete;
      }, "Didn't error out with invalid input", 2500);
    }));
  });

  describe('Articles service network failure', function() {
    var $httpBackend;
    beforeEach(inject(function($injector) {
      $httpBackend = $injector.get('$httpBackend');
      $httpBackend.when('GET', 'http://www.omgchrome.com/feed').respond(500);
    }));
    it('errors out when a network issue occurs', inject(function(Articles) {
      var failActionComplete = false;
      $httpBackend.expectGET('http://www.omgchrome.com/feed');
      var failAction = Articles.getLatestArticles().then(function() {}, function(status) {
        failActionComplete = true;
        expect(status.response).toBeFalsy();
      });
      $httpBackend.flush();

      waitsFor(function() {
        return failActionComplete;
      }, "Didn't error out with invalid input", 2500);
    }));
  });

  describe('LocalStorage service', function() {
    beforeEach(function() {
      localStorage['unread'] = 2;
      module(function($provide) {
        $provide.provider('Badge', function() {
          this.$get = function() {
            return {
              notify: function() {}
            }
          };
        });
      });
    });

    it('increments the unread value', inject(function(LocalStorage) {
      LocalStorage.increment();
      expect(~~localStorage['unread']).toEqual(3);
    }));

    it('decrements the unread value', inject(function(LocalStorage) {
      LocalStorage.decrement();
      expect(~~localStorage['unread']).toEqual(1);
    }));

    it('returns if attempting to decrement from 0 unread articles', inject(function(LocalStorage) {
      localStorage['unread'] = 0;
      LocalStorage.decrement();
      expect(~~localStorage['unread']).toEqual(0);
    }));

    it('resets the unread value', inject(function(LocalStorage) {
      LocalStorage.reset();
      expect(~~localStorage['unread']).toEqual(0);
    }));
  });

  describe('truncateFilter', function() {
    // 150 character string, then 140 and 40 character strings that truncate appropriately
    var testString = 'qQ5ozw0oT8OkSoX0o0RFHkqXlzfSXyTEvB MjcieehLKCL43rdHrpcwaTd0hbBc0rECxIlJnQ3 EGf84xX7rOPdzaJkOyB2N7OjcH9GZ8w2OMftv 8wttZgNedWxSBxVMY5 SqfbJIaUlAM5sKpSj2';
    var testStringAt40 = 'qQ5ozw0oT8OkSoX0o0RFHkqXlzfSXyTEvB...';
    var testStringAt140 = 'qQ5ozw0oT8OkSoX0o0RFHkqXlzfSXyTEvB MjcieehLKCL43rdHrpcwaTd0hbBc0rECxIlJnQ3 EGf84xX7rOPdzaJkOyB2N7OjcH9GZ8w2OMftv 8wttZgNedWxSBxVMY5...';
    var testStringAt131 = 'qQ5ozw0oT8OkSoX0o0RFHkqXlzfSXyTEvB MjcieehLKCL43rdHrpcwaTd0hbBc0rECxIlJnQ3 EGf84xX7rOPdzaJkOyB2N7OjcH9GZ8w2OMftv 8wttZgNedWxSBxVMY5...';

    it('truncates a line greater than N characters and finds the first word break < N to break on', inject(function(truncateFilter) {
      expect(truncateFilter(testString, 150)).toEqual(testString);
      expect(truncateFilter(testString, 140)).toEqual(testStringAt140);
      expect(truncateFilter(testString, 40)).toEqual(testStringAt40);
    }));

    it('returns an empty string if the input is undefined', inject(function(truncateFilter) {
      expect(truncateFilter(undefined, 150)).toEqual('');
    }));

    it('finishes truncation if the next character was a space', inject(function(truncateFilter) {
      expect(truncateFilter(testString, 131)).toEqual(testStringAt131);
    }));
  });

  describe('eatClickDirective', function() {
    var element, scope;
    beforeEach(inject(function($rootScope, $compile) {
      element = angular.element(
        '<a href="boo" eat-click>Boourns!</a>'
      );
      scope = $rootScope;
      $compile(element)(scope);
      scope.$digest();
    }));
    it('prevents clicks on links from initializing default events, like preventDefault()', inject(function(eatClickDirective) {
      expect(element[0].onclick()).toBeFalsy();
      expect(element[0].click()).toBeFalsy();
    }));
  });


  describe('Notification service', function() {
    var notificationCancelled = 0;
    beforeEach(function() {
      localStorage['notificationsEnabled'] = true;
      webkitNotifications = {
        createNotification: function() {
          console.log("This is where a notification sould go");
          expect(localStorage['notificationsEnabled']).toEqual('true');
        }
      };
      var mockwebkitNotification = {
        addEventListener: function() {},
        show: function() {},
        cancel: function() { notificationCancelled++; }
      };

      spyOn(webkitNotifications, 'createNotification').andReturn(mockwebkitNotification);
    });

    var testArticle = {
      title: 'This is a test article',
      summary: 'This would be text within the article\'s description field that becomes the summary'
    };

    it('notifies the user of a single article with title and summary', inject(function(Notification) {
      var singleNotify = Notification.singleNotify(testArticle, 500);
      var multiNotify = Notification.multiNotify(10, 500);
      expect(webkitNotifications.createNotification).toHaveBeenCalled();

      waitsFor(function() {
        return notificationCancelled === 2;
      }, "Notifications weren't cancelled after 500ms", 1000);

    }));

    it('skips notifications if notificationsEnabled is false', inject(function(Notification) {
      localStorage['notificationsEnabled'] = false;
      Notification.start();
      Notification.singleNotify(testArticle, 500);
      Notification.multiNotify(5, 500);
      expect(webkitNotifications.createNotification).not.toHaveBeenCalled();
    }));

    it('skips notifications if there are no new articles', inject(function(Notification) {
      localStorage['newArticles'] = 0;
      Notification.start();
      expect(webkitNotifications.createNotification).not.toHaveBeenCalled();
    }));

    it('initiates a single-article notification for one new article', inject(function(Notification, databaseService) {
        var dbServiceSpy = databaseService;
        var callbackCalled = false;
        var testNotification = {
          title: "Test",
          summary: "Test summary"
        }
        dbServiceSpy.getDb = function(callback) {
          return {
            then: function(callback) {
              var dbTest = {
                transaction: function() {
                  return {
                    objectStore: function() {
                      return {
                        openCursor: function() {
                          var onsuccess = function(event) {
                            expect(event.target.result.value.title).toEqual(testNotification.title);
                            expect(event.target.result.value.summary).toEqual(testNotification.summary);
                          };
                          var targetObj = {
                            target: {
                              result: {
                                value: testNotification
                              }
                            }
                          };
                          onsuccess(targetObj);
                          return { onsuccess: onsuccess };
                        }
                      }
                    }
                  }
                }
              };
              callback(dbTest);
              console.log('called here!');
              callbackCalled = true;
            }
          }
        }

        localStorage['newArticles'] = 1;
        Notification.start();

        spyOn(databaseService, 'getDb').andReturn(dbServiceSpy);

        waitsFor(function() {
          return callbackCalled;
        },"blah", 5000);
        // TODO implement openCursor
    }));

    it('initiates a multi-article notification for > 1 new article', inject(function(Notification) {
      localStorage['newArticles'] = 4;
      Notification.start();
      expect(webkitNotifications.createNotification).toHaveBeenCalled();
    }));

  });

});