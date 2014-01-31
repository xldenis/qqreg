


require 'rubygems'
require 'bundler'
require 'rack'
Bundler.setup(:default)
require 'newrelic_rpm'

require './app'
use Rack::Deflater
run Registration
