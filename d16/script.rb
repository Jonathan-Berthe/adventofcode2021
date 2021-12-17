class Packet
  attr_reader :packet, :content, :length_of_packet, :id, :version, :total_version, :length_type_id, :value

  def initialize(bin_num)
    @packet = bin_num
    @version = version
    @id = id
    @total_version = version
    case id
    when 4
      @content = number_if_id_4
    else
      @content = []
      @length_type_id = length_type_id
      case @length_type_id
      when "0"
        length_of_sub_packets = bit_to_int(@packet[7..21])
        @length_of_packet = 22 + length_of_sub_packets # 22 = 3 + 3 + 1 + 15
        tmp = 0 
        while 22 + tmp < length_of_packet - 1
          sub_packet = Packet.new(@packet[(22 + tmp)..length_of_packet - 1])
          length_sub_packet = sub_packet.length_of_packet
          @content.push(sub_packet)
          @total_version += sub_packet.total_version
          tmp += length_sub_packet
        end
      when "1"
        number_of_sub_packets = bit_to_int(packet[7..17])
        count_sub_packets = 0
        length_sub_packets = 0
        while count_sub_packets < number_of_sub_packets
          sub_packet = Packet.new(@packet[18 + length_sub_packets..packet.length - 1])
          length_sub_packet = sub_packet.length_of_packet
          @content.push(sub_packet)
          @total_version += sub_packet.total_version
          count_sub_packets += 1
          length_sub_packets += length_sub_packet
        end
        @length_of_packet = 18 + length_sub_packets 
      else
        raise "Error"
      end
      
    end
    @packet = packet[0..length_of_packet - 1]
  end

  def version
    @version ||= bit_to_int(packet[0..2])
  end

  def id
    @id ||= bit_to_int(packet[3..5])
  end

  def length_type_id
    raise "Not an operator" if id == 4

    @length_type_id ||= packet[6]
  end

  def value
    raise "Error" if content.nil?
    
    case id
    when 0
      content.map(&:value).sum
    when 1
      content.map(&:value).inject(:*)
    when 2
      content.map(&:value).min
    when 3
      content.map(&:value).max
    when 4
      content
    when 5
      content[0].value > content[1].value ? 1 : 0
    when 6
      content[0].value < content[1].value ? 1 : 0
    when 7
      content[0].value == content[1].value ? 1 : 0
    else
      "Error"
    end
  end

  private
  def bit_to_int(bit)
    bit.to_i(2)
  end

  def number_if_id_4
    raise "Id not 4" unless id == 4

    num = ""
    index = 6
    while true
      bit = packet[index + 1..index + 4]
      num += packet[index + 1..index + 4]
      break if packet[index] == "0"
      index += 5
    end
    index += 5
    @length_of_packet = index
    bit_to_int(num)
  end

  def round_to_4_mutliple(num)
    num + 4 - num % 4
  end

end


file  = File.open("input.txt")
hexa_num = file.readlines[0].gsub("\n", '')
bin_num = hexa_num.hex.to_s(2).rjust(hexa_num.size*4, '0')
packet = Packet.new(bin_num)
p packet.total_version # PART 1
p packet.value # PART 2
