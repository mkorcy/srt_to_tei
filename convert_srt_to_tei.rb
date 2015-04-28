require 'srt'
require 'nokogiri'

def buildXML 
	srt_file = SRT::File.parse(File.new(ARGV[0])) 

	xml_file = ARGV[1] 

	template = Nokogiri::XML(File.open('./example.xml'))
	
	# teiHeader, can be done later... 
		# format: template.at('date')['value'] = ? 
		# template.at('title')['value'] = ? 

	# timeline
	current_timeline_element = template.at('#timepoint_begin')
	numLines = srt_file.lines.size 

	#transcript 
	transcript_div = Nokogiri::XML::Node.new("div1", template) 
	transcript_div['id'] = 'transcript.1' 
	transcript_div['n'] = 'Transcript'
	template.at('timeline').add_next_sibling(transcript_div) 


	srt_file.lines.each_with_index do |line, i| 
		current_timeline_element = addTimelineElement(template, line, current_timeline_element, i)
		addTranscriptElement(template, line, transcript_div, i)

		# add time_point end 
		if i == numLines - 1 
			end_timeline = Nokogiri::XML::Node.new("when", template)
			end_timeline['id'] = 'timepoint_end'
			end_timeline['since'] = 'timepoint_begin'
			end_timeline['interval'] = ((line.end_time * 1000).floor).to_s
			current_timeline_element.add_next_sibling(end_timeline)
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
			
	#to milliseconds, floor might cause problems, consider to_i		
	time_point['interval'] = ((line.start_time * 1000).floor).to_s

	current.add_next_sibling(time_point)

	return time_point
end 

def addTranscriptElement(template, line, parentDiv, index)
	# wrapper 
	transcript_point = Nokogiri::XML::Node.new('u', template)
	transcript_point['rend'] = 'transcript_chunk'
	transcript_point['start'] = 'timepoint_' + (index + 1).to_s 
	transcript_point['n'] = index + 1
	transcript_point['end'] = 'timepoint_' + (index + 2).to_s  

	# subtitle 

	subtitle = Nokogiri::XML::Node.new('u', template)
	subtitle.content = line.text.join(" ")

	transcript_point.add_child(subtitle)
	parentDiv.add_child(transcript_point)

end

# options here are to build the template in this function
# or to use a supplied template and edit it. 
def writeXML(output, xml_file) 
	File.open(xml_file, 'w') do |f| 
		f.puts output.to_xml
	end 
end 

# input 
case ARGV.size
when 0, 1 
	puts "invalid input. Usage: ruby convert_srt_to_tei [FILE.srt] [OUTPUT_FILE.xml]"
when 2
	buildXML	 
end 