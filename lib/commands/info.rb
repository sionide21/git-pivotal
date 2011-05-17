require 'commands/base'

module Commands
  class Info < Base

    def run!
      super

      unless story_id
        put "Branch name must contain a Pivotal Tracker story id"
        return 1
      end

      put "Story:         #{story.name}"
      put "URL:           #{story.url}"
      put "Description:   #{story.description}"

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
  end
end
