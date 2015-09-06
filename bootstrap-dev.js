(function() {
  console.log("Bootstrapping...");
  var ajax = new XMLHttpRequest();
  (function(d, t) {
    var g = d.createElement(t),
      s = d.getElementsByTagName(t)[0];
    g.src = 'http://localhost:3000/<!-- FILENAME -->';
    s.parentNode.insertBefore(g, s);
  }(document, 'script'));
}());