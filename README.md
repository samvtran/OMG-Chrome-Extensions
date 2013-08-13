# OMG! Extensions

The official [OMG! Chrome!](http://www.omgchrome.com) and [OMG! Ubuntu!](http://www.omgubuntu.co.uk) Chrome extensions.

## Availability
The extension is available in the Chrome Web Store or can be downloaded from this repo and used as an "unpacked" extension.

## Libraries
This extension uses [CoffeeScript](http://coffeescript.org/) and [Sass](http://sass-lang.com/) and the following amazing projects:

- [AngularJS](http://angularjs.org)
- [Compass](http://compass-style.org/)

## Usage
Please run `npm install -g grunt-cli` (as sudo if necessary) to install the necessary prerequisites, then run `npm install --production` to install the extension's local dependencies.

To generate a production build, just run `grunt build` and a production directory, `dist`, will be built and ready for use!

## Development
Running `npm install` without the `--production` flag will install all the test dependencies. You will also want to run `npm install -g karma` to install the Karma test runner.

Running `grunt dev` will automagically build and lint Sass and CoffeeScript.

To run the test suite run `grunt test` from the main repository. `grunt test-watch` will keep karma running in the background and rerunning tests any time you make changes.

For CI use, `grunt test` generates a jUnit-formatted XML file, `test-results.xml`, that can be consumed by compatible CI servers.

## License, et al.
Chrome is a registered trademark of [Google Inc](http://google.com/).

Ubuntu is a registered trademark of [Canonical Ltd](http://canonical.com).

OMG! Chrome! and OMG! Ubuntu! are members of the Ohso Ltd. Network.

Copyright (C) 2012-2013 [Ohso Ltd](http://ohso.co/).

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.