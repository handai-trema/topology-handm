require 'rubygems'
require 'pio/lldp'

#
# Edges between two switches.
#
class HSlink
  attr_reader :dpid
  attr_reader :ip_address
  attr_reader :mac_address
  attr_reader :port

  def initialize(dpid, packet_in)
    data = packet_in.data
    @dpid = dpid
    @ip_address = packet_in.source_ip_address
    @mac_address = packet_in.source_mac
    @port = packet_in.in_port
  end

  # rubocop:disable AbcSize
  # rubocop:disable CyclomaticComplexity
  # rubocop:disable PerceivedComplexity
  def ==(other)
    ((@dpid == other.dpid) &&
     (@ip_address == other.ip_address) &&
     (@mac_address == other.mac_address) &&
     (@port == other.port))
  end
  # rubocop:enable AbcSize
  # rubocop:enable CyclomaticComplexity
  # rubocop:enable PerceivedComplexity

  def <=>(other)
    to_s <=> other.to_s
  end

  def to_s
    format '%#x-%#s', *([dpid, mac_address])
  end

  def connect_to?(port)
    dpid = port.dpid
    port_no = port.number
    (@dpid == dpid) && (@port == port_no)
  end
end
