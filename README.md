# ChronoLogger

[![Gem Version](https://badge.fury.io/rb/chrono_logger.svg)](http://badge.fury.io/rb/chrono_logger)
[![Build Status](https://travis-ci.org/ma2gedev/chrono_logger.svg)](https://travis-ci.org/ma2gedev/chrono_logger)
[![Code Climate](https://codeclimate.com/github/ma2gedev/chrono_logger/badges/gpa.svg)](https://codeclimate.com/github/ma2gedev/chrono_logger)
[![Coverage Status](https://coveralls.io/repos/ma2gedev/chrono_logger/badge.svg)](https://coveralls.io/r/ma2gedev/chrono_logger)
[![endorse](https://api.coderwall.com/ma2gedev/endorsecount.png)](https://coderwall.com/ma2gedev)

A lock-free logger with timebased file rotation.

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

```
require 'chrono_logger'

logger = ChronoLogger.new('development.%Y%m%d')

logger.error("Enjoy")
logger.warn("logging!")
logger.info("Enjoy")
logger.debug("programming!")
```

## Contributing

1. Fork it ( https://github.com/ma2gedev/chrono_logger/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

MIT. See LICENSE.txt for more details.
