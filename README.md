# Telegram chat plugin for Redmine

This plugin posts updates to issues in your Redmine installation to a Telegram
channel. Improvements are welcome! Just send a pull request.

## Screenshot

![screenshot](https://raw.github.com/sciyoshi/redmine-Telegram/gh-pages/screenshot.png)

## Installation

From your Redmine plugins directory, clone this repository as `redmine_Telegram` (note
the underscore!):

    git clone https://github.com/sciyoshi/redmine-Telegram.git redmine_Telegram

You will also need the `httpclient` dependency, which can be installed by running

    bundle install

from the plugin directory.

Restart Redmine, and you should see the plugin show up in the Plugins page.
Under the configuration options, set the Telegram API URL to the URL for an
Incoming WebHook integration in your Telegram account.

## Customized Routing

You can also route messages to different channels on a per-project basis. To
do this, create a project custom field (Administration > Custom fields > Project)
named `Telegram Channel`. If no custom channel is defined for a project, the parent
project will be checked (or the default will be used). To prevent all notifications
from being sent for a project, set the custom channel to `-`.

For more information, see http://www.redmine.org/projects/redmine/wiki/Plugins.
