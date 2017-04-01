require 'test_helper'

class DiatexTest < MiniTest::Test
  def setup
    ENV['DEVELOPMENT'] = nil
    ENV["DIATEX_URL"] = nil
    ENV["DIATEX_CDN_REPO"] = nil
    ENV["DIATEX_IMAGE_BASE_PATH"] = nil
  end

  def test_latex_image_url
    VCR.use_cassette("latex_image_request") do
      ENV['DEVELOPMENT'] = "true"
      url = Diatex.send(:latex_image_url, "f(x)=5y")
      assert_equal "http://gitcdn.jnadeau.ca/images/diatex/latex/ce645fe7a0e3d8b384fd64ff7a47c9d9.png", url
    end
  end

  def test_diagram_image_url
    VCR.use_cassette("diagram_image_request") do
      ENV['DEVELOPMENT'] = "true"
      url = Diatex.send(:diagram_image_url, "f(x)=5y")
      assert_equal "http://gitcdn.jnadeau.ca/images/diatex/diagram/ce645fe7a0e3d8b384fd64ff7a47c9d9.png", url
    end
  end

  def test_latex_image_env_options
    VCR.use_cassette("latex_image_env_options") do
      ENV["DIATEX_URL"] = "https://diatex.mydomain.com"
      ENV["DIATEX_CDN_REPO"] = "myawesomeuser/gitcdn"
      ENV["DIATEX_IMAGE_BASE_PATH"] = "https://gitcdn.mydomain.com"
      url = Diatex.send(:latex_image_url, "f(x)=5y+y")
      # should only be one request
      WebMock::RequestRegistry.instance.requested_signatures.each do |request|
        assert_equal "https://diatex.mydomain.com:443/latex", request.uri.to_s
        request_params = CGI::parse(request.body)
        assert_equal ["f%28x%29%3D5y%2By"], request_params["latex"]
        assert_equal ["myawesomeuser/gitcdn"], request_params["github_repo"]
      end
      assert_equal "https://gitcdn.mydomain.com/images/diatex/latex/ce645fe7a0e3d8b384fd64ff7a47c9d9.png", url
    end
  end
end
