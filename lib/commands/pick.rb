require 'commands/base'

module Commands
  class Pick < Base
    StoryType = Struct.new(:type, :plural_type, :branch_suffix)
    Types = {
      :feature => StoryType.new('feature', 'features', 'feature'),
      :bug     => StoryType.new('bug', 'bugs', 'hotfix'),
      :chore   => StoryType.new('chore', 'chores', 'chore')
    }

    def initialize(type, *args)
      super(*args)
      @type = Types[type]
    end

    def type
      @type.type
    end

    def plural_type
      @type.plural_type
    end

    def branch_suffix
      @type.branch_suffix
    end

    def run!
      response = super
      return response if response > 0

      msg = "Retrieving latest #{plural_type} from Pivotal Tracker"
      if options[:only_mine]
        msg += " for #{options[:full_name]}"
      end
      put "#{msg}..."

      story = get_and_print_story "No #{plural_type} available!"

      default_desc = story.name.gsub(' ', '_').gsub(/[^a-zA-Z_]/, '')
      default_desc = default_desc.length > 175 ? default_desc[0..172].strip+'...' : default_desc
      unless options[:quiet] || options[:defaults]
        put "Enter branch description [#{default_desc}]: ", false
        description = input.gets.chomp.gsub(' ', '_').gsub('-', '_')
        if description.empty?
          description = default_desc
        end
      end

      put "Updating #{type} status in Pivotal Tracker..."
      if story.update(:owned_by => options[:full_name], :current_state => :started)
        
        now = Date.today.strftime('%Y%m%d')
        branch = "#{branch_suffix}/#{now}-#{options[:initials]}-#{description}-#{story.id}"
        
        if get("git branch").match(branch).nil?
          put "Creating new #{type} branch '#{branch}' from #{integration_branch}"
          sys "git checkout #{integration_branch}"
          sys "git pull"
          sys "git checkout -b #{branch}"
        end

        return 0
      else
        put "Unable to mark #{type} as started"

        return 1
      end
    end

    protected

    def fetch_story
      conditions = { :story_type => type, :current_state => "unstarted", :limit => 1, :offset => 0 }
      conditions[:owned_by] = options[:full_name] if options[:only_mine]
      search_story conditions
    end
    
    private

    def type_options
      options[type.to_sym] || {}
    end
  end
end
