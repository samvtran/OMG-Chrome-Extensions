import query from 'query-string';

export class Article {
  constructor({ title, link, date, id, unread }) {
    this.title = title;
    this.link = link;
    this.date = date;
    this.id = id;
    this.unread = unread;
  }
}

export function xmlParse(text) {
  const dom = new DOMParser().parseFromString(text, 'application/xml');
  const channel = dom.querySelector('channel');
  if (!channel) return [];

  const items = channel.querySelectorAll('item');
  if (!items) return [];

  return Array.prototype.map.call(items, (item) => {
    const thumbnail = item.querySelector('thumbnail');
    const id = ~~query.parse(query.extract(item.querySelector('guid').textContent)).p;

    const article = {
      title: item.querySelector('title').textContent,
      link: item.querySelector('link').textContent,
      date: Date.parse(item.querySelector('pubDate').textContent),
      id,
      unread: true,
    };
    if (thumbnail) article.thumbnail = thumbnail.getAttribute('url');
    return article;
  });
}

export function getParser(type) {
  switch (type) {
    // TODO case 'json':
    case 'xml':
    default:
      return xmlParse;
  }
}