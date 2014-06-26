# OMG! Extensions

The official [OMG! Chrome!](http://www.omgchrome.com) and [OMG! Ubuntu!](http://www.omgubuntu.co.uk) Chrome extensions.

## Availability
The extension is available in the Chrome Web Store or can be downloaded from this repo and used as an "unpacked" extension.

## Libraries
This extension uses [CoffeeScript](http://coffeescript.org/) and [Sass](http://sass-lang.com/) and the following amazing projects:

- [React](http://facebook.github.io/react)
- [Bourbon](http://bourbon.io/)

## Usage
Please run `npm install -g gulp` (as sudo if necessary) to install the necessary prerequisites, then run `npm install` to install the extension's local dependencies.

To generate a production build, just run `gulp build` and a production directory, `build`, will be built and ready for use!

## Development
You will want to run `npm install -g karma` to install the Karma test runner.

Running `gulp dev` will watch for file changes and rebuild the extension on the fly.

To run the test suite run `gulp test` from the main repository. If, for whatever reason, you wish to use karma on its own, you can run `karma start test/karma.conf.js`

For CI use Karma will output test results for TeamCity. Other reporters are available.

Coverage is a bit spotty at the moment, but the console reporter will give you rough figures.

## License, et al.
Chrome is a registered trademark of [Google Inc](http://google.com/).

Ubuntu is a registered trademark of [Canonical Ltd](http://canonical.com).

OMG! Chrome! and OMG! Ubuntu! are members of the Ohso Ltd. Network.

Copyright (C) 2012-2014 [Ohso Ltd](http://ohso.co/).

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.