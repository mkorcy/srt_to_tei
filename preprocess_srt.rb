def buildSRT
  input_file = File.new(ARGV[0]) 
	output_file = File.new(ARGV[1], 'w')
  segment_count = 1
  segment_markers = {}
  minute_marker = 4 #default position of minutes in timestamp character array

  # two passes, first gets the markers 

  input_file.each do |line|
    if line[/^\[/]
      last_colon = line.rindex(':')
      time_stamp = line.chomp.gsub('[','').gsub(']','')
      time_stamp[last_colon - 1] = ','
      segment_markers[segment_count] = time_stamp
      segment_count +=1
    end
  end

  # the one quirk here is there is no real end point so i'm fudging one
  # by adding a minute to the last marker, this is pretty crude but need to
  # see how it works to figure out if actually needs to be refined at all.

  last_time_marker = segment_markers[segment_count - 1].dup

  if last_time_marker[minute_marker] == 9
    last_time_marker[minute_marker] = '0'
    minute_marker -=1
  end
    
  last_time_marker[minute_marker] = (last_time_marker[minute_marker].to_i + 1).to_s
  segment_markers[segment_count] = last_time_marker
  
  # reset segment count for 2nd pass
  input_file.seek 0
  segment_count = 1

  input_file.each do |line|
    if line[/^\[/]
      output_file.puts segment_count.to_s 
      output_file.puts segment_markers[segment_count] + ' --> ' + segment_markers[segment_count + 1]
      segment_count +=1
    else 
      output_file.write line 
    end
  end

  output_file.close

end

# input 
case ARGV.size
when 0, 1 
	puts "invalid input. Usage: ruby preprocess_srt [transcript.txt] [OUTPUT_FILE.srt]"
when 2
	buildSRT
end 