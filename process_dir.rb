require 'shellwords'
def processDirectoryOfSRT
  input_dir = ARGV[0]

  Dir.glob(input_dir + '/*.txt') do |text_file|
    # do work on files ending in .txt in the desired directory

    output_file = text_file.gsub('.txt','.srt')
    output_file = output_file.gsub('Transcripts','Processed_Transcripts')

    return_val = system( "/Users/mkorcy01/.rvm/rubies/ruby-2.0.0-p451/bin/ruby /Users/mkorcy01/Documents/workspace/2015/transcript_parsing/srt_to_tei/preprocess_srt.rb #{Shellwords.escape(text_file)} #{Shellwords.escape(output_file)}" )

     output_tei = output_file.gsub('Processed_Transcripts','TEI')
     output_tei = output_tei.gsub('.srt','.xml')
     return_val = system( "/Users/mkorcy01/.rvm/rubies/ruby-2.0.0-p451/bin/ruby /Users/mkorcy01/Documents/workspace/2015/transcript_parsing/srt_to_tei/convert_srt_to_tei.rb #{Shellwords.escape(output_file)} #{Shellwords.escape(output_tei)}" )

    unless return_val
    	puts "error running command: '#{output_file}'"
    end

  end #end of Dir loop

end

case ARGV.size
  when 0
    puts "invalid input. Usage: ruby process_dir [dir]"
  when 1
    processDirectoryOfSRT
  end
