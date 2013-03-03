# incremental\_backup

Creates incremental backups via ssh and rsync.

## Description

incremental\_backup is a tool to easily create incremental backups to a local directory or to a remote server using ssh and rsync.

The backup is by default performed every hour of a determined set of files and folders. The backup is easily restorable from every hour in the last day, every day in the last week, every week in the last month, every month in the past three months and every year forever. These default settings can be changed to suit your needs.

## Dependencies

* Ruby (tested on 1.9.3)
* ssh
* rsync

## Installation

    $ gem install incremental_backup

## Usage

The recommended usage is to create a small ruby application with a gemfile. Take a look at [the example](https://github.com/lasseebert/incremental_backup/tree/master/live_example).

## Cron
It's recommended to setup a cron job to handle scheduling of the backup.

The cron job can be triggered as often as you would like to, the script still only at most perform one backup per hour. This is useful if your computer is usually not online for more than an hour.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
