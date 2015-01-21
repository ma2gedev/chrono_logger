# ChronoLogger

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
