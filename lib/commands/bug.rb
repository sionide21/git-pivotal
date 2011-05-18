require 'commands/pick'

module Commands
  class Bug < Pick
    def initialize(*args)
      super(:bug, *args)
    end
  end
end