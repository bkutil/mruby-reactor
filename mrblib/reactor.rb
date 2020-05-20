module Reactor
  class Dispatcher
    def initialize
      @handlers = Hash.new { |h, k| h[k] = {} }
      @demuxer = Demuxer.new(self)
    end

    def register(handle, event, handler)
      @handlers[handle][event] = handler
      @demuxer.add(handle, event)
    end

    def deregister(handle, event)
      @demuxer.remove(handle, event)
      @handlers[handle].delete(event)
      @handlers.delete(handle) if @handlers[handle].empty?
    end

    def notify(handle, event)
      handler = @handlers.dig(handle, event)
      handler.call(self, handle, event) if handler
    end

    def run
      @demuxer.run
    end

    def stop
      @demuxer.stop
    end
  end

  class Demuxer
    def initialize(dispatcher)
      @dispatcher = dispatcher
      @readers = []
      @writers = []
      @io_timeout = 0.01
      @run = nil
    end

    def add(handle, op)
      case op
      when :read
        add_handle(@readers, handle)
      when :write
        add_handle(@writers, handle)
      else
        nil
      end
    end

    def remove(handle, op)
      case op
      when :read
        remove_handle(@readers, handle)
      when :write
        remove_handle(@writers, handle)
      else
        nil
      end
    end

    def stop
      @run = nil
    end

    def run
      @run = :run

      loop do
        readable, writable = IO.select(@readers, @writers, nil, @io_timeout)

        readable && readable.each do |handle|
          @dispatcher.notify(handle, :read)
        end

        writable && writable.each do |handle|
          @dispatcher.notify(handle, :write)
        end

        break unless @run
      end
    end

    private

    def add_handle(to, handle)
      to << handle unless to.include?(handle)
    end

    def remove_handle(from, handle)
      from.delete(handle)
    end
  end
end
