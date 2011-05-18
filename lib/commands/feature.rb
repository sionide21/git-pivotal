require 'commands/pick'

module Commands
  class Feature < Pick
    def initialize(*args)
      super(:feature, *args)
    end
  end
end