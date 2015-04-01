

#################################################################################
####                           Massimo Re Ferre'                             ####
####                             www.it20.info                               ####
####         vcautils, a set of utilities for vCloud Air Consumers           ####
################################################################################# 



  
#################################################################################
####  compute.rb is the front end program that presents a CLI interface      ####
####              It leverages the compute-be.rb library                     ####
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

require 'modules/compute-be'


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
	puts "\te.g. compute ".green + "<API-URL-endpoint> <Org name>".magenta + " computetoken".green
	puts "\te.g. compute ".green + "<API-URL-endpoint> <Org name>".magenta + " catalogs".green
	puts "\te.g. compute ".green + "<API-URL-endpoint> <Org name>".magenta + " catalog".green  + " <catalog id>".magenta
	puts "\te.g. compute ".green + "<API-URL-endpoint> <Org name>".magenta + " orgvms".green
	puts "\te.g. compute ".green + "<API-URL-endpoint> <Org name>".magenta + " orgvapps".green
	puts "\te.g. compute ".green + "<API-URL-endpoint> <Org name>".magenta + " vdcs".green
	puts "\te.g. compute ".green + "<API-URL-endpoint> <Org name>".magenta + " vdc".green + " <vdc id>".magenta
	puts "\te.g. compute ".green + "<API-URL-endpoint> <Org name>".magenta + " vdc".green + " <vdc id>".magenta + " vapps".green
	puts "\te.g. compute ".green + "<API-URL-endpoint> <Org name>".magenta + " vdc".green + " <vdc id>".magenta + " networks".green
	puts "\n"

end #usage


# These are the variables the program accept as inputs (see the usage section for more info)

 

	$input0 = ARGV[0]

	$input1 = ARGV[1]

	$input2 = ARGV[2]

	$input3 = ARGV[3]

	$input4 = ARGV[4]


# The if checks if the user called an operation. If not the case, we print the text on how to use the CLI  


if $input0 && $input1 && $input2
  
# We login (the login method is in vcautilscore)  

file_path = "vcautils.yml"
raise "no file #{file_path}" unless File.exists? file_path
configuration = YAML.load_file(file_path)
username = configuration[:username]
password = configuration[:password]
mode = configuration[:mode]
computeapiendpoint = $input0
orgname = $input1
puts
puts "Logging in ...\n\n"


compute = Compute.new()

tempapiversionsarray = compute.apiversions(computeapiendpoint)
if mode == "developer" then puts JSON.pretty_generate(tempapiversionsarray) end
apiversionsarray = Array.new
tempapiversionsarray['SupportedVersions']['VersionInfo'].length.times do |i| 
																	apiversionsarray.push(tempapiversionsarray['SupportedVersions']['VersionInfo'][i]['Version'])
																  end
apiversionsarray = apiversionsarray.sort_by do |x|
    x.split(".").map {|i| i.to_i}
  end

apiversion = apiversionsarray.last

computetoken = compute.login(username, password, orgname, computeapiendpoint, apiversion)

if mode == "developer" then 
						puts 
						puts "computetoken: " + computetoken
						puts "apiversion: " + apiversion
