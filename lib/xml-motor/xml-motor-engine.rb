# XMLMotorEngine

xml_motor_engine = File.join(File.dirname(File.expand_path __FILE__), 'xml-motor-engine', '*.rb')
Dir.glob(xml_motor_engine).each{|parts| require parts }

module XMLMotorEngine
  def self._splitter_(xmldata)
    start_splits = xmldata.split(/</)
    @xmlnodes = [start_splits[0]]
    start_splits[1..-1].each do |val|
      tag_attr = XMLChopper.get_tag_attrib_value(val.gsub('/>','>'))
      if val.match(/\/>/)
        post_attr = tag_attr[1]
        tag_attr[1] = ''
        @xmlnodes.push tag_attr
        @xmlnodes.push [["/#{tag_attr[0][0]}", nil], post_attr]
      else
        @xmlnodes.push tag_attr
      end
    end
    @xmlnodes
  end

  def self._indexify_(_nodes=nil)
    xmlnodes _nodes unless _nodes.nil?
    @xmltags = {}
    idx = 1
    depth = 0
    @xmlnodes[1..-1].each do |xnode|
      tag_name = xnode[0][0].strip.downcase
      if tag_name.match(/^\/.*/) then
        depth -= 1
        @xmltags[tag_name[1..-1]][depth] ||= []
        @xmltags[tag_name[1..-1]][depth].push idx
      elsif tag_name.chomp.match(/^\/$/) then
        @xmltags[tag_name] ||= {}
        @xmltags[tag_name][depth] ||= []
        @xmltags[tag_name][depth].push idx
        @xmltags[tag_name][depth].push idx
      else
        @xmltags[tag_name] ||= {}
        @xmltags[tag_name][depth] ||= []
        @xmltags[tag_name][depth].push idx
        depth += 1
      end
      idx +=1
    end
    @xmltags
  end

  def self._grab_my_node_ (index_to_find, attrib_to_find=nil, with_tag=false)
    attrib = XMLMotorEngine::AirFilter.expand_attrib_to_find(attrib_to_find)
    nodes = []
    node_count = index_to_find.size/2 - 1
    0.upto node_count do |ncount|
      node_start = index_to_find[ncount*2]
      node_stop = index_to_find[ncount*2 +1]
      next if XMLMotorEngine::AirFilter.filter?(attrib,
                                                @xmlnodes[node_start][0][1])

      nodes[ncount] ||= ""
      nodes[ncount] += @xmlnodes[node_start][1] unless @xmlnodes[node_start][1].nil?
      (node_start+1).upto (node_stop-1) do |node_idx|
        nodes[ncount] += XMLMotorEngine::Exhaust.inXML(@xmlnodes[node_idx], nodes[ncount])
      end
      if with_tag
        tagifyd = XMLJoiner.dejavu_node @xmlnodes[node_start][0]
        nodes[ncount] = tagifyd.first + nodes[ncount] + tagifyd.last
      end
    end
    nodes.delete(nil) unless attrib_to_find.nil?
    nodes
  end

  def self._grab_my_attrib_ (attrib_key, index_to_find, attrib_to_find=nil)
    attrib = XMLMotorEngine::AirFilter.expand_attrib_to_find(attrib_to_find)

    attribs = []
    node_count = index_to_find.size/2 - 1
    0.upto node_count do |ncount|
      node_start = index_to_find[ncount*2]
      node_stop = index_to_find[ncount*2 +1]
      next if XMLMotorEngine::AirFilter.filter?(attrib,
                                                @xmlnodes[node_start][0][1])
      unless @xmlnodes[node_start][0][1].nil?
        attribs[ncount] = @xmlnodes[node_start][0][1][attrib_key] unless @xmlnodes[node_start][0][1][attrib_key].nil?
      end
    end
    attribs.delete(nil) unless attrib_to_find.nil?
    attribs
  end

  def self.xml_extracter(tag_to_find=nil, attrib_to_find=nil, with_tag=false, just_attrib_val=nil)
    index_to_find = []
    if attrib_to_find.nil? and tag_to_find.nil?
      return nil
    elsif tag_to_find.nil?
      index_to_find = @xmltags.collect {|xtag| xtag[1].collect {|val| val[1] }}.flatten
    else
      index_to_find = XMLIndexHandler.get_tag_indexes self, tag_to_find.downcase
    end
    if just_attrib_val.nil?
      return _grab_my_node_ index_to_find, attrib_to_find, with_tag
    else
      return _grab_my_attrib_ just_attrib_val, index_to_find, attrib_to_find
    end
  end

  def self.xml_miner(xmldata, tag_to_find=nil, attrib_to_find=nil, with_tag=false)
    return nil if xmldata.nil?
    _splitter_ xmldata
    _indexify_
    xml_extracter tag_to_find, attrib_to_find, with_tag
  end

  def self.xmlnodes(xml_nodes=nil)
    @xmlnodes = xml_nodes || @xmlnodes
  end

  def self.xmltags(xml_tags=nil)
    @xmltags = xml_tags || @xmltags
  end

  def self.pre_processed_content(_nodes, _tags=nil, tag_to_find=nil, attrib_to_find=nil, with_tag=false, just_attrib_val=nil)
    begin
      xmlnodes _nodes
      unless _tags.nil?
        xmltags _tags
      else
        _indexify_
      end
      return xml_extracter tag_to_find, attrib_to_find, with_tag, just_attrib_val
    rescue
      XMLStdout._err "Parsing processed XML Nodes."
    end
    nil
  end
end
