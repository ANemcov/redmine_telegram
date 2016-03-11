require 'redmine'

require 'telegram_mailer_patch'

Redmine::Plugin.register :redmine_telegram do
	name 'Redmine Telegram'
	author 'Alex Nemtsov aka pythonchik'
	url 'https://github.com/ANemcov/redmine_telegram'
	author_url 'http://cmd-q.ru'
	description 'Telegram chat integration'
	version '0.3'

	requires_redmine :version_or_higher => '0.8.0'

	settings \
		:default => {
			'callback_url' => 'https://api.telegram.org/bot',
			'channel' => nil,
			'icon' => 'https://raw.github.com/sciyoshi/redmine-slack/gh-pages/icon.png',
			'username' => 'redmine',
			'display_watchers' => 'no',
			'new_include_description' => 1,
			'updated_include_description' => 1,
			'use_proxy' => 0,
			'proxyurl' => nil
		},
		:partial => 'settings/telegram_settings'
end
