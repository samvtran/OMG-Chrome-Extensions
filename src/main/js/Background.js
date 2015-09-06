import Articles from './Components/Articles';
import MenuBar from './Components/MenuBar';
import Messenger from './Utils/Messenger';
import Notifier from './Utils/Notifier';
import Storage from './Utils/Storage';

MenuBar.updateIcon(Articles.getArticles());

function setupPull() {
  setTimeout(() => {
    Articles.fetchArticles(() => {
      Notifier.notifyUnread();
      Messenger.updateUI();
      setupPull();
    });
  }, Storage.getPollInterval());
}

(() => {
  Articles.fetchArticles(() => {
    Notifier.notifyUnread();
    Messenger.updateUI();
    setupPull();
  }, Storage.getVersion(true) !== Storage.latestVersion);
})();