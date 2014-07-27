# Cancannible
[![Build Status](https://travis-ci.org/evendis/cancannible.svg?branch=master)](https://travis-ci.org/evendis/cancannible)

CanCan RBAC support with permissions inheritance and database storage

TODO: wip refactoring to a new gem structure

## Installation

Add this line to your application's Gemfile:

    gem 'cancannible'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cancannible

## Configuring cached abilities storage

Cancannible does not implement any specific storage mechanism - that is up to you to provide if you wish.

Cached abilities storage is enabled by setting the `get_cached_abilities` and `store_cached_abilities` hooks with
the appropriate implementation for your caching infrastructure.

For example, this is a simple scheme using Redis:

    Cancannible.setup do |config|

      # Return an Ability object for +user+ or nil if not found
      config.get_cached_abilities = proc{|user|
        key = "user:#{user.id}:abilities"
        Marshal.load(@redis.get(key))
      }

      # Command: put the +ability+ object for +user+ in the cache storage
      config.store_cached_abilities = proc{|user,ability|
        key = "user:#{user.id}:abilities"
        @redis.set(key, Marshal.dump(ability))
      }

    end



## Contributing

1. Fork it ( https://github.com/evendis/cancannible/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
