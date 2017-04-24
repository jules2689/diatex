require 'tempfile'
require 'charts'
require "RMagick"
require 'octokit'

module Diatex
  REGEX = /
    ^(?<!<!---\n)                         # Make sure it's not a comment
    (?<declaration>
      ```(?<type>latex|diagram|mermaid)   # Match the content of latex or diagram
      \n
      (.|\n)*?                            # Non-greedy match all and new line, for actual declaration
      \n
      ```
    )
    (?!\n?--->)$                          # Make sure it's really not a comment
  /x

  CONFIG = {
    github_token: ENV['GITHUB_ACCESS_TOKEN'],
    github_repo: ENV['GITHUB_REPO'],
    git_repo_url: ENV['GIT_REPO_URL']
  }.freeze

  module CLI
    def self.run(*argv)
      # Make sure env is setup
      nil_keys = CONFIG.keys.select { |k| CONFIG[k].nil? }
      raise "#{nil_keys.join(',')} are not set as env vars" unless nil_keys.empty?
      raise 'Did not provide a path as an argument' if argv[0].nil?
      raise "Path #{argv[0]} did not exist as a directory" if !File.exist?(argv[0]) || !File.directory?(argv[0])

      # Parse all markdown files in specified directory
      Dir["#{argv[0]}/**/*.md"].each do |file|
        print(file)
        old_content = File.read(file)
        new_content = Diatex.process(old_content)
        File.write(file, new_content)
        print(" >>> Done\n")
      end
    end
  end

  class << self
    # Read each file as and replace the content specified by the REGEX
    def process(contents)
      contents.gsub(REGEX) do |match|
        r = Regexp.last_match
        # Remove the backticks and new lines
        content = match.gsub(/```\S*/, '').strip
        replacement_text(match, content, r['type'].downcase)
      end
    end

    private

    def replacement_text(match, content, type)
      url = nil
      height = nil
      width = nil

      case type
      when 'latex'
        raise 'not supported'
      when 'diagram', 'mermaid'
        url = diagram_image_url(content)
        width = "100%"
      end
      raise 'Error from upstream' if (url.nil? || url == '')

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

    def diagram_image_url(content)
      svg_string = nil
      file = Tempfile.new('svg_string')
      begin
        Charts.render_chart(content, file.path + ".svg")
        svg_string = File.read(file.path + ".svg")
      ensure
         file.close
         file.unlink   # deletes the temp file
      end

      url = nil
      file = Tempfile.new('svg_string')
      begin
        img = Magick::Image.from_blob(svg_string) do
          self.format = 'SVG'
          self.background_color = 'transparent'
        end
        image = img.first.to_blob do
          self.format = 'PNG'
        end
        File.write(file.path + ".png", image)
        url = upload_image(file.path + ".png")
      ensure
         file.close
         file.unlink   # deletes the temp file
      end
      url
    end

    def upload_image(file_path)
      path = "images/website/#{File.basename(file_path)}"
      github.create_contents(
        CONFIG[:github_repo],
        path,
        "Adding Image #{path}",
        branch: "gh-pages",
        file: file_path
      )
      CONFIG[:git_repo_url] + path
    end

    def github
      @github ||= Octokit::Client.new(access_token: CONFIG[:github_token]) 
    end
  end
end