end
 
	case $input2.chomp
     	  		    		when 'computetoken'
     	  	  	    		  	puts "To start consuming this instance right away use the following parameters: ".green
     	  	  	    		    puts " - login url              : ".green + "GET ".blue + computeapiendpoint.blue
     	  	  	    		  	puts " - x-vcloud-authorization : ".green + computetoken.blue
     	  	  	    		  	puts " - Accept                 : ".green + "application/*+xml;version=".blue + apiversion.blue
     	  	  	    		  	puts
     	  	  	    		  	puts " - Available APIs         : ".green + apiversionsarray.to_s.blue   	  	  	    		  	
     	  	  	    		  	puts     	  		    		

     	  	  	    		when 'vdcs'
     	  	  	    			vdcsarray = compute.vdcs(computetoken, computeapiendpoint, apiversion)
 								if mode == "developer" then puts JSON.pretty_generate(vdcsarray) end
     	  	  	    			vdcsarray["QueryResultRecords"]["OrgVdcRecord"].length.times do |e|     
     	  	  	    				puts "name    : ".green + vdcsarray["QueryResultRecords"]["OrgVdcRecord"][e]["name"].blue
     	  	  	    				puts "status  : ".green + vdcsarray["QueryResultRecords"]["OrgVdcRecord"][e]["status"].blue
     	  	  	    				puts "href    : ".green + vdcsarray["QueryResultRecords"]["OrgVdcRecord"][e]["href"].blue
     	  	  	    				puts "orgName : ".green + vdcsarray["QueryResultRecords"]["OrgVdcRecord"][e]["orgName"].blue
     	  	  	    				puts
     	  	  	    			end	  	  
     	  	  	    			  
     	  	  	    		when 'orgvapps' 
     	  	  	    			orgvappsarray = compute.orgvapps(computetoken, computeapiendpoint, apiversion)
 								if mode == "developer" then puts JSON.pretty_generate(orgvappsarray) end
    							if orgvappsarray["QueryResultRecords"]["VAppRecord"] == nil
	         								puts "The are no vApps in this instance".red
	         								puts
	         					else
     	  	  	    			            orgvappsarray["QueryResultRecords"]["VAppRecord"].length.times do |e|     
     	  	  	    							puts "name           : ".green + orgvappsarray["QueryResultRecords"]["VAppRecord"][e]["name"].blue
     	  	  	    							puts "href : ".green + orgvappsarray["QueryResultRecords"]["VAppRecord"][e]["href"].blue
     	  	  	    							puts "numberOfVMs    : ".green + orgvappsarray["QueryResultRecords"]["VAppRecord"][e]["numberOfVMs"].blue
     	  	  	    							puts "vdcName        : ".green + orgvappsarray["QueryResultRecords"]["VAppRecord"][e]["vdcName"].blue
     	  	  	    							puts
     	  	  	    						end	  
     	  	  	    			end 
	  	  	    		
     	  	  	    		when 'orgvms' 
     	  	  	    			orgvmsarray = compute.orgvms(computetoken, computeapiendpoint, apiversion)
 								if mode == "developer" then puts JSON.pretty_generate(orgvmsarray) end
    							if orgvmsarray["QueryResultRecords"]["VMRecord"] == nil
    								        puts "The are no vApps in this instance".red
	         								puts
	         					else
	         								puts
     	  	  	    						orgvmsarray["QueryResultRecords"]["VMRecord"].length.times do |e|     
     	  	  	    							puts "name            : ".green + orgvmsarray["QueryResultRecords"]["VMRecord"][e]["name"].blue
     	  	  	    							puts "isVAppTemplate  : ".green + orgvmsarray["QueryResultRecords"]["VMRecord"][e]["isVAppTemplate"].blue
     	  	  	    							puts "containerName   : ".green + orgvmsarray["QueryResultRecords"]["VMRecord"][e]["containerName"].blue
     	  	  	    							puts
     	  	  	    						end
     	  	  	    						puts "Please be aware that this list also contains all VM templates in all catalogs. See attribute <isVAppTemplate>.".magenta
											puts
     	  	  	    			end	
     	  	  	    			
     	  	  	    		when 'catalogs' 
     	  	  	    		   	catalogsarray = compute.catalogs(computetoken, computeapiendpoint, apiversion)
 								if mode == "developer" then puts JSON.pretty_generate(catalogsarray) end
	     	  	  	    		catalogsarray["QueryResultRecords"]["CatalogRecord"].length.times do |e|     
    	 	  	  	    				puts "name                  : ".green + catalogsarray["QueryResultRecords"]["CatalogRecord"][e]["name"].blue
     		  	  	    				puts "isPublished           : ".green + catalogsarray["QueryResultRecords"]["CatalogRecord"][e]["isPublished"].blue
     	  		  	    				puts "isShared              : ".green + catalogsarray["QueryResultRecords"]["CatalogRecord"][e]["isShared"].blue
     	  	  		    				puts "numberOfMedia         : ".green + catalogsarray["QueryResultRecords"]["CatalogRecord"][e]["numberOfMedia"].blue
     	  	  	    					puts "numberOfVAppTemplates : ".green + catalogsarray["QueryResultRecords"]["CatalogRecord"][e]["numberOfVAppTemplates"].blue
     	  	  	    					puts "href                  : ".green + catalogsarray["QueryResultRecords"]["CatalogRecord"][e]["href"].blue
     	  	  	    					puts
     	  	  	    			end # catalogsarray["QueryResultRecords"]["CatalogRecord"].length.times
     	  	  	    			
     	 					when 'catalog' 
     	  	  	    		   	if $input3 != nil 
     	  	  	    		   	catalogsarray = compute.catalogs(computetoken, computeapiendpoint, apiversion)
	         					catalogexists = false
								catalogsarray["QueryResultRecords"]["CatalogRecord"].length.times do |e|
	         						if catalogsarray["QueryResultRecords"]["CatalogRecord"][e]["name"] == $input3
	         							catalogitemsarray = compute.catalogitems(computetoken, catalogsarray["QueryResultRecords"]["CatalogRecord"][e]["href"], apiversion)
 										if mode == "developer" then puts JSON.pretty_generate(catalogitemsarray) end
	         							if catalogitemsarray["Catalog"]["CatalogItems"] == nil
	         								puts "The catalog ".red + $input3.blue + " is empty".red
	         								puts
	         							 else
	         							 catalogitemsarray["Catalog"]["CatalogItems"]["CatalogItem"].length.times do |x|
	         								puts "CatalogItem name : ".green + catalogitemsarray["Catalog"]["CatalogItems"]["CatalogItem"][x]["name"].blue
	         								puts "CatalogItem id   : ".green + catalogitemsarray["Catalog"]["CatalogItems"]["CatalogItem"][x]["id"].blue
	         								catalogitemdetails = compute.instancedetails(computetoken, "",catalogitemsarray["Catalog"]["CatalogItems"]["CatalogItem"][x]["href"], apiversion)
	         								#puts JSON.pretty_generate(catalogitemdetails)
	         								puts "         - Entity name  : ".green + catalogitemdetails["CatalogItem"]["Entity"]["name"].blue
	         								puts "         - Entity href  : ".green + catalogitemdetails["CatalogItem"]["Entity"]["href"].blue
	         								puts
	         							 end #catalogitemsarray["Catalog"]["CatalogItems"]["CatalogItem"].length.times do |x|
	         							end #if catalogitemsarray["Catalog"]["CatalogItems"] == "null"
										catalogexists = true
	         						end #if catalogsarray["QueryResultRecords"]["CatalogRecord"][e] == $input3
								end #catalogsarray["QueryResultRecords"]["CatalogRecord"].length.times
								if catalogexists == false
	         						puts "The catalog ".red + $input3.blue + " does not exist".red 
	         						puts
	         					end #if catalogexists == false
     	  	  	    		   	else #if $input3 != nil 
								puts "please provide a catalog name to query".red
								puts
     	  	  	    		   	end #if $input3 != nil 




							when 'vdc'
							    if $input3 != nil 
     	  	  	    		   	  vdcsarray = compute.vdcs(computetoken, computeapiendpoint, apiversion)
 								  if mode == "developer" then puts JSON.pretty_generate(vdcsarray) end
	         					  vdcexists = false
								  vdcsarray["QueryResultRecords"]["OrgVdcRecord"].length.times do |e|
	         					  	if vdcsarray["QueryResultRecords"]["OrgVdcRecord"][e]["name"] == $input3
	         							if $input4 == nil 
	         								#puts JSON.pretty_generate(vdcsarray)
	         								puts "status              : ".bold.green + vdcsarray["QueryResultRecords"]["OrgVdcRecord"][e]["status"].bold.blue
	         								puts "numberOfVApps       : ".bold.green + vdcsarray["QueryResultRecords"]["OrgVdcRecord"][e]["numberOfVApps"].bold.blue
	         								puts "cpuLimitMhz         : ".green + vdcsarray["QueryResultRecords"]["OrgVdcRecord"][e]["cpuLimitMhz"].blue
	         								puts "cpuUsedMhz          : ".green + vdcsarray["QueryResultRecords"]["OrgVdcRecord"][e]["cpuUsedMhz"].blue
	         								puts "memoryLimitMB       : ".green + vdcsarray["QueryResultRecords"]["OrgVdcRecord"][e]["memoryLimitMB"].blue
	         								puts "memoryUsedMB        : ".green + vdcsarray["QueryResultRecords"]["OrgVdcRecord"][e]["memoryUsedMB"].blue
	         								puts "storageLimitMB      : ".green + vdcsarray["QueryResultRecords"]["OrgVdcRecord"][e]["storageLimitMB"].blue
	         								puts "storageUsedMB       : ".green + vdcsarray["QueryResultRecords"]["OrgVdcRecord"][e]["storageUsedMB"].blue
	         								puts "pvdcHardwareVersion : ".green + vdcsarray["QueryResultRecords"]["OrgVdcRecord"][e]["pvdcHardwareVersion"].blue
	         								puts
	         							else #if $input4 == nil 
	         							case $input4.chomp	         								
	         								when 'networks'
	         									networksarray = compute.networks(computetoken, vdcsarray["QueryResultRecords"]["OrgVdcRecord"][e]["href"], apiversion)
 								  				if mode == "developer" then puts JSON.pretty_generate(networksarray) end
												networksarray["Network"].length.times do |x| 
												   		networkdetails = compute.networkdetails(computetoken, networksarray["Network"][x]["href"], apiversion)
 								  						if mode == "developer" then puts JSON.pretty_generate(networkdetails) end
												   		puts "name          : ".green + networkdetails["OrgVdcNetwork"]["name"].blue
    	 	  	  	    								puts "href          : ".green + networkdetails["OrgVdcNetwork"]["href"].blue
     	  	  	    									puts "Configuration : ".green
     	  	  	    									puts " - IpScopes : ".green
     	  	  	    									puts "   - IpScope : ".green
     	  	  	    									puts "      - Gateway : ".green + networkdetails["OrgVdcNetwork"]["Configuration"]["IpScopes"]["IpScope"]["Gateway"].blue
     	  	  	    									puts "      - Netmask : ".green + networkdetails["OrgVdcNetwork"]["Configuration"]["IpScopes"]["IpScope"]["Netmask"].blue
     	  	  	    									puts "      - IsEnabled : ".green + networkdetails["OrgVdcNetwork"]["Configuration"]["IpScopes"]["IpScope"]["IsEnabled"].blue
     	  	  	    									puts "            - IpRanges : ".green
     	  	  	    									puts "                - IpRange : ".green
     	  	  	    									if networkdetails["OrgVdcNetwork"]["Configuration"]["IpScopes"]["IpScope"]["IpRanges"]
     	  	  	    									   networkdetails["OrgVdcNetwork"]["Configuration"]["IpScopes"]["IpScope"]["IpRanges"]["IpRange"].length.times do |y|
     	  	  	    										  puts "                     - StartAddress : ".green + networkdetails["OrgVdcNetwork"]["Configuration"]["IpScopes"]["IpScope"]["IpRanges"]["IpRange"][y]["StartAddress"].blue
     	  	  	    										  puts "                     - EndAddress   : ".green + networkdetails["OrgVdcNetwork"]["Configuration"]["IpScopes"]["IpScope"]["IpRanges"]["IpRange"][y]["EndAddress"].blue
     	  	  	    									   end #networkdetails["OrgVdcNetwork"]["Configuration"]["IpScopes"]["IpScope"]["IpRanges"]["IpRange"].length do |y|
     	  	  	    									end #if networkdetails["OrgVdcNetwork"]["Configuration"]["IpScopes"]["IpScope"]["IpRanges"]
     	  	  	    									puts "   - FenceMode : ".green + networkdetails["OrgVdcNetwork"]["Configuration"]["FenceMode"].blue
     	  	  	    									puts "   - RetainNetInfoAcrossDeployments : ".green + networkdetails["OrgVdcNetwork"]["Configuration"]["RetainNetInfoAcrossDeployments"].blue
     	  	  	    									puts "IsShared : ".green + networkdetails["OrgVdcNetwork"]["IsShared"].blue
     	  	  	    									puts
     	  	  	    									puts
												end # networksarray["Network"].length.times do |x| 

	         								else #case $input4.chomp
	         								puts "The operation ".red + $input4.blue + " against the vdc is not recognized as a valid operation".red
	         							end #case $input4.chomp         								
	         							end  #if $input4 == nil 
	         							vdcexists = true
	         						end #if vdcsarray["QueryResultRecords"]["OrgVdcRecord"][e]["name"] == $input3
	         					  end #vdcsarray["QueryResultRecords"]["OrgVdcRecord"].length.times do |e|
								
								if vdcexists == false
	         						puts "The vdc ".red + $input3.blue + " does not exist".red 
	         						puts
	         					end #if vdcexists == false
     	  	  	    		   	
     	  	  	    		   	else #if $input3 != nil 
								puts "please provide a vdc name to query".red
								puts
     	  	  	    		   	end #if $input3 != nil 


     	  	  	    	else #case $input2.chomp
     	  	  	    			puts "The operation ".red + $input3.to_s + " against the instance is not recognized as a valid operation".red
     	  	  	    			puts   	    	
     	  	  	    	end #case $input2.chomp

   


# If the user did not specify an operation at all we suggest how to properly use the CLI 

else #if $input0 && $input1 && input2
  puts "\n"
  puts "You must specify the <API-URL-endpoint>, the <Org name> and a valid operation".red
  puts "e.g. https://us-virginia-1-4.vchs.vmware.com 616ge553-342d-e4-be4a-d50e5sde5283 vdcs".red
  puts "e.g. https://iaas.vcdcloud.com acme catalogs".red
  puts "\n" 
  usage()
  puts "\n" 



end #if $input0 && $input1 && input2










































