#################################################################################
####                           Massimo Re Ferre'                             ####
####                             www.it20.info                               ####
####         vcautils, a set of utilities for vCloud Air Consumers           ####
################################################################################# 



  
#################################################################################
####     vca.rb is the front end program (CLI) for the vca platform          ####
####              It leverages the vca-be.rb library                         ####
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

require 'modules/vca-be'


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
	puts "\te.g. vca token".green
	puts "\te.g. vca plans".green
	puts "\te.g. vca instances".green
	puts "\te.g. vca instance".green + " <instance id>".magenta 
	puts "\te.g. vca users".green
	puts "\te.g. vca servicegroups".green
	puts "\te.g. vca billedcosts".green
	puts "\te.g. vca billablecosts".green
	puts "\te.g. vca customquery".green + " <REST GET query>".magenta + " <ContentType>".magenta
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
serviceroot = configuration[:serviceroot]
mode = configuration[:mode]
loginserviceroot = serviceroot

puts
puts "Logging in ...\n\n"

iam = Iam.new()

sc = Sc.new()

billing = Billing.new()

metering = Metering.new()

token = iam.login(username, password, loginserviceroot)

misc = Misc.new()



case $input0.chomp
   

  when 'token'  
  	  puts "OAuth token:\n".green + "Bearer " + token


			
  when 'users'
 	 usersarray = iam.users(token, serviceroot)
 	 if mode == "developer" then puts JSON.pretty_generate(usersarray) end
	 usersarray['Users']['User'].length.times do |i|
	  	  		puts "id           : ".green + usersarray['Users']['User'][i]["id"].blue
	  	  		puts "state        : ".green + usersarray['Users']['User'][i]["state"].blue
	  	  		puts "email        : ".green + usersarray['Users']['User'][i]["email"].blue
	  	  		puts "metacreated  : ".green + usersarray['Users']['User'][i]["meta"]["created"].blue
	  	  		puts "metamodified : ".green + usersarray['Users']['User'][i]["meta"]["modified"].blue
	  	  		puts 
				end #do   	  

 	  
  when 'plans'  
	plansarray = sc.plans(token, serviceroot)	
 	if mode == "developer" then puts JSON.pretty_generate(plansarray) end
	plansarray['PlanList']['plans'].length.times do |i|
	  	  		puts "id             : ".green + plansarray['PlanList']['plans'][i]["id"].blue
	  	  		puts "name           : ".green + plansarray['PlanList']['plans'][i]["name"].blue
	  	  		puts "serviceName    : ".green + plansarray['PlanList']['plans'][i]["serviceName"].blue
	  	  		puts "region         : ".green + plansarray['PlanList']['plans'][i]["region"].blue
	  	  		puts 
				end #do 

			      
   
  when 'instances'
    instancesarray = sc.instances(token, serviceroot)
 	if mode == "developer" then puts JSON.pretty_generate(instancesarray) end
	instancesarray["InstanceList"]["instances"].length.times do |i|
	  	  		puts "name               : ".green + instancesarray["InstanceList"]["instances"][i]["name"].blue
	  	  		puts "id                 : ".green + instancesarray["InstanceList"]["instances"][i]["id"].blue
	  	  		puts "serviceGroupId     : ".green + instancesarray["InstanceList"]["instances"][i]["serviceGroupId"].blue
	  	  		puts "region             : ".green + instancesarray["InstanceList"]["instances"][i]["region"].blue
	  	  		puts "planId             : ".green + instancesarray["InstanceList"]["instances"][i]["planId"].blue
	  	  		puts "apiUrl             : ".green + instancesarray["InstanceList"]["instances"][i]["apiUrl"].blue
	  	  		puts "dashboardUrl       : ".green + instancesarray["InstanceList"]["instances"][i]["dashboardUrl"].blue
	  	  		puts "instanceAttributes : ".green + instancesarray["InstanceList"]["instances"][i]["instanceAttributes"].blue
	  	  		puts 
				end #do 
   
   
  
  when 'instance'  
      instancesarray = sc.instances(token, serviceroot)
      plansarray = sc.plans(token, serviceroot)
      if $input1
       instanceexists = false	
       instancesarray["InstanceList"]["instances"].length.times do |i|
	         if instancesarray["InstanceList"]["instances"][i]["id"] == $input1	         		
	                plan = instancesarray["InstanceList"]["instances"][i]["planId"]
	         		plansarray['PlanList']['plans'].length.times do |x|
	         		  if plansarray['PlanList']['plans'][x]['id'] == plan 	         		
	         		  case plan.chomp
	         		  
	    				#Subscription Service     		
	         			when "region:PMP:planID:be817b3c-c762-45c4-9915-f956dc67ba82" 
	         		       	puts "Sorry the instance ".red + $input1 + " refers to a Subscription instance. This tool doesn't support Subscription instances".red 
			 				puts
			 				
	    				#OnDemand (and DR on OnDemand)     					 							 					 			
			 			when "region:us-virginia-1-12.vchs.vmware.com:planID:67538ff0-f4c3-48cb-8a6f-b0a3ac5aa324",
			 				 "region:au-south-1-15.vchs.vmware.com:planID:c65d5821-aa97-4141-915a-7d7eab0a9d51",
			 				 "region:de-germany-1-16.vchs.vmware.com:planID:c65d5821-aa97-4141-915a-7d7eab0a9d51",
			 				 "region:uk-slough-1-6.vchs.vmware.com:planID:c65d5821-aa97-4141-915a-7d7eab0a9d51",
			 				 "region:us-california-1-3.vchs.vmware.com:planID:c65d5821-aa97-4141-915a-7d7eab0a9d51",
			 				 "region:us-virginia-1-4.vchs.vmware.com:planID:c65d5821-aa97-4141-915a-7d7eab0a9d51"
			 		 		orgname, sessionuri = misc.extractendpoint(instancesarray["InstanceList"]["instances"][i]["instanceAttributes"])
     	  	  	    		if mode == "developer" then puts instancesarray["InstanceList"]["instances"][i]["instanceAttributes"] end
     	  	  	    		if mode == "developer" then puts "orgname, sessionuri = " + orgname.to_s + ", " + sessionuri.to_s end  	  	    	
     	  	  	    		#right now I am not using the apiUrl 
     	  	  	    		#ideally that should be the starting point 
     	  	  	    		#however to speed up things I am using sessionuri + the specific (packaged) query I need directly
     	  	  	    		apiUrl = instancesarray["InstanceList"]["instances"][i]["apiUrl"]
     	  	  	    		#puts "The API URL for this service is : ".bold.green + apiUrl.bold.blue
     	  	  	    		puts "The session URL for this instance is             : ".bold.green + sessionuri.bold.blue
     	  	  	    		puts "The friendly <vCD Org name> for this instance is : ".bold.green + orgname.bold.blue
     	  	  	    		puts	
   	  	  	    				 
	    				#Object Storage powered by EMC ViPR			 				
			 			when "region:us-california-1-3.vchs.vmware.com:planID:os.vca.vmware.4562.6481"
			 				puts "Oooohhhh ".red + $input1 + " is an Object Storage Instance powered by ViPR.... <under construction>".red 
			 				puts
			 				
     				    #when
			 			#########
			 			# New service types will have to be inserted here (e.g. DBaaS)
			 			#########
  
			 			
			 		  end #case plan.chomp 
			 		end #if plansarray['PlanList']['plans'][x]['id'] == plan 	
			 		end #plansarray['PlanList']['plans'].length.times do |x|
	         
     	  	   	 
     	  	  	   instanceexists = true 
     	     end #if instancesarray["InstanceList"]["instances"][i]["id"] == $input1
	   end #instancesarray["InstanceList"]["instances"].length.times do
	   if instanceexists == false
    	     puts "Sorry the instance ".red + $input1 + " doesn't exist".red 
			 puts
	   end #if instance exists
	  else #if $input1
	   puts "You need to specify an instance".red
	   puts
    end #if $input1
   
   
   

  when 'servicegroups'
    servicegroupsarray = billing.servicegroups(token, serviceroot)
    if mode == "developer" then puts JSON.pretty_generate(servicegroupsarray) end
	servicegroupsarray["serviceGroupList"]["serviceGroup"].length.times do |i|
				puts
	  	  		puts "id              : ".green + servicegroupsarray["serviceGroupList"]["serviceGroup"][i]["id"].blue
	  	  		puts "displayName     : ".green + servicegroupsarray["serviceGroupList"]["serviceGroup"][i]["displayName"].blue
	  	  		puts "billingCurrency : ".green + servicegroupsarray["serviceGroupList"]["serviceGroup"][i]["billingCurrency"].blue
	  	  		puts "availableBills  : ".green 
	  	  		puts "       - bill:".green
				servicegroupsarray["serviceGroupList"]["serviceGroup"][i]["availableBills"]["bill"].length.times do |e|
						puts "              - billingPeriod:".green
						puts "                - month     :".green + servicegroupsarray["serviceGroupList"]["serviceGroup"][i]["availableBills"]["bill"][e]["billingPeriod"]["month"].to_s.blue
						puts "                - year      :".green + servicegroupsarray["serviceGroupList"]["serviceGroup"][i]["availableBills"]["bill"][e]["billingPeriod"]["year"].to_s.blue
						puts "                - sartDate  :".green + servicegroupsarray["serviceGroupList"]["serviceGroup"][i]["availableBills"]["bill"][e]["billingPeriod"]["startDate"].blue
						puts "                - endDate   :".green + servicegroupsarray["serviceGroupList"]["serviceGroup"][i]["availableBills"]["bill"][e]["billingPeriod"]["endDate"].blue
						puts				
				end #do e	
				puts
				puts
	end #do i 
 
 
 
 
 
 
 
   when 'billedcosts'
   	if $input1
   	servicegroupexists = false	
       servicegroupsarray.length.times do |i|
	         if servicegroupsarray["serviceGroupList"]["serviceGroup"][i]["id"] == $input1
	  	  	    		billedcostsarray = billing.billedcosts(token, serviceroot, servicegroupsarray["serviceGroupList"]["serviceGroup"][i]["id"])
						if billedcostsarray["status"] 
							puts "Sorry, there is no billing yet for this servicegroup".red
							puts 			
						else
							#I need to convert cost to string as if it's nil it will complain
    						puts "cost        : " +  billedcostsarray["cost"].to_s
    						puts "currency    : " +  billedcostsarray["currency"]
    						puts "month       : " +  billedcostsarray["month"].to_s
    						puts "year        : " +  billedcostsarray["year"].to_s
    				    	puts "startTime   : " +  billedcostsarray["startTime"]
    				    	puts "endTime     : " +  billedcostsarray["endTime"]
    						#puts JSON.pretty_generate(billedcostsarray)
	  	  	    			#servicegrouparray.length.times do |i|
							#end #do
						end		
     	  	  	    	servicegroupexists = true 
     	     end #servicegroup check 
	   end #do
	   if servicegroupexists == false
    	     puts "Sorry the servicegroup ".red + $input1 + " doesn't exist".red 
			 puts
	   end #if servicegroup exists    
    end #main if







