require 'digest'
require 'net/http'
require 'cgi'
require 'json'

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

  module CLI
    def self.run(*argv)
      # Make sure env is setup
      raise 'Did not provide DIATEX_PASSWORD env var' if ENV['DIATEX_PASSWORD'].nil? && argv[1] != 'local'
      # Make sure directory is provide and exists as a directory
      raise 'Did not provide a path as an argument' if argv[0].nil?
      raise "Path #{argv[0]} did not exist as a directory" if !File.exist?(argv[0]) || !File.directory?(argv[0])

      # Parse all markdown files in specified directory
      Dir["#{argv[0]}/**/*.md"].each do |file|
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

    def latex_image_url(content)
      # Weird encodings happen if we don't escape
      # The Server also expects this escaped
      content = content.strip.gsub(/\\\[/, '').gsub(/\\\]/, '') # Strip of surrounding \[ \]
      body = { latex: CGI.escape(content.strip) }
      uri = URI('https://jnadeau.ca/diatex/latex')
      fetch_response(uri, body)
    end

    def diagram_image_url(content)
      body = { diagram: content }
      uri = URI('https://jnadeau.ca/diatex/diagram')
      fetch_response(uri, body)
    end

    def fetch_response(uri, body)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Get.new(uri.request_uri, 'Content-Type' => 'application/json')
      request.basic_auth('diatex', ENV['DIATEX_PASSWORD'])
      request.body = body.to_json
      response = http.request(request)

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
      height = "75px"

      case type
      when 'latex'
        url = latex_image_url(content) unless local
        height = "75px"
      when 'diagram', 'mermaid'
        url = diagram_image_url(content) unless local
        height = "250px"
      end
      raise 'Error from upstream' if !local && (url.nil? || url == '')

      # The replacement text will be HTML commented blocks, followed by a markdown image
      [
        "\n<!---\n#{match.strip.gsub('-->', '-\->')}\n--->\n",
        "<img src='#{url}' alt='#{type} image' height='#{height}'>\n"
      ].join
    end
  end
end
