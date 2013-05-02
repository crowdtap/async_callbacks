require 'sidekiq'

class AsyncCallbacks::Worker
  include Sidekiq::Worker

  cattr_accessor :auto_drain
  self.auto_drain = false

  def perform(vars_hash, method, finder)
    instance = eval(finder)
    vars_hash = AsyncCallbacks::SERIALIZER.load(vars_hash).symbolize_keys!
    vars_hash.each { |k,v| instance.instance_variable_set(k, v)  }

    # TODO Disable persistance on the instance as this is very racy and dangerous
    instance.send(method)
  rescue Exception => e
    Rails.logger.error "AsyncCallbacks Exception #{e.message}: #{e.backtrace.join("\n")}"
    raise e
  end
end

