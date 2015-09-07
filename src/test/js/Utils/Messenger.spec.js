import * as Messenger from 'js/Utils/Messenger';
import * as types from 'js/Utils/MessageTypes';
import { stubChromeAPIs } from 'Helpers';

describe('Messenger', () => {
  let sandbox;
  let stubs;
  beforeEach(() => {
    stubs = stubChromeAPIs();
    sandbox = sinon.sandbox.create();
  });

  afterEach(() => sandbox.restore());

  it('should add a listener for the given type', () => {
    const stub = sandbox.stub(stubs.runtime.onMessage, 'addListener');
    Messenger.listenFor(types.MESSAGE_UPDATE_UI, () => {});
    expect(stub).to.have.been.calledOnce;
  });

  it('should only trigger listeners if the types match', () => {
    const callback = {
      toCall: () => {}
    };
    const stub = sandbox.stub(callback, 'toCall');
    sandbox.stub(stubs.runtime.onMessage, 'addListener', cb => cb({ type: types.MESSAGE_UPDATE_UI }));

    Messenger.listenFor('nocall', callback.toCall);
    expect(stub).to.have.not.been.called;

    Messenger.listenFor(types.MESSAGE_UPDATE_UI, callback.toCall);
    expect(stub).to.have.been.calledOnce;
  })

  it('should send an update UI message to listeners', () => {
    const stub = sandbox.stub(stubs.runtime, 'sendMessage');
    Messenger.updateUI();
    expect(stub).to.have.been.calledWith({ type: types.MESSAGE_UPDATE_UI });
  });
});