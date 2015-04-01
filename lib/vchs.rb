

#################################################################################
####                           Massimo Re Ferre'                             ####
####                             www.it20.info                               ####
####         vcautils, a set of utilities for vCloud Air Consumers           ####
################################################################################# 

  
#################################################################################
####     vchs.rb is the front end program (CLI) for the vchs platform        ####
####                It leverages the vchs-be.rb library                      ####
#################################################################################


#################################################################################
####                              IMPORTANT !!                               ####
####  The program reads a file called vcautils.yml in the working directory  ####
####        If the file does not exist the program will abort                ####
####  The file is used to provide the program with connectivity parameters   ####
#################################################################################

# This is the format of the vcautils.yml file:
# :username: email@domain
# :password: password
# :serviceroot: https://vca.vmware.com
# :mode: admin | developer 

# These are the additional modules/gems required to run the program 

require 'httparty'
require 'yaml'
require 'xml-fu'
require 'pp'
require 'json'
require 'awesome_print' #optional - useful for debugging

require 'modules/vchs-be'


# We stole this piece of code (silence_warnings) from the Internet.
# We are using it to silence the warnings of the certificates settings (below)


def silence_warnings(&block)
  warn_level = $VERBOSE
  $VERBOSE = nil
  result = block.call
  $VERBOSE = warn_level
  result
end





#=begin
class String
	def black;          "\033[30m#{self}\033[0m" end
	def red;            "\033[31m#{self}\033[0m" end
	def green;          "\033[32m#{self}\033[0m" end
	def brown;          "\033[33m#{self}\033[0m" end
	def blue;           "\033[34m#{self}\033[0m" end
	def magenta;        "\033[35m#{self}\033[0m" end
	def cyan;           "\033[36m#{self}\033[0m" end
	def gray;           "\033[37m#{self}\033[0m" end
	def bg_black;       "\033[40m#{self}\033[0m" end
	def bg_red;         "\033[41m#{self}\033[0m" end
	def bg_green;       "\033[42m#{self}\033[0m" end
	def bg_brown;       "\033[43m#{self}\033[0m" end
	def bg_blue;        "\033[44m#{self}\033[0m" end
	def bg_magenta;     "\033[45m#{self}\033[0m" end
	def bg_cyan;        "\033[46m#{self}\033[0m" end
	def bg_gray;        "\033[47m#{self}\033[0m" end
	def bold;           "\033[1m#{self}\033[22m" end
	def reverse_color;  "\033[7m#{self}\033[27m" end
end #String
#=end





# This bypass certification checks...  NOT a great idea for production but ok for test / dev 

silence_warnings do
	OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
end 


# This is what the program accepts as input

def usage
	puts "\te.g. vchs services".green
	puts "\te.g. vchs service".green + " <serviceId>".magenta 
	puts "\te.g. vchs service".green + " <serviceId>".magenta + " <VDC name>".magenta 
	puts "\n"

end #usage



# These are the variables the program accept as inputs (see the usage section for more info)

	$input0 = ARGV[0]

	$input1 = ARGV[1]

	$input2 = ARGV[2]

	$input3 = ARGV[3]

	$input4 = ARGV[4]


# The if checks if the user called an operation. If not the case, we print the text on how to use the CLI  


if $input0
  
# We login (the login method is in vcautilscore)  

file_path = "vcautils.yml"
raise "no file #{file_path}" unless File.exists? file_path
configuration = YAML.load_file(file_path)
username = configuration[:username]
password = configuration[:password]
vchsserviceroot = "https://vchs.vmware.com"
mode = configuration[:mode]
vchsloginserviceroot = "https://vchs.vmware.com"
acceptheadercompute = "application/*+xml;version=5.6"

puts
puts "Logging in ...\n\n"

vchs = Vchs.new()

token = vchs.login(username, password, vchsloginserviceroot)


