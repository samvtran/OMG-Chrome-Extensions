import * as types from './MessageTypes';

export function updateUI() {
  chrome.runtime.sendMessage({type: types.MESSAGE_UPDATE_UI});
}
export function listenFor(type, cb) {
  chrome.runtime.onMessage.addListener((req) => {
    if (req.type === type) cb();
  })
}