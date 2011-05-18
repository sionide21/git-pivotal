require 'commands/base'
require 'commands/pivotal_branch'

module Commands
  class Comment < Base
    include PivotalBranch

    def run!
      super

      unless @message
        @message = $stdin.read
      end

      get_story.notes.create(:text => @message)

      return 0
    end

  private
  
    def parse_argv(*args)
      OptionParser.new do |opts|
        opts.banner = "Usage: git comment [options]"
        opts.on("-s", "--story=", "Specify the story to use") { |s| options[:story] = s }
        opts.on("-k", "--api-key=", "Pivotal Tracker API key") { |k| options[:api_token] = k }
        opts.on("-p", "--project-id=", "Pivotal Trakcer project id") { |p| options[:project_id] = p }
        opts.on("-n", "--full-name=", "Pivotal Trakcer full name") { |n| options[:full_name] = n }
        opts.on("-m", "--message=", "The comment message") { |m| @message = m }
        opts.on("-q", "--quiet", "Quiet, no-interaction mode") { |q| options[:quiet] = q }
        opts.on("-v", "--[no-]verbose", "Run verbosely") { |v| options[:verbose] = v }
        opts.on_tail("-h", "--help", "This usage guide") { put opts.to_s; exit 0 }
      end.parse!(args)
    end
  
  end
end
