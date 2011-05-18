require 'commands/pick'
require 'commands/pivotal_branch'

module Commands
  class Review < Base
    def run!
      response = super
      return response if response > 0
      
      puts "Retrieving latest finished stories from Pivotal Tracker"
      story = get_and_print_story "No finished stories available!"
      
      put "Check this story out for review? [Y/n]: ", false
      unless ['y', 'yes', ''].include? gets.strip.downcase
        return 0
      end
      
      puts "Running git fetch"
      sys("git fetch")
      
      puts "Locating story branch"
      
      branch = find_story_branch(story.id)
      
      if get("git branch").each_line.any? {|b| b.sub('*','').strip == branch }
        raise "A branch for this story already exists locally:\n\t#{branch}"
      end
      
      puts "Checking out story branch for review"
      sys("git checkout --track -b #{branch} origin/#{branch}")
      
      puts "You are now in the review branch for this story."
      puts "You can see the diff with: "
      
      puts "\t'git diff #{integration_branch}...'"
      
    end

    private
    
    def find_story_branch(id)
      branches = []
      get("git branch -r | grep '^  origin/.*\\-#{id}$'").each_line do |branch|
        branch = branch.strip.sub(/^origin\//, '')
        if branch.match(PivotalBranch::BRANCH_REGEX)
          branches << branch
        end
      end
      if branches.size != 1
        raise "!! Cannot locate story branch."
      end
      return branches.first
    end
    
    def fetch_story
      search_story({ :current_state => "finished", :limit => 1, :offset => 0 })
    end
  end
end