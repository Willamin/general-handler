module GeneralHandler
  VERSION = {{ `shards version __DIR__`.chomp.stringify }}

  class NoHandlerError < Exception; end

  abstract class Handler(T)
    property next : GeneralHandler::Handler(T) | (T ->) | Nil

    abstract def call(context : T)

    def call_next(context : T)
      if next_handler = @next
        next_handler.call(context)
      else
        raise GeneralHandler::NoHandlerError.new("No more handlers")
      end
    end
  end

  abstract class Server(T)
    property handler : GeneralHandler::Handler(T)

    def initialize(handlers : Array(GeneralHandler::Handler(T)))
      @handler = GeneralHandler::Server(T).build_middleware(handlers)
    end

    def initialize(handlers : Array(GeneralHandler::Handler(T)), &handler : T ->)
      @handler = GeneralHandler::Server(T).build_middleware(handlers, handler)
    end

    def before_process(context : T); end

    def after_process(context : T); end

    def process(context : T)
      before_process(context)

      @handler.call(context)

      after_process(context)
    end

    def self.build_middleware(handlers, last_handler : (T ->)? = nil)
      raise ArgumentError.new "You must specify at least one #{{{T.stringify}}} Handler." if handlers.empty?
      0.upto(handlers.size - 2) { |i| handlers[i].next = handlers[i + 1] }
      handlers.last.next = last_handler if last_handler
      handlers.first
    end
  end
end
