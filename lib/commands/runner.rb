require 'commands/base'

def Commands::run(command)
  begin
    command.new(STDIN, STDOUT, *ARGV).run! || 0
    exit 1
  rescue Commands::NoSuchStory => e
    puts e
    exit 1
  rescue Interrupt
    exit 2
  rescue Exception => e
    puts e
    exit 3
  end
end