# Telegram chat plugin for Redmine

This plugin posts updates to issues in your Redmine installation to a Telegram
channel. Improvements are welcome! Just send a pull request.

## Installation

From your Redmine plugins directory, clone this repository as `redmine_telegram` (note
the underscore!):

    git clone https://github.com/ANemcov/redmine_telegram.git redmine_telegram

You will also need the `httpclient` dependency, which can be installed by running

    bundle install

from the plugin directory.

Start mmigration command

	rake redmine:plugins:migrate RAILS_ENV=production

Restart Redmine, and you should see the plugin show up in the Plugins page.
Under the configuration options, set the "Telegram Bot Token" and default "Telegram Channel ID". For details see [Telegram BOT API](https://core.telegram.org/bots/API)

## Customized Routing

You can also route messages to different channels on a per-project basis. To
do this, create a project custom field (Administration > Custom fields > Project)
named `Telegram Channel`. If no custom channel is defined for a project, the parent
project will be checked (or the default will be used). To prevent all notifications
from being sent for a project, set the custom channel to `-`.

## Uninstall

From Redmine plugin directory run command

	rake redmine:plugins:migrate NAME=redmine_telegram VERSION=0 RAILS_ENV=production

After that restart Redmine.



For more information, see http://www.redmine.org/projects/redmine/wiki/Plugins.
