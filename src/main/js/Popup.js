import Articles from './Components/Articles';
import MenuBar from './Components/MenuBar';
import Config from 'config!./Config';
import Messenger from './Utils/Messenger';
import * as types from './Utils/MessageTypes';
import Storage from './Utils/Storage';

(function() {
  const refresh = document.querySelector('.PopupHeader-refresh');
  const options = document.querySelector('#options');
  const markAllAsRead = document.querySelector('#markAllAsRead');
  const articleList = document.querySelector('#articleList');

  MenuBar.updateIcon(Articles.getArticles());
  Articles.populate(articleList);

  refresh.addEventListener('click', (e) => {
    if (!refresh.classList.contains('is-refreshing')) {
      refresh.classList.add('is-refreshing');
      Articles.fetchArticles(function() {
        const newArticles = Articles.getArticles();
        if (newArticles.length) {
          Storage.setLastNotification({type: 'single', lastId: newArticles[0].id, article: newArticles[0]});
        }
        Articles.populate(articleList);
        refresh.classList.remove('is-refreshing');
      });
    }
  });

  options.addEventListener('click', () => chrome.tabs.create({url: 'options.html'}))
  markAllAsRead.addEventListener('click', () => Articles.markAllAsRead(() => Articles.populate(articleList)));

  Messenger.listenFor(types.MESSAGE_UPDATE_UI, () => {
    Articles.populate(articleList);
  })
}());