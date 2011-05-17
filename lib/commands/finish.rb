require 'commands/base'

module Commands
  class Finish < Base

    def run!
      super

      unless story_id
        put "Branch does not appear to be a Pivotal Tracker story branch"
        return 1
      end

      put "Marking Story #{story_id} as finished..."
      if story.update(:current_state => finished_state)
        put "Merging #{current_branch} into #{integration_branch}"
        sys "git checkout #{integration_branch}"
        sys "git merge --no-ff #{current_branch}"

        return 0
      else
        put "Unable to mark Story #{story_id} as finished"

        return 1
      end
    end

  protected

    def finished_state
      if story.story_type == "chore"
        "accepted"
      else
        "finished"
      end
    end

    def story_id
      if m = current_branch.match(BRANCH_REGEX)
        return m[BRANCH_REGEX_ID]
      end
    end

    def story
      @story ||= project.stories.find(story_id)
    end

  private

    def type_options
      options[story.story_type.to_sym] || {}
    end
  end
end
