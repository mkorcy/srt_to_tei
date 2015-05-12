require 'nokogiri'

@template = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml| 
	xml.TEI { # switch to tei.2 later
		## HEADER 
		xml.teiHeader{
			## FILE DESCRIPTION
			xml.fileDesc {
				xml.titleStmt {
					xml.title 
					xml.author
				}
				xml.extent 
				xml.publicationStmt {
					xml.distribution { 
						xml.text("Tufts Technology Services")
					}
					xml.address {
						xml.addrLine {
							xml.text("Tufts University")
						}
						xml.addrLine {
							xml.text("16 Dearborn Road")
						}
						xml.addrLine {
							xml.text("Somerville, MA, 02155")
						}
					}
					xml.idno
					xml.availability("status" => "free") {
						xml.p {
							xml.text("This publication is freely available for scholarly or educational use.")
						}
					}
				}
				xml.sourceDesc {
					xml.recordingStmt {
						# add total duration here, 
						xml.recording("type" => "audio") {
							xml.date
							xml.equipment {
								xml.p
							}
							xml.respStmt {
								xml.resp 
								xml.name
							}
						}
					}
				}
			}
			## ENCODING DESCRIPTION
			xml.encodingDesc {
				xml.editorialDecl {
					xml.stdVals {
						xml.text("Standard date values are given in ISO form: yyyy-mm-dd.")
						xml.p
					} 
				}
				xml.classDecl {
					xml.taxonomy("id" => "LCSH") {
						xml.bible {
							xml.title {
								xml.text("Library of Congress")
							}
						}
					}
				}
			}
			## PROFILE DESCRIPTION 
			xml.profileDesc {
				xml.creation {
					xml.date 
				}
				xml.langUsage {
					xml.language("id" => "EN", "usage" => "100") {
						xml.text("English.")
					}
				}
				# participant description...? 
				xml.particDesc 
			}
		}
		xml.text_ {
			xml.body {
				xml.timeline("id" => "transcript_timeline",
							 "unit" => "millisecond", 
							 "origin" => "timepoint_begin") {
					xml.when("id" 		=> "timepoint_begin", 
						     "absolute" => "beginning of recording")
				}
			}
		}

	}
end

