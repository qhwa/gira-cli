require "http/client"
require "option_parser"
require "./gira-cli/*"

module Gira::Cli

  class Runner

    GIRA_HOME = "~/.gira"
    GIRA_HOST = "https://gira.cc"

    def initialize(args)
      if args.empty?
        print_usage
        exit
      end

      @options = OptionParser.new
      @verbose = false

      parse_options args
      check_conf
      system to_cmd(args)
    end

    def parse_options args
      @options.on("-h", "--help", "help") do
        print_usage
        exit
      end

      @options.on("-V", "--verbose", "verbose") do
        @verbose = true
      end

      @options.on("-v", "--version", "version") do
        print_version
        exit
      end

      @options.parse(args)
    end

    def print_usage
      puts "Usage: gira [--options] [...]"
      puts "options:"
      puts "  -h --help       print this help"
      puts "  -V --verbose    print debug messages"
      puts "  -v --version    print version"
    end

    def print_version
      puts "gira v#{Gira::Cli::VERSION}"
    end

    #protected :check_conf

      def check_conf
        init_confs unless already_inited?
        setup_proxy_confs unless caching?
      end

      def already_inited?
        File.directory?(gira_home)
      end

      def gira_home
        File.expand_path GIRA_HOME
      end

      def init_confs
        puts "Initing gira home" if verbose?
        Dir.mkdir_p cache_dir, 0o700
      end

      def verbose?
        @verbose
      end

      def caching?
        return false if !File.exists?(proxychains_conf_path)
        File.stat(proxychains_conf_path).atime > Time.now - 1.days
      end

      def cache_dir
        File.join gira_home, "cache"
      end

      def setup_proxy_confs
        Dir.mkdir_p File.dirname(proxychains_conf_path)

        puts "Fetching configurations from gira.cc" if verbose?
        headers = HTTP::Headers.new
        headers["X-Gira-API-Token"] = File.read(token_cache_path).chomp
        HTTP::Client.get("#{GIRA_HOST}/proxychains.conf", headers) do |res|
          if res.status_code == 200
            File.write(proxychains_conf_path, res.body_io.read)
          else
            puts "Error fetching configuration. #{res.body_io.read}"
          end
        end
      end

      def token_cache_path
        File.join gira_home, "conf", "token"
      end

      def check_api_token
      end

      def to_cmd args
        arr = [proxychains_bin]
        arr.concat args
        arr.join(" ")
      end

      def proxychains_bin
        uname = `uname -a`
        if uname =~ /Darwin/
          "proxychains4"
        else
          "proxychains"
        end
      end

      def proxychains_conf_path
        File.expand_path "~/.proxychains/proxychains.conf"
      end

  end
end

Gira::Cli::Runner.new(ARGV)
