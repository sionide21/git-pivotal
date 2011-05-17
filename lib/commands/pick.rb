require 'commands/base'

module Commands
  class Pick < Base

    def type
      raise Error("must define in subclass")
    end

    def plural_type
      raise Error("must define in subclass")
    end

    def branch_suffix
      raise Error("must define in subclass")
    end

    def run!
      response = super
      return response if response > 0

      msg = "Retrieving latest #{plural_type} from Pivotal Tracker"
      if options[:only_mine]
        msg += " for #{options[:full_name]}"
      end
      put "#{msg}..."

      unless story
        put "No #{plural_type} available!"
        return 0
      end

      put "Story: #{story.name}"
      put "URL:   #{story.url}"

      put "Updating #{type} status in Pivotal Tracker..."
      if story.update(:owned_by => options[:full_name], :current_state => :started)

        default_desc = story.name.gsub(' ', '_')
        unless options[:quiet] || options[:defaults]
          put "Enter branch description [#{default_desc}]: ", false
          description = input.gets.chomp.gsub(' ', '_').gsub('-', '_')
          if description.empty?
            description = default_desc
          end
        end

        now = Date.today.strftime('%Y%m%d')
        branch = "#{branch_suffix}/#{options[:initials]}-#{now}-#{description}-#{story.id}"
        
        if get("git branch").match(branch).nil?
          put "Switched to a new branch '#{branch}'"
          sys "git checkout -b #{branch}"
        end

        return 0
      else
        put "Unable to mark #{type} as started"

        return 1
      end
    end

    protected

    def story
      return @story if @story

      conditions = { :story_type => type, :current_state => "unstarted", :limit => 1, :offset => 0 }
      conditions[:owned_by] = options[:full_name] if options[:only_mine]
      @story = project.stories.all(conditions).first
    end
    
    private

    def type_options
      options[type.to_sym] || {}
    end
  end
end
