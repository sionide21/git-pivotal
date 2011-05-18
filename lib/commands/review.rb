require 'commands/pick'

module Commands
  class Review < Base
    def run!
      response = super
      return response if response > 0
      
      puts "Retrieving latest finished stories from Pivotal Tracker"
      story = get_and_print_story "No finished stories available!"
      
      
      
      puts "Running git fetch"
      sys("git fetch")
      
      puts "Locating story branch"
      
      branch = find_story_branch(story.id)
      
      puts "Checking out story branch for review"
      
      #sys("git checkout -b #{branch} origin/#{branch}")
      
      puts "You are now in the review branch for this story."
      puts "You can see the diff with: "
      
      puts "\t'git diff #{integration_branch}...'"
      
    end

    private
    
    def find_story_branch(id)
      branches = []
      get("git branch -r | grep '^  origin/.*\\-#{id}$'").each_line do |branch|
        branch = branch.strip.sub(/^origin\//, '')
        if branch.match(BRANCH_REGEX)
          branches << branch
        end
      end
      if branches.size != 1
        raise Exception, "!! Cannot locate story branch."
      end
      return branches.first
    end
    
    def fetch_story
      search_story({ :current_state => "finished", :limit => 1, :offset => 0 })
    end
  end
end