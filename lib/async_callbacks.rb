require 'active_support/core_ext'
require 'active_model/callbacks'

module AsyncCallbacks
  require 'async_callbacks/mixin'
  require 'async_callbacks/worker'
  require 'async_callbacks/serializer'

  include Mixin
end
