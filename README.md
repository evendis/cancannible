# Cancannible
[![Build Status](https://travis-ci.org/evendis/cancannible.svg?branch=master)](https://travis-ci.org/evendis/cancannible)

Cancannible is a gem that extends CanCan with a range of capabilities:
* database-persisted permissions
* export CanCan methods to the model layer (so that permissions can be applied in model methods, and easily set in a test case)
* permissions inheritance (so that, for example, a User can inherit permissions from Roles and/or Groups)
* caching of abilities (so that they don't need to be recalculated on each web request)
* general-purpose access refinements (so that, for example, CanCan will automatically enforce multi-tenant or other security restrictions)

## Limitations
Cancannible's origin was in a web application that's been in production for over 3 years.
This gem is an initial refactoring as a separate component. It continues to be used in production, but
there are some limitations and constraints that will ideally be removed or changed over time:

* It only supports ActiveRecord for permissions storage (specifically, it has been tested with PostgreSQL and SQLite)
* It currently assumes permissions are stored in a Permission model with a specific structure
* It works with the [CanCan](https://github.com/ryanb/cancan) gem. It has not yet been tested with the new [CanCanCan](https://github.com/CanCanCommunity/cancancan) gem.
* It assumes and is only tested with Rails 3.2. Not yet with Rails 4.
* It assumes your CanCan rules are setup with the default `Ability` class


## Installation

Add this line to your application's Gemfile:

    gem 'cancannible'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cancannible

## Configuration

A generator is provided to create:
* a default initialization template
* a Permission model and migration

After installing the gem, run the generator:

    $ rails generate cancannible:install

## The Cancannible initialization file

See the initialization file template for specific instructions. Use the initialization file to configure:
* abilities caching
* general-purpose access refinements

## Configuring cached abilities storage

Cancannible does not implement any specific storage mechanism - that is up to you to provide if you wish.

Cached abilities storage is enabled by setting the `get_cached_abilities` and `store_cached_abilities` hooks with
the appropriate implementation for your caching infrastructure.

For example, this is a simple scheme using Redis:

    Cancannible.setup do |config|

      # Return an Ability object for +grantee+ or nil if not found
      config.get_cached_abilities = proc{|grantee|
        key = "user:#{grantee.id}:abilities"
        Marshal.load(@redis.get(key))
      }

      # Command: put the +ability+ object for +grantee+ in the cache storage
      config.store_cached_abilities = proc{|grantee,ability|
        key = "user:#{grantee.id}:abilities"
        @redis.set(key, Marshal.dump(ability))
      }

    end


## Contributing

1. Fork it ( https://github.com/evendis/cancannible/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
