var cloneDeep = require('lodash.clonedeep');
module.exports = (function() {
  var config = {
    /**
     * The production array contains all the flavors that will be produced upon running gulp:build
     *
     * A few things to keep in mind:
     * - Opera won't accept minified JS, so make sure to turn minification off for Opera extensions
     */
    production: [
      {
        name: "example",
        title: "OMG! Example!",
        directory: "example",
        manifest: 'example',
        minify: true,
        parser: 'xml',
        homepage: "http://www.example.com",
        feedUrl: "http://www.example.com/rss2",
        aboutText: "This is HTML-enabled about text that shows up on the options page"
      }
    ],
    /**
     * This is just a JavaScript file, so you can of course skip the copying and pasting and just reuse your configuration
     */
    dev: {
      name: "example-dev",
      title: "OMG! Example!",
      directory: "example",
      manifest: 'exampleDev',
      minify: false,
      parser: 'xml',
      homepage: "http://www.example.com",
      feedUrl: "http://www.example.com",
      aboutText: ""
    },
    manifests: {
      chrome: {
        "name": "OMG! Example!",
        "version": "3.0.0",
        "manifest_version": 2,
        "description": "So example",
        "icons": {
          "19": "images/icon_active19.png",
          "48": "images/icon_logo48.png",
          "128": "images/icon_logo128.png"
        },
        "browser_action": {
          "default_icon": {
            "19": "images/icon_active19.png",
            "38": "images/icon_active38.png"
          },
          "default_title": "OMG! Example!",
          "default_popup": "popup.html"
        },
        "background": {
          "page": "background.html"
        },
        "permissions": [
          "http://*.example.com/*",
          "notifications"
        ],
        "web_accessible_resources": [
          "images/icon_logo48.png"
        ],
        "options_page": "options.html"
      }
    }
  };

  // Intead of copying and pasting, we're going to reuse our production build with the addition of some CSP relaxation for development
  config.manifests.chromeDev = cloneDeep(config.manifests.chrome);
  config.manifests.chromeDev['content_security_policy'] = "script-src 'self' 'unsafe-eval' http://localhost:3000; object-src 'self'";
  return config;
}());