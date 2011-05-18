require 'commands/base'

def Commands::run(command)
  begin
    result = command.new(STDIN, STDOUT, *ARGV).run!
  rescue Commands::NoSuchStory => e
    puts e
    exit 1
  rescue Interrupt
    exit 2
  rescue Exception => e
    puts e
    exit 3
  end
  exit result || 0
end