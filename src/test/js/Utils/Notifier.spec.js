import * as Notifier from 'js/Utils/Notifier';

describe('Notifier', () => {
  it('should trigger a test notification');

  it('should trigger a single notification');

  it('should trigger a single notification without an image if no thumbnail is present');

  it('should trigger a single notification without an image or buttons when in Opera');

  it('should trigger a multi notification');
  
  it('should trigger a multi notification without buttons when in Opera');

  it('should create the rich notification');

  it('should clear notifications');

  it('should set up event listeners for buttons and trigger single article actions');

  it('should set up event listeners for buttons and trigger multi article actions');

  it('should notify a user of an unread article');

  it('should notify a user of multiple unread articles');

  it('should skip notification if notifications are disabled');

  it('should skip notification if there are no new articles');
});