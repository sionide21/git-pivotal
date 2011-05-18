require 'rubygems'
require 'pivotal-tracker'
require 'optparse'

module Commands
  
  class NoSuchStory < Exception
  end
  
  class Base

    attr_accessor :input, :output, :options

    def initialize(input=STDIN, output=STDOUT, *args)
      @input = input
      @output = output
      @options = {}

      parse_gitconfig
      parse_argv(*args)
    end

    def put(string, newline=true)
      @output.print(newline ? string + "\n" : string) unless options[:quiet]
    end

    def sys(cmd)
      put cmd if options[:verbose]
      system "#{cmd} > /dev/null 2>&1"
    end

    def get(cmd)
      put cmd if options[:verbose]
      `#{cmd}`
    end

    def run!
      unless options[:api_token] && options[:project_id]
        put "Pivotal Tracker API Token and Project ID are required"
        return 1
      end

      PivotalTracker::Client.token = options[:api_token]
      PivotalTracker::Client.use_ssl = options[:use_ssl] || false
      

      return 0
    end

  protected

    def current_branch
      @current_branch ||= get('git symbolic-ref HEAD').sub('refs/heads/', '').strip
    end

    def project
      @project ||= PivotalTracker::Project.find(options[:project_id])
    end
    
    def integration_branch
      @integration_branch || type_options[:integration_branch] || "develop"
    end
  
    def get_and_print_story(error_msg)
      story = get_story

      put "Story: #{story.name}"
      put "URL:   #{story.url}"
      
      return story
    end
    
    def get_story
      return @story if @story
      @story = fetch_story
      raise NoSuchStory, error_msg unless @story
      return @story
    end
    
    def search_story(conditions)
      if options.include? :story
        return project.stories.find(options[:story])
      end
      return project.stories.all(conditions).first
    end
    
    private

    BOOL_OPTS = [:use_ssl, :only_mine, :append_name]
    def parse_gitconfig
      get("git config --list").each_line do |line|
        opt_section = options
        line = line.strip
        key, value = line.split '='
        next unless key.match(/^pivotal\.(.*)$/)
        key = $1.gsub('-','_')
        # Handle Sections
        if key.include? '.'
          sections = key.split '.'
          key = sections.pop
          sections.each do |section|
            opt_section[section.to_sym] ||= {}
            opt_section = opt_section[section.to_sym]
          end
        end
        
        key = key.to_sym
        if BOOL_OPTS.include? key
          value = value == 'true'
        end
        opt_section[key] = value
      end
    end

    def parse_argv(*args)
      OptionParser.new do |opts|
        opts.banner = "Usage: git pick [options]"
        opts.on("-s", "--story=", "Specify the story to use") { |s| options[:story] = s }
        opts.on("-k", "--api-key=", "Pivotal Tracker API key") { |k| options[:api_token] = k }
        opts.on("-p", "--project-id=", "Pivotal Trakcer project id") { |p| options[:project_id] = p }
        opts.on("-n", "--full-name=", "Pivotal Trakcer full name") { |n| options[:full_name] = n }
        opts.on("-b", "--integration-branch=", "The branch to merge finished stories back down onto") { |b| @integration_branch = b }
        opts.on("-m", "--only-mine", "Only select Pivotal Tracker stories assigned to you") { |m| options[:only_mine] = m }
        opts.on("-D", "--defaults", "Accept default options. No-interaction mode") { |d| options[:defaults] = d }
        opts.on("-q", "--quiet", "Quiet, no-interaction mode") { |q| options[:quiet] = q }
        opts.on("-v", "--[no-]verbose", "Run verbosely") { |v| options[:verbose] = v }
        opts.on_tail("-h", "--help", "This usage guide") { put opts.to_s; exit 0 }
      end.parse!(args)
    end

  end
end
