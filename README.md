# ChronoLogger

[![Gem Version](https://badge.fury.io/rb/chrono_logger.svg)](http://badge.fury.io/rb/chrono_logger)
[![Build Status](https://travis-ci.org/ma2gedev/chrono_logger.svg)](https://travis-ci.org/ma2gedev/chrono_logger)
[![Code Climate](https://codeclimate.com/github/ma2gedev/chrono_logger/badges/gpa.svg)](https://codeclimate.com/github/ma2gedev/chrono_logger)
[![Coverage Status](https://coveralls.io/repos/ma2gedev/chrono_logger/badge.svg)](https://coveralls.io/r/ma2gedev/chrono_logger)
[![Inline docs](http://inch-ci.org/github/ma2gedev/chrono_logger.svg?branch=master)](http://inch-ci.org/github/ma2gedev/chrono_logger)
[![endorse](https://api.coderwall.com/ma2gedev/endorsecount.png)](https://coderwall.com/ma2gedev)

A lock-free logger with timebased file rotation.

Ruby's stdlib `Logger` wraps `IO#write` in mutexes. `ChronoLogger` removes these mutexes.

`ChronoLogger` provides time based file rotation such as:

```
logger = ChronoLogger.new('/log/production.log.%Y%m%d')
Time.now.strftime('%F')
# => "2015-01-26"
File.exist?('/log/production.log.20150126')
# => true

# one day later
Time.now.strftime('%F')
# => "2015-01-27"
logger.write('hi next day')
File.exist?('/log/production.log.20150127')
# => true
```

## Motivation

Current my projects uses `::Logger` with cronolog. So

- Reduce dependency such as cronolog
- Remove mutexes in ruby world because os already does when some environments (ex: ext4 file system)
- Support time based rotation without renaming file because file renaming sometime makes problem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'chrono_logger'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install chrono_logger

## Usage

Same interfaces ruby's stdlib `Logger` except for `new` method.

```ruby
require 'chrono_logger'

# specify path with `Time#strftime` format
logger = ChronoLogger.new('development.%Y%m%d')

logger.error("Enjoy")
logger.warn("logging!")
logger.info("Enjoy")
logger.debug("programming!")
```

With Rails:

```ruby
# in config/environments/{development,production}.rb

config.logger = ChronoLogger.new("#{config.paths['log'].first}.%Y%m%d")
```

## Migrating from `::Logger` with cronolog

You only change `Logger.new` into `ChronoLogger.new`:

```ruby
# for instance your setup is like the following
Logger.new(IO.popen("/usr/sbin/cronolog production.%Y%m%d", "w"))

# turns into
ChronoLogger.new('production.%Y%m%d')
```

## Limitation

- High performance logging only daily based time formatting path for example `'%Y%m%d'`. You can create pull request if you need other time period.

## Contributing

1. Fork it ( https://github.com/ma2gedev/chrono_logger/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

MIT. See [LICENSE.txt](LICENSE.txt) for more details.

## Resources

- [ChronoLogger logging is 1.5x faster than ruby's stdlib Logger](https://coderwall.com/p/vjjszq/chronologger-logging-is-1-5x-faster-than-ruby-s-stdlib-logger)

