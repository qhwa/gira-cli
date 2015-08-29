require "http/client"
require "./gira-cli/*"

module Gira::Cli

  class Runner

    GIRA_HOME = "~/.gira"
    GIRA_HOST = "https://gira.cc"
    #GIRA_HOME = "./template"
    #GIRA_HOST = "http://127.0.0.1:3000"

    def initialize(args)
      check_conf
      system to_cmd(args)
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
        puts "Initing gira home"
        Dir.mkdir_p cache_dir, 0o700
      end

      def caching?
        return false if !File.exists?(proxychains_conf_path)
        File.stat(proxychains_conf_path).atime > Time.now - 1.days
      end

      def cache_dir
        File.join gira_home, "cache"
      end

      def setup_proxy_confs
        puts "Fetching configurations from gira.cc"
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
        arr = ["proxychains4", "-f", proxychains_conf_path]
        arr.concat args
        arr.join(" ")
      end

      def proxychains_conf_path
        File.join gira_home, "conf/proxychains.conf"
      end

  end
end

Gira::Cli::Runner.new(ARGV)
