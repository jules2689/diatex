require 'test_helper'

class DiatexTest < MiniTest::Test
  def test_latex_image_url
    ENV['DEVELOPMENT'] = "true"
    VCR.use_cassette("latex_image_request") do
      url = Diatex.send(:latex_image_url, "f(x)=5y")
      assert_equal "http://gitcdn.jnadeau.ca/images/diatex/latex/ce645fe7a0e3d8b384fd64ff7a47c9d9.png", url
      byebug
    end
  end

  # WebMock::RequestRegistry.instance.requested_signatures.each { |a| puts a.uri }

  def test_latex_image_url_request_parameters
  end
end
