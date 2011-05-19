require 'commands/base'
require 'commands/pivotal_branch'

module Commands
  class Finish < Base
    include PivotalBranch

    def run!
      super

      story = get_story

      put "Marking Story #{story_id} as finished..."
      if story.update(:current_state => finished_state)
        put "Pushing #{current_branch} to server."
        sys "git push origin #{current_branch}"

        return 0
      else
        put "Unable to mark Story #{story_id} as finished"

        return 1
      end
    end

  protected

    def finished_state
      if get_story.story_type == "chore"
        "accepted"
      else
        "finished"
      end
    end
  end
end
