module Commands::PivotalBranch
  BRANCH_REGEX = /^([a-z]+)\/([0-9]{8})-([A-Z]{2,3})-([^-]+)-([0-9]+)$/
  BRANCH_REGEX_TYPE = 1
  BRANCH_REGEX_ID = 5
  
  private

  def type_options
    if m = current_branch.match(BRANCH_REGEX)
      return options[m[BRANCH_REGEX_TYPE]] || {}
    end
    return {}
  end
    
  def story_id
    return options[:story] if options.include? :story
    if m = current_branch.match(BRANCH_REGEX)
      return m[BRANCH_REGEX_ID]
    end
  end

  def fetch_story
    unless story_id
      raise "Branch name must contain a Pivotal Tracker story id"
    end

    project.stories.find(story_id)
  end
end