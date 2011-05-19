require 'commands/base'
require 'commands/pivotal_branch'

module Commands
  class PostReview < Base
    include PivotalBranch

    def run!
      super
      
      unless ['bug', 'feature'].include? story_type
        raise "You can only review bug and feature stories"
      end
      
      if get_story.current_state.downcase != 'finished'
        raise "Cannot accept a story unless it is finished."
      end
    end
  end
  
  class Accept < PostReview
    def run!
      super
      
      story = get_story
      branch = current_branch

      put "Marking Story #{story_id} as delivered..."
      if story.update(:current_state => 'delivered')
        put "Merging #{branch} back into to #{integration_branch}."
        sys "git checkout #{integration_branch}"
        sys "git merge --no-ff #{branch}", true

        return 0
      else
        raise "!! Unable to mark Story #{story_id} as delivered"
      end
    end
  end
  
  class Reject < PostReview
    def run!
      super
      
      story = get_story

      put "Rejection Reason: ", false
      comment = gets.strip

      put "Marking Story #{story_id} as rejected..."
      if story.update(:current_state => 'rejected')
        put "Commenting with rejection message..."
        story.notes.create(:text => "Rejected:\n#{comment}")
        return 0
      else
        raise "!! Unable to mark Story #{story_id} as started"
      end
    end
  end
end
