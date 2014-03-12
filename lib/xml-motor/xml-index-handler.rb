module XMLIndexHandler
  def self.get_tag_indexes(tagPath)
    begin
	  tag, predicate = _get_tag_and_predicate_ tagPath.split("/")[0]
	  xml_idx_to_find = XMLMotorEngine.xmltags[tag].values
      xml_idx_to_find = xml_idx_to_find.flatten
	  if not predicate.nil?
		xml_idx_to_find = xml_idx_to_find[(2 * (predicate.to_i - 1))..-1]
	  end

      traverse_tag xml_idx_to_find, tagPath
    rescue
      XMLStdout._err "Finding index for tagPath:#{tagPath}.\nLook if it's actually present in the provided XML."
      return []
    end
  end

  def self.traverse_tag(xml_idx_to_find, tagPath)
    tagPath.split('/')[1..-1].each do |tag_i|
	  tag, predicate = _get_tag_and_predicate_ tag_i
      x_curr = XMLMotorEngine.xmltags[tag].values.flatten
	  if not predicate.nil?
		x_curr = x_curr[(2 * (predicate.to_i - 1))..-1]
	  end
      xml_idx_to_find = expand_node_indexes xml_idx_to_find, x_curr
    end
    xml_idx_to_find
  end

  def self.expand_node_indexes(outer_idx, x_curr)
    expanded_node_indexes = []
    (0...outer_idx.size).step(2) do |o|
      o1, o2 = outer_idx[o], outer_idx[o + 1]
      expanded_node_indexes += node_indexes_in_range(x_curr, o1, o2)
    end
    expanded_node_indexes.flatten
  end

  def self.node_indexes_in_range(x_curr, outer_open, outer_close)
    node_indexes = []
    (0...x_curr.size).step(2) do |x|
      x1, x2 = x_curr[x], x_curr[x + 1]
      next if node_index_out_of_bound?(outer_open, outer_close, x1, x2)
      node_indexes.push x1, x2
    end
    node_indexes
  end

  def self.node_index_out_of_bound?(outer_min, outer_max, curr_min, curr_max)
    outer_min > curr_min || outer_max < curr_max
  end

  def self._get_tag_and_predicate_(tag)
    startIndex = tag.index("[")
	endIndex = tag.index("]")
	if startIndex.nil? or endIndex.nil?
	  return tag, nil
	end
	return tag[0..startIndex-1], tag[(startIndex + 1)..(endIndex - 1)]
  end
end
