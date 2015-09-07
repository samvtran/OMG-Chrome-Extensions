import sinonChai from 'sinon-chai';
import chai from 'chai';
import lolex from 'lolex';
chai.use(sinonChai);

function stubChromeAPIs() {
  window.chrome = {
    browserAction: {
      setBadgeText: () => {},
      setIcon: () => {}
    },
    notifications: {
      create: () => {},
      clear: () => {},
      onShowSettings: {
        addListener: () => {}
      },
      onClicked: {
        addListener: () => {}
      },
      onButtonClicked: {
        addListener: () => {}
      }
    },
    runtime: {
      sendMessage: () => {},
      onMessage: {
        addListener: () => {}
      }
    }
  }

  return window.chrome;
}

export default {
  expect: chai.expect,
  lolex,
  stubChromeAPIs
}