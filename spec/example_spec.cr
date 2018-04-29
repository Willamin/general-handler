require "../src/general_handler.cr"

class ResponseContext
  property input : String
  property output : IO = STDOUT

  def initialize(@input); end
end

class HelloHandler < GeneralHandler::Handler(ResponseContext)
  def call(context)
    case context.input
    when "hello"
      context.output.puts "hi there"
    else
      call_next(context)
    end
  end
end

class ByeHandler < GeneralHandler::Handler(ResponseContext)
  def call(context)
    case context.input
    when "bye"
      context.output.puts "see ya"
    else
      call_next(context)
    end
  end
end

class ResponseServer < GeneralHandler::Server(ResponseContext)
  def run(s : String)
    c = ResponseContext.new(s)
    process(c)
  end
end

server = ResponseServer.new([
  HelloHandler.new,
  ByeHandler.new,
])

STDOUT.puts "The following should output \"hi there\""
STDOUT.print " # => "
server.run("hello")

STDOUT.puts "The following should output \"see ya\""
STDOUT.print " # => "
server.run("bye")

STDOUT.puts "The following should output \"error rescued\""
STDOUT.print " # => "
begin
  server.run("uh-oh")
rescue GeneralHandler::NoHandlerError
  puts "error rescued"
end
