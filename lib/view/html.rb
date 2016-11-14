require 'json'
#pushnode(i,"HOST",false,node)
#pushnode(i,"EDGE",true,node)
#pushedge(i-1,i%11,edge)
module View
  # Topology controller's GUI (graphviz).
  class Html
    def initialize(output = 'topology.html')
      @nodes=[]
      @edges=[]
      @output = output
    end

    # rubocop:disable AbcSize
    def update(_event, _changed, topology)
      @nodes=[]
      topology.switches.each_with_object({}) do |each,tmp|
	pushnode(each,false) 
      end
      topology.hosts.each_with_object([]) do |each|
	pushnode(each.to_s,true)
      end 
 
      topology.links.each do |each|
	pushedge(each.dpid_a,each.dpid_b)
      end
      topology.hslinks.each do |each|
	pushedge(each.mac_address.to_s,each.dpid)
      end
      @edges = @edges.uniq
      output()
    end
  private
  def output()
    base =File.read("./lib/view/create_vis_base.txt")
    base2 =File.read("./lib/view/create_vis_base2.txt")
    result= base+JSON.generate(@nodes)+";\n edges ="+JSON.generate(@edges)+base2
    File.write(@output, result)
  end
  def pushnode(id,ishost)
    if ishost then
      @nodes.push({id:id,label:id,image:"./lib/view/laptop.png",shape:'image'}) 
    else
      @nodes.push({id:id,label:id.to_hex,image:"./lib/view/switch.png",shape:"image"})
    end
  end
  def pushedge(from,to)
    @edges.push({from:from,to:to})
  end
  end
end
=begin
      GraphViz.new(:G, use: 'neato', overlap: false, splines: true) do |gviz|
        nodes = topology.switches.each_with_object({}) do |each, tmp|
          tmp[each] = gviz.add_nodes(each.to_hex, shape: 'box')
        end
        topology.links.each do |each|
          next unless nodes[each.dpid_a] && nodes[each.dpid_b]
          gviz.add_edges nodes[each.dpid_a], nodes[each.dpid_b]
        end
        hosts = topology.hosts.each_with_object([]) do |each|
          gviz.add_nodes(each.to_s, shape: 'box')
        end
        topology.hslinks.each do |each|
          gviz.add_edges each.mac_address.to_s, each.dpid.to_hex
        end
        gviz.output png: @output
      end
    end
    # rubocop:enable AbcSize
    def to_s
      "Graphviz mode, output = #{@output}"
    end
  end
end

=end
