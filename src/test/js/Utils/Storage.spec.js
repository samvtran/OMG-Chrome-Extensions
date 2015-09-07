import * as Storage from 'js/Utils/Storage';
import { expect, rewireModule, stubChromeAPIs } from 'Helpers';
import isEqual from 'lodash.isequal';

define('Storage', () => {
  let sandbox;
  let chromeApis;
  beforeEach(() => {
    localStorage.clear();
    sandbox = sinon.sandbox.create();
    chromeApis = stubChromeAPIs();
  });
  afterEach(() => {
    sandbox.restore();
  })

  describe('version', () => {
    it('should return a version of 0 if no version number is available in the database', () => {
      expect(Storage.getVersion()).to.equal(0);
    });

    it('should return the version number saved in the database', () => {
      localStorage['version'] = 43;
      expect(Storage.getVersion()).to.equal("43")
    });

    it('should set the version to the latest version if no version exists', () => {
      expect(Storage.getVersion(true)).to.equal(Storage.latestVersion);
    });
  });

  describe('notifications', () => {
    it('should return whether notifications are enabled', () => {
      localStorage['notificationsEnabled'] = 'false';
      expect(Storage.areNotificationsEnabled()).to.equal(false);
      localStorage['notificationsEnabled'] = 'true';
      expect(Storage.areNotificationsEnabled()).to.equal(true);
    });

    it('should set notifications to enabled if the option has not been set', () => {
      expect(Storage.areNotificationsEnabled()).to.equal(true);
      expect(localStorage['notificationsEnabled']).to.equal('true');
    });

    it('should store whether notifications are enabled or not', () => {
      expect(Storage.setNotificationsEnabled(true));
      expect(localStorage['notificationsEnabled']).to.equal('true');
      expect(Storage.setNotificationsEnabled(false));
      expect(localStorage['notificationsEnabled']).to.equal('false');
    });

    it('should set and get the latest notification', () => {
      const obj = { type: 'multi', lastId: 2309482 };
      Storage.setLastNotification(obj);
      expect(isEqual(Storage.getLastNotification(), obj)).to.equal(true);
    });

    it('should return a default notification if no notification has been triggered yet', () => {
      expect(isEqual(Storage.getLastNotification(), { type: 'multi', lastId: 0 })).to.equal(true);
    });
  });

  describe('articles', () => {
    it('should save and retrieve a list of stored articles', () => {
      const articles = [{ a: 'a' }, { b: 'b' }, { c: 'c' }];
      Storage.setArticles(articles);
      expect(isEqual(Storage.getArticles(), articles)).to.equal(true);
    });

    it('should return an empty array if no articles are found', () => {
      expect(isEqual(Storage.getArticles(), [])).to.equal(true);
    });
  });

  describe('polling', () => {
    it("should return a default poll interval if one isn't set", () => {
      expect(Storage.getPollInterval()).to.equal(Storage.defaultPollInterval);
    });
    it('should save and retieve a poll interval', () => {
      const interval = 3516515;
      Storage.setPollInterval(interval);
      expect(Storage.getPollInterval()).to.equal(interval);
    })
  });
});