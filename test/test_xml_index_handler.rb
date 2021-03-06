#!/usr/bin/env ruby

require 'test/unit'
require_relative '../lib/xml-motor.rb'

class TestXMLIndexHandler < Test::Unit::TestCase
  def setup
    @content = <<-xmldata
	<dummy>
	 <mmy> <y id='3'> <z>300</z> </y> <y>5</y> <z>500</z> </mmy>
	</dummy>
       xmldata
    XMLMotorEngine._splitter_ @content
    XMLMotorEngine._indexify_ XMLMotorEngine.xmlnodes
  end
  def teardown
    XMLMotorEngine.instance_variable_set "@xmlnodes", nil
    XMLMotorEngine.instance_variable_set "@xmltags", nil
  end

  def test_get_tag_indexes
    assert_equal XMLIndexHandler.get_tag_indexes("dummy"), [1, 12]
    assert_equal XMLIndexHandler.get_tag_indexes("mmy"), [2, 11]
    assert_equal XMLIndexHandler.get_tag_indexes("y"), [3, 6, 7, 8]
    assert_equal XMLIndexHandler.get_tag_indexes("z"), [4, 5, 9, 10]
    assert_equal XMLIndexHandler.get_tag_indexes("not_exists"), []
    assert_equal XMLIndexHandler.get_tag_indexes("dummy/mmy"), [2, 11]
    assert_equal XMLIndexHandler.get_tag_indexes("dummy/mmy/y"), [3, 6, 7, 8]
    assert_equal XMLIndexHandler.get_tag_indexes("dummy/mmy/y/z"), [4, 5]
    assert_equal XMLIndexHandler.get_tag_indexes("dummy/not_exists"), []
    assert_equal XMLIndexHandler.get_tag_indexes("not_exists/dummy"), []
    assert_equal XMLIndexHandler.get_tag_indexes("dummy/not_exists/z"), []
  end

  def test_expand_node_indexes
    xtags = XMLMotorEngine.xmltags
    assert_equal XMLIndexHandler.expand_node_indexes(xtags["dummy"][0], xtags["mmy"][1]),  xtags["mmy"][1]
    assert_equal XMLIndexHandler.expand_node_indexes(xtags["dummy"][0], xtags["y"][2]),  xtags["y"][2]
    assert_equal XMLIndexHandler.expand_node_indexes(xtags["dummy"][0], xtags["z"][3]),  xtags["z"][3]
    assert_equal XMLIndexHandler.expand_node_indexes(xtags["mmy"][1], xtags["y"][2]),  xtags["y"][2]
    assert_equal XMLIndexHandler.expand_node_indexes(xtags["mmy"][1], xtags["z"][3]),  xtags["z"][3]
    assert_equal XMLIndexHandler.expand_node_indexes(xtags["y"][2], xtags["z"][3]),  xtags["z"][3]
  end
end
