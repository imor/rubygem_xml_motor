# XMLMotorEngine::Exhaust

module XMLMotorEngine
  module Exhaust

    def self.content_at_node_count(node_start_index, node_stop_index,
                                  with_tag, node_at_count)
      xmlnodes = XMLMotorEngine.xmlnodes
      node = node_at_count || ""
      node += xmlnodes[node_start_index][1] unless xmlnodes[node_start_index][1].nil?
      (node_start_index + 1).upto (node_stop_index - 1) do |node_idx|
        node += inXML(xmlnodes[node_idx], node)
      end
      return tagify(xmlnodes[node_start_index][0], node) if with_tag
      node
    end

    def self.tagify(xmlnode_part, node)
      tagifyd = XMLJoiner.dejavu_node xmlnode_part
      "#{ tagifyd.first }#{ node }#{ tagifyd.last }"
    end

    def self.inXML(xmlnode, xml)
      attrib = xmlnode[0][1].nil? ? '' : XMLJoiner.dejavu_attributes(xmlnode[0][1]).to_s
      xml = "<" + xmlnode[0][0] + attrib + ">"
      xml += xmlnode[1] unless xmlnode[1].nil?
      xml
    end

    def self.tag_hash(tag_name, idx, depth, xmltag= {})
	  @open_tags ||= []
	  if tag_name.match(/^\/.*/) then
	    tag_name = tag_name[1..-1]
		unwind_limit = @open_tags.rindex tag_name
		if unwind_limit.nil?
		  #Ignore a closing tag without any opening tag
		elsif unwind_limit < @open_tags.size - 1
		  #A closing tag is found but it doesn't match the last open tag
		  while @open_tags.size >= unwind_limit + 1
		    popped_tag = @open_tags.pop
			depth -= 1
		    if popped_tag == tag_name
		      xmltag[tag_name] = push_to_tag_hash xmltag[tag_name], depth, [idx], true
		    else
		      arr = xmltag[popped_tag][depth]
			  arr.push arr[arr.size - 1]
			end
		  end
		else
		  #A closing tag matches the last open tag
		  @open_tags.pop
		  depth -= 1
		  xmltag[tag_name] = push_to_tag_hash xmltag[tag_name], depth, [idx], true
		end
	  elsif tag_name.chomp.match(/^\/$/) then
		#Why isn't depth decremented here? What is being done in this elsif block exactly?
		xmltag[tag_name] = push_to_tag_hash xmltag[tag_name], depth, [idx, idx], true
	  else
	    @open_tags.push tag_name
		xmltag[tag_name] = push_to_tag_hash xmltag[tag_name], depth, [idx], false
		depth += 1
	  end
      return xmltag, depth
    end

    def self.get_matching_open_array(xmltags_hash, depth, is_close_tag)
        if is_close_tag
            matching_array = xmltags_hash[depth]
        else
            matching_array = xmltags_hash[depth] ||= []
        end

        has_even_elements = (not matching_array.nil?) and matching_array.size % 2 == 0
        if has_even_elements
            return matching_array
        end
        cur_depth = depth - 1
        while cur_depth >= 0
            matching_array = xmltags_hash[cur_depth]
            has_even_elements = (not matching_array.nil?) and matching_array.size % 2 == 0
            if has_even_elements
                return matching_array
            end
            cur_depth = cur_depth - 1
        end
        return matching_array
    end

    #returns a hash from _key to and array of _values_
    #key is an integer
    def self.push_to_tag_hash(hash, key, values, is_close_tag)
      hash ||= {}
      matching_array = get_matching_open_array(hash, key, is_close_tag)
      values.each{|value| matching_array.push value}
      hash
    end
  end
end
