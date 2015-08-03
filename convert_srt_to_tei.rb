require 'srt'
require 'nokogiri'
require './template.rb'

def buildXML
	srt_file = SRT::File.parse(File.new(ARGV[0]))

	xml_file = ARGV[1]

	template = Nokogiri::XML(@template.to_xml)

	# timeline
	current_timeline_element = template.at('#timepoint_begin')
	numLines = srt_file.lines.size

	# total duration
	duration = template.at('recording')
	duration['dur'] = srt_time_to_milliseconds(srt_file.lines.last.end_time) + 'ms'

	#transcript
	transcript_div = Nokogiri::XML::Node.new("div1", template)
	transcript_div['id'] = 'transcript.1'
	transcript_div['n'] = 'Transcript'
	template.at('timeline').add_next_sibling(transcript_div).add_next_sibling("\n")

	srt_file.lines.each_with_index do |line, i|
	#	puts "add Timeline Element #{line} i: #{i}"
		current_timeline_element = addTimelineElement(template, line, current_timeline_element, i)
		addTranscriptElement(template, line, transcript_div, i)

		# add time_point end
		if i == numLines - 1
			end_timeline = Nokogiri::XML::Node.new("when", template)
			end_timeline['id'] = 'timepoint_end'
			end_timeline['since'] = 'timepoint_begin'
			end_timeline['interval'] = srt_time_to_milliseconds(line.end_time)
			current_timeline_element.add_next_sibling(end_timeline)
			current_timeline_element.add_next_sibling("\n")
		end
	end

	writeXML(template, xml_file)
end

# adds a new timeline <when /> element with
# id = timepont_INDEX, since = timepoint_begin, interval = start_time in milliseconds
# returns the added element so the next one can be concatenated onto it.
def addTimelineElement(template, line, current, index)
	time_point = Nokogiri::XML::Node.new("when", template)
	time_point['id'] = 'timepoint_' + (index + 1).to_s
	time_point['since'] = 'timepoint_begin'
 # puts "LINE #{line} END OF LINE"
	time_point['interval'] = srt_time_to_milliseconds(line.start_time)

	current.add_next_sibling(time_point)
	current.add_next_sibling("\n")

	return time_point
end


def addTranscriptElement(template, line, parentDiv, index)
	# wrapper
	transcript_point = Nokogiri::XML::Node.new("u", template)
	transcript_point['rend'] = 'transcript_chunk'
	transcript_point['start'] = 'timepoint_' + (index + 1).to_s
	transcript_point['n'] = index + 1
	transcript_point['end'] = 'timepoint_' + (index + 2).to_s

	# subtitle

	subtitle = Nokogiri::XML::Node.new("u", template)
	subtitle.content = line.text.join(" ")

	transcript_point.add_child("\n")
	transcript_point.add_child(subtitle)
	transcript_point.add_child("\n")
	parentDiv.add_child(transcript_point)

end

def writeXML(output, xml_file)
	File.open(xml_file, 'w') do |f|
		f.puts output.to_xml
	end
end


def srt_time_to_milliseconds(time)
	return ((time * 1000).floor).to_s
end

# input
case ARGV.size
when 0, 1
	puts "invalid input. Usage: ruby convert_srt_to_tei [FILE.srt] [OUTPUT_FILE.xml]"
when 2
	buildXML
end