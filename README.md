# Telegram private messages plugin for Redmine

This plugin posts issues updates to a Telegram. 

## Installation

From your Redmine plugins directory, clone this repository as `redmine_telegram` (note
the underscore!):

    git clone https://github.com/massdest/redmine_telegram redmine_telegram

You will also need the `httpclient` dependency, which can be installed by running

    bundle install

from the plugin directory.

Start migration command

	rake redmine:plugins:migrate RAILS_ENV=production

Restart Redmine, and you should see the plugin show up in the Plugins page.
Under the configuration options, set the "Telegram Bot Token" and default "Telegram Channel ID". For details see [Telegram BOT API](https://core.telegram.org/bots/API)

## Update plugin

Go to plugin girectory and pull last version
	
	git pull origin master

Then start migration database to new version

	rake redmine:plugins:migrate RAILS_ENV=production

Last step - restaart your web-server to apply changes.

Now you can use last version.

## Using

Create User custom field named "Telegram Channel" for ex: http://redmine.com/custom_fields/new?type=UserCustomField (without quotes).
The channel can be entered per user settings http://redmine.com/my/account for every user who wants to get notifications, in "Telegram Channel" field, for ex: 11111111 (not phone number, but chat id)
To get Telegram Channel id you must create bot with [BotFather](https://core.telegram.org/bots#6-botfather), then get bot token and run bot.py from this folder, send any symbols to bot and it return your Telegram Channel id.

## Uninstall

From Redmine plugin directory run command

	rake redmine:plugins:migrate NAME=redmine_telegram VERSION=0 RAILS_ENV=production

After that restart Redmine.



For more information, see http://www.redmine.org/projects/redmine/wiki/Plugins.
