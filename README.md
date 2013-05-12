# OMG! Chrome! Extension

The official [OMG! Chrome!](http://omgchrome.com) Chrome extension

## Availability
The extension is available in the Chrome Web Store or can be downloaded from this repo and used as an "unpacked" extension.

## Compatibility
The extension has been tested on the latest Chrome dev releases. The extension may not function properly with outdated versions of Chrome/ium.

## Libraries, et al.
This extension uses [CoffeeScript](http://coffeescript.org/) and [Sass](http://sass-lang.com/) and the following amazing projects:

- [AngularJS](http://angularjs.org)
- [Compass](http://compass-style.org/)

## Usage
Please run `npm i -g grunt-cli` (as sudo if necessary) to install the necessary prerequisites, then run `npm install` to install the rest of the dependencies.

To generate a production build, just run `grunt build` and a production directory will be ready for usage!

## Development
Please run `npm i -g grunt-cli istanbul karma@~0.9 jasmine-node` (as sudo if needed) to install all the development and testing prerequisites, then run `npm install` to install the rest of the dependencies.

To start development and have SASS and CoffeeScript built automatically, run `grunt dev` and use the dev folder as the Chrome extension.

To run the test suite (***currently in progress***) run `karma start test/karma.conf.js` from the main repository. This will keep karma running in the background and rerunning tests any time you make changes.

## License, et al.
Chrome is a registered trademark of [Google Inc]](http://google.com/).

OMG! Chrome! is a member of the Ohso Ltd Network.

Copyright (C) 2012-2013 [Ohso Ltd](http://ohso.co/)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.