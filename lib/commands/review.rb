require 'commands/pick'

module Commands
  class Review < Base
    def run!
      response = super
      return response if response > 0
      
      puts "Retrieving latest finished stories from Pivotal Tracker"
      story = get_and_print_story "No finished stories available!"      
    end

    private
    
    def get_story
      search_story { :current_state => "finished", :limit => 1, :offset => 0 }
    end
  end
end