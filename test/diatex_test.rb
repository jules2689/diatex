require 'test_helper'

class DiatexTest < MiniTest::Test
  def test_nothing
    inp = '# header'
    exp = '# header'
    act = Diatex.process(inp)
    assert_equal(exp, act)
  end
end
