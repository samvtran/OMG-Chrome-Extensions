import sinonChai from 'sinon-chai';
import chai from 'chai';
chai.use(sinonChai);

function rewireModule(rewiredModule, varValues, before = () => {}, after = () => {}) {
  var rewiredReverts = [];

  beforeEach(function() {
    before();
    var key, value, revert;
    const rewiredValues = typeof varValues === 'function' ? varValues() : varValues;
    for (key in rewiredValues) {
      if (rewiredValues.hasOwnProperty(key)) {
        value = rewiredValues[key];
        revert = rewiredModule.__set__(key, value);
        rewiredReverts.push(revert);
      }
    }
  });

  afterEach(function() {
    after();
    rewiredReverts.forEach(function(revert) {
      revert();
    });
  });

  return rewiredModule;
};

function stubChromeAPIs() {
  window.chrome = {
    browserAction: {
      setBadgeText: () => {},
      setIcon: () => {}
    },
    notifications: {

    }
  }

  return window.chrome;
}

export default {
  expect: chai.expect,
  rewireModule,
  stubChromeAPIs
}