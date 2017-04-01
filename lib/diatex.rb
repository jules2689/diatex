require 'digest'
require 'net/http'
require 'cgi'
require 'json'

require 'byebug'

module Diatex
  REGEX = /
    ^(?<!<!---\n)                 # Make sure it's not a comment
    (?<declaration>
      ```(?<type>latex|diagram|mermaid)   # Match the content of latex or diagram
      \n
      (.|\n)*?                    # Non-greedy match all and new line, for actual declaration
      \n
      ```
    )
    (?!\n?--->)$                  # Make sure it's really not a comment
  /x

  IGNORED_DIRS = %w(jekyll)
  module CLI
    def self.run(*argv)
      # Make sure env is setup
      raise 'Did not provide DIATEX_PASSWORD env var' if ENV['DIATEX_PASSWORD'].nil? && argv[1] != 'local'
      # Make sure directory is provide and exists as a directory
      # raise 'Did not provide a path as an argument' if argv[0].nil?
      # raise "Path #{argv[0]} did not exist as a directory" if !File.exist?(argv[0]) || !File.directory?(argv[0])
      # Parse all markdown files in specified directory

      Dir["#{argv[0]}/**/*.md"].each do |file|
        next if IGNORED_DIRS.any? { |folder| File.dirname(file).include?(folder) }
        print(file)
        old_content = File.read(file)
        new_content = Diatex.process(old_content, local: argv[1] == 'local')
        File.write(file, new_content)
        print(" >>> Done\n")
      end
    end
  end

  class << self
    # Read each file as and replace the content specified by the REGEX
    def process(contents, local: false)
      contents.gsub(REGEX) do |match|
        r = Regexp.last_match
        # Remove the backticks and new lines
        content = match.gsub(/```\S*/, '').strip
        replacement_text(match, content, r['type'].downcase, local: local)
      end
    end

    private

    def url
      if ENV['DIATEX_URL']
        ENV['DIATEX_URL']
      elsif ENV['DEVELOPMENT']
        'http://localhost:3000'
      else
        'https://jnadeau.ca/diatex'
      end
    end

    def git_cdn_repo
      ENV.fetch("DIATEX_CDN_REPO", "jules2689/gitcdn")
    end

    def image_base_path
      ENV.fetch("DIATEX_IMAGE_BASE_PATH", "http://gitcdn.jnadeau.ca")
    end

    def latex_image_url(content)
      # Weird encodings happen if we don't escape
      # The Server also expects this escaped
      content = content.strip.gsub(/\\\[/, '').gsub(/\\\]/, '') # Strip of surrounding \[ \]
      body = { latex: CGI.escape(content.strip) }
      uri = URI("#{url}/latex")
      response = fetch_response(uri, body)
      File.join(image_base_path, response) if response
    end

    def diagram_image_url(content)
      body = { diagram: content }
      uri = URI("#{url}/diagram")
      response = fetch_response(uri, body)
      File.join(image_base_path, response) if response
    end

    def fetch_response(uri, body)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.port == 443
      request = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'application/json')
      request.basic_auth('diatex', ENV['DIATEX_PASSWORD'])
      body["github_repo"] = git_cdn_repo if body["github_repo"].nil?
      request.form_data = body
      response = http.request(request)

      unless response.code == "200"
        puts "server responded with status code #{response.code}: #{response.body}"
        return nil
      end

      # Parse the response
      parsed = JSON.parse(response.body)
      if parsed['error']
        puts parsed['error']
        puts parsed['output']
        return nil
      else
        parsed['url']
      end
    end

    def replacement_text(match, content, type, local: false)
      url = nil
      height = nil
      width = nil

      case type
      when 'latex'
        url = latex_image_url(content) unless local
        height = "75px"
      when 'diagram', 'mermaid'
        url = diagram_image_url(content) unless local
        width = "100%"
      end
      raise 'Error from upstream' if !local && (url.nil? || url == '')

      # The replacement text will be HTML commented blocks, followed by a markdown image
      image_modifiers = {
        height: height,
        width: width
      }.map { |k, v| "#{k}='#{v}'" if v }.compact.join(' ')
      [
        "\n<!---\n#{match.strip.gsub('-->', '-\->')}\n--->\n",
        "<img src='#{url}' alt='#{type} image' #{image_modifiers}>\n"
      ].join
    end
  end
end
