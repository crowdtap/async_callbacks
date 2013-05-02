require 'active_support/core_ext'
require 'active_model/callbacks'
require 'async_callbacks/mixin'
require 'async_callbacks/worker'
require 'async_callbacks/serializer'

module AsyncCallbacks
  include Mixin
end
