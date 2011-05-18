require 'commands/base'
require 'commands/pivotal_branch'

module Commands
  class Info < Base
    include PivotalBranch

    def run!
      super

      story = get_story

      put "Story:         #{story.name}"
      put "URL:           #{story.url}"
      put "Created:       #{story.created_at.strftime '%B %d, %Y'}"
      put "State:         #{story.current_state.capitalize}"
      put "Estimate:      #{story.estimate}"
      put "Description:   #{story.description}"

      return 0
    end
  end
end
