require 'commands/pick'

module Commands
  class Chore < Pick
    def initialize(*args)
      super(:chore, *args)
    end
  end
end