case $input0.chomp
   

  when 'token'  
  	  puts "OAuth token:\n".green + token

 	  
  when 'services'  
	servicesarray = vchs.services(token, vchsserviceroot)	
 	if mode == "developer" then puts JSON.pretty_generate(servicesarray) end
 	if servicesarray['Services']['Service'].any?
 		servicesarray['Services']['Service'].length.times do |i|
	  		  		puts "region       : ".green + servicesarray['Services']['Service'][i]["region"].blue
	  	  			puts "serviceId    : ".green + servicesarray['Services']['Service'][i]["serviceId"].blue
	  	  			puts "serviceType  : ".green + servicesarray['Services']['Service'][i]["serviceType"].blue
	 	 	  		puts "type         : ".green + servicesarray['Services']['Service'][i]["type"].blue
	  		  		puts "href         : ".green + servicesarray['Services']['Service'][i]["href"].blue
	  	  			puts 
					end #servicesarray['Services']['Service'].length.times do |i|
					 
	else #if servicesarray['Services']['Service'].any?
	puts
	puts "Sorry, this account doesn't have any resource associated".red
	puts 
	end #if servicesarray['Services']['Service'].any?

      
  when 'service'  
      servicesarray = vchs.services(token, vchsserviceroot)
      if $input1
       		if servicesarray['Services']['Service'].any?
       		       	serviceexists = false	
       				servicesarray["Services"]["Service"].length.times do |i|
	         			if servicesarray["Services"]["Service"][i]["serviceId"] == $input1
	         				serviceexists = true
	         				vdcssarray = vchs.vdcs(token, servicesarray["Services"]["Service"][i]["href"])
 							if mode == "developer" then puts JSON.pretty_generate(vdcssarray) end
 							puts
 							if $input2
 									vdcexists = false	
							    	vdcssarray['Compute']['VdcRef'].length.times do |i|							    		
							    		if vdcssarray['Compute']['VdcRef'][i]["name"] == $input2
							    		vdcexists = true							    		
										computeattributes = vchs.computeattributes(token, vdcssarray['Compute']['VdcRef'][i]['Link']['href'])	
										if mode == "developer" then puts JSON.pretty_generate(computeattributes) end
										puts 
										puts "href                           : ".green + computeattributes['VCloudSession']['VdcLink']["href"].blue
										puts "authorizationToken             : ".green + computeattributes['VCloudSession']['VdcLink']["authorizationToken"].blue
										puts "authorizationHeader            : ".green + computeattributes['VCloudSession']['VdcLink']["authorizationHeader"].blue
								    	puts
								    	puts "friendly API URL handoff       : ".green + computeattributes['VCloudSession']['VdcLink']["href"][0..41].blue + 'org/'.blue + vdcssarray['Compute']['VdcRef'][i]["name"].blue
								    	puts "friendly <vCD Org name> is     : ".green + vdcssarray['Compute']['VdcRef'][i]["name"].blue
								    	puts
								    	end # if vdcssarray['Compute']['VdcRef'][i]["name"] == $input2
								    end #vdcssarray['Compute']['VdcRef'].length.times do |i|
								    
								    if vdcexists == false
	      								puts
										puts "The VDC ".red + $input2.blue + " does not exist".red						
										puts	         			
									end #if vdcexists exists		

							else #if $input2
							    	vdcssarray['Compute']['VdcRef'].length.times do |i|
	  		  							puts "name    : ".green + vdcssarray['Compute']['VdcRef'][i]["name"].blue
	  	  								puts "status  : ".green + vdcssarray['Compute']['VdcRef'][i]["status"].blue
	  	  								puts "type    : ".green + vdcssarray['Compute']['VdcRef'][i]["type"].blue
	 	 	  							puts "href    : ".green + vdcssarray['Compute']['VdcRef'][i]["href"].blue
	  	  								puts 
									end #vdcssarray['Compute']['VdcRef'].length.times do |i|		
							end #if $input2
	         			end #if servicesarray["Services"]["Service"][i]["serviceId"] == $input1	         				         			
	         		end #servicesarray["Services"]["Service"].length.times do |i| 	         		
	        else #servicesarray['Services']['Service'].any?
			puts
			puts "Sorry, this account doesn't have any resource associated".red
			puts
			end #servicesarray['Services']['Service'].any?         
	         
	  else #if $input1
	  puts
	  puts "You need to specify a serviceId".red
	  puts 
	  end #if $input1
	  
	  if serviceexists == false
	      				puts
						puts "The serviceId ".red + $input1.blue + " does not exist".red						
						puts	         			
	  end #if instance exists		
	
	         
	         
       							       		  
  else #case $input0
    puts "\n" 
    puts "Noooooope!".red
    puts "\n" 
    usage()
    puts "\n" 

end #case $input0.chomp


# If the user did not specify an operation at all we suggest how to properly use the CLI 

else #if $input0
  puts "\n" 
  puts "Use any of the following operations".red
  puts "\n" 
  usage()
  puts "\n" 



end #main if










































