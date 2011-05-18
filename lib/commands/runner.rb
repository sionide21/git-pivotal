require 'commands/base'

def Commands::run(command)
  begin
    exit command.new(STDIN, STDOUT, *ARGV).run!
  rescue Commands::NoSuchStory => e
    puts e
    exit 1
  rescue Interrupt
    exit 2
  end
end