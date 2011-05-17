require 'commands/base'

module Commands
  class Comment < Base

    def run!
      super

      unless story_id
        put "Branch name must contain a Pivotal Tracker story id"
        return 1
      end

      unless @message
        @message = $stdin.read
      end

      story.notes.create(:text => @message)

      return 0
    end

  protected

    def story_id
      if m = current_branch.match(BRANCH_REGEX)
        return m[BRANCH_REGEX_ID].to_i
      end
    end

    def story
      @story ||= project.stories.find(story_id)
    end
    
  private
  
    def parse_argv(*args)
      OptionParser.new do |opts|
        opts.banner = "Usage: git comment [options]"
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
