import * as types from './MessageTypes';

export default class Messenger {
  static updateUI() {
    chrome.runtime.sendMessage({ type: types.MESSAGE_UPDATE_UI });
  }
  static listenFor(type, cb) {
    chrome.runtime.onMessage.addListener((req) => {
      if (req.type === type) cb();
    })
  }
}