##### TO BE TESTED #####
   when 'billedusage'
   	if $input1
   	servicegroupexists = false	
       servicegroupsarray["serviceGroupList"]["serviceGroup"].length.times do |i|
	         if servicegroupsarray["serviceGroupList"]["serviceGroup"][i]["id"] == $input1
	  	  	    		billedusagearray = billing.billedusage(token, serviceroot, servicegroupsarray["serviceGroupList"]["serviceGroup"][i]["id"])
	  	  	    		#servicegrouparray.length.times do |i|
						#end #do		
     	  	  	    	servicegroupexists = true 
     	     end #servicegroup check 
	   end #do
	   if servicegroupexists == false
    	     puts "Sorry the servicegroup ".red + $input1 + " doesn't exist".red 
			 puts
	   end #if servicegroup exists    
    end #main if







   when 'billablecosts'
   	if $input1
   	servicegroupexists = false	
       servicegroupsarray["serviceGroupList"]["serviceGroup"].length.times do |i| 
	         if servicegroupsarray["serviceGroupList"]["serviceGroup"][i]["id"] == $input1
	  	  	    		billablecostsarray = metering.billablecosts(token, serviceroot, servicegroupsarray["serviceGroupList"]["serviceGroup"][i]["id"])
	  	  	    		puts "currency       : " + billablecostsarray["currency"]
	  	  	    		puts "lastUpdateTime : " + billablecostsarray["lastUpdateTime"]
	  	  	    		billablecostsarray["cost"].length.times do |e|
	  	  	    				puts "    - type     : " + billablecostsarray["cost"][e]["type"]
	  	  	    				puts "    - costItem : "
	  	  	    				billablecostsarray["cost"][e]["costItem"].length.times do |n|
	  	  	    						puts "         - properties : "
	  	  	    						puts "               - property : "
	  	  	    						billablecostsarray["cost"][e]["costItem"][n]["properties"]["property"].length.times do |m|
	  	  	    								puts "                       - value : " + billablecostsarray["cost"][e]["costItem"][n]["properties"]["property"][m]["value"]
	  	  	    								puts "                       - name  : " + billablecostsarray["cost"][e]["costItem"][n]["properties"]["property"][m]["name"]
										end #do
								end #do
	  	  	    				puts
	  	  	    				puts
						end #do		
     	  	  	servicegroupexists = true 
     	     end #servicegroup check 
	   end #do
	   if servicegroupexists == false
    	     puts "Sorry the servicegroup ".red + $input1 + " doesn't exist".red 
			 puts
	   end #if servicegroup exists    
    end #main if





 ##### TO BE TESTED   ########
  when 'billableusage'
   	if $input1
   	instanceexists = false	
       instancesarray.length.times do |i|
	         if instancesarray[i]["Id"] == $input1
	  	  	    		billableusagearray = metering.billableusage(token, serviceroot, instancesarray[i]["Id"])
	  	  	    		puts "currency       : " + billablecostsarray["currency"]
	  	  	    		puts "lastUpdateTime : " + billablecostsarray["lastUpdateTime"]
	  	  	    		billablecostsarray["cost"].length.times do |e|
	  	  	    				puts "    - type     : " + billablecostsarray["cost"][e]["type"]
	  	  	    				puts "    - costItem : "
	  	  	    				billablecostsarray["cost"][e]["costItem"].length.times do |n|
	  	  	    						puts "         - properties : "
	  	  	    						puts "               - property : "
	  	  	    						billablecostsarray["cost"][e]["costItem"][n]["properties"]["property"].length.times do |m|
	  	  	    								puts "                       - value : " + billablecostsarray["cost"][e]["costItem"][n]["properties"]["property"][m]["value"]
	  	  	    								puts "                       - name  : " + billablecostsarray["cost"][e]["costItem"][n]["properties"]["property"][m]["name"]
										end #do
								end #do
	  	  	    				puts
	  	  	    				puts
						end #do		
     	instanceexists = true 
     	end #instance check 
	   end #do
	   if instanceexists == false
    	     puts "Sorry the instance ".red + $input1 + " doesn't exist".red 
			 puts
	   end #if servicegroup exists    
    end #main if




 ##### This allows for free form REST queries   ########
  when 'custom'
   	if $input1
		customresult = misc.customquery(token, serviceroot, $input1, $input2)
		puts JSON.pretty_generate(customresult)
	else
		puts "Please provide a valid API call path (with proper Content Type) to run a GET against https://vca.vmware.com".green
		puts "Example: /api/iam/Users".green
		puts 
    end #main if



       							       		  
else #case $input0
  puts "\n" 
  puts "Noooooope!".red
  puts "\n" 
  usage()
  puts "\n" 
  
end 


# If the user did not specify an operation at all we suggest how to properly use the CLI 

else #if $input0
  puts "\n" 
  puts "Use any of the following operations".red
  puts "\n" 
  usage()
  puts "\n" 



end #main if










































