#################################################################################
####                           Massimo Re Ferre'                             ####
####                             www.it20.info                               ####
####         vcautils, a set of utilities for vCloud Air Consumers           ####
################################################################################# 


class Iam
	include HTTParty
  	format :xml
    #debug_output $stderr
    
    
    
  def hashtoarray(structure)
  	 #this function work arounds an issue of httparty (and other REST clients apparently) that do not comply to the XML Schema correctly
  	 #in some circumstances the httparty response contains a hash whereas it should be an array of hash with one item 
  	 #this function takes input a JSON structure and check if it's a hash. If it is, it will turn it into an array of hash with one element
  	 #if the input is already an Array of hash it will do nothing
  	 #for further reference:  http://stackoverflow.com/questions/28282125/httparty-response-interpretation-in-ruby/ 
  	 structure = [structure] unless structure.is_a? Array
  	 return structure
  end #hashtoarray
  
  
    
  def login(username, password, serviceroot)
    self.class.base_uri serviceroot
  	#Avoid setting the basic_auth as (due to an httparty problem) it propagates and gets retained for other calls inside the class 
  	#self.class.basic_auth username, password
  	auth_token = Base64.encode64(username + ":" + password)
  	self.class.default_options[:headers] = {"Accept" => "application/xml;version=5.7", "Authorization" => "Basic " + auth_token}
    response = self.class.post('/api/iam/login')
    token = response.headers['vchs-authorization']
    return token
  end #login

  
   
  def users(token, serviceroot)
    self.class.base_uri serviceroot
  	#legacy type 
  	#self.class.default_options[:headers] = { "Accept" => "application/xml;class=com.vmware.vchs.iam.api.schema.v2.classes.user.Users;version=5.7", "Authorization" => "Bearer " + token }
  	self.class.default_options[:headers] = { "Accept" => "application/xml;version=*", "Authorization" => "Bearer " + token }
    usersarray = self.class.get('/api/iam/Users')
	usersarray['Users']['User'] = hashtoarray(usersarray['Users']['User'])
    usersarray['Users']['User'].length.times do |e|
    	usersarray['Users']['User'][e]["roles"]["role"] = hashtoarray(usersarray['Users']['User'][e]["roles"]["role"])
    end
	return usersarray
  end #users 


  def logout
    self.class.delete('/api/session')
  end
    
  def links
    response = self.class.get('/api/session')
    response['Session']['Link'].each do |link|
      puts link['href']
    end
  end 
 
 
end #Iam
 
 
 

class Sc
	include HTTParty
  	format :xml
  	#debug_output $stderr

  def hashtoarray(structure)
  	 #this function work arounds an issue of httparty (and other REST clients apparently) that do not comply to the XML Schema correctly
  	 #in some circumstances the httparty response contains a hash whereas it should be an array of hash with one item 
  	 #this function takes input a JSON structure and check if it's a hash. If it is, it will turn it into an array of hash with one element
  	 #if the input is already an Array of hash it will do nothing
  	 #for further reference:  http://stackoverflow.com/questions/28282125/httparty-response-interpretation-in-ruby/ 
  	 structure = [structure] unless structure.is_a? Array
  	 return structure
  end #hashtoarray
 
 
  def plans(token, serviceroot)
    self.class.base_uri serviceroot
  	self.class.default_options[:headers] = { "Accept" => "application/xml;version=5.7", "Authorization" => "Bearer " + token }
    plansarray = self.class.get('/api/sc/plans')
    return plansarray
  end #plans


  def instances(token, serviceroot)
    self.class.base_uri serviceroot
  	self.class.default_options[:headers] = { "Accept" => "application/xml;version=5.7", "Authorization" => "Bearer " + token }
    instancesarray = self.class.get('/api/sc/instances')
	instancesarray["InstanceList"]["instances"] = hashtoarray(instancesarray["InstanceList"]["instances"])
	return instancesarray
  end #instances

end #Sc




class Billing
	include HTTParty
  	format :json
  	#debug_output $stderr

  def servicegroups(token, serviceroot)
    self.class.base_uri serviceroot
  	self.class.default_options[:headers] = { "Accept" => "application/json;version=5.7", "Authorization" => "Bearer " + token }
    servicegroupsarray = self.class.get('/api/billing/service-groups')
    return servicegroupsarray 
  end #servicegroups 



def billedcosts(token, serviceroot, servicegroupid)
    self.class.base_uri serviceroot
  	self.class.default_options[:headers] = { "Accept" => "application/json;version=5.7", "Authorization" => "Bearer " + token }
    billedcostsarray = self.class.get('/api/billing/service-group/' + servicegroupid + '/billed-costs')
    return billedcostsarray
  end #billedcosts




def billedusage(token, serviceroot, servicegroupid)
    self.class.base_uri serviceroot
  	self.class.default_options[:headers] = { "Accept" => "application/json;version=5.7", "Authorization" => "Bearer " + token }
    billedusagearray = self.class.get('/api/billing/service-group/' + servicegroupid + '/billed-usage')
  end #billedusage




end #Billing 






class Metering
	include HTTParty
  	format :json
  	#debug_output $stderr


def billablecosts(token, serviceroot, servicegroupid)
    self.class.base_uri serviceroot
  	self.class.default_options[:headers] = { "Accept" => "application/json;version=5.7", "Authorization" => "Bearer " + token }
    billablecostsarray = self.class.get('/api/metering/service-group/' + servicegroupid + '/billable-costs')
    return billablecostsarray
  end #billablecosts



def billableusage(token, serviceroot, instanceid)
    self.class.base_uri serviceroot
  	self.class.default_options[:headers] = { "Accept" => "application/json;version=5.7", "Authorization" => "Bearer " + token }
    billableusagearray = self.class.get('/api/metering/service-instance/' + instanceid + '/billable-usage')
    return billableusagearray
  end #billableusage




end #Metering 




class Misc
	include HTTParty
  	format :xml
  	#debug_output $stderr
 
  def customquery(token, serviceroot, customapicall, acceptcontentspecific)
  	if acceptcontentspecific != nil 
  		acceptcontent = "application/xml" + ";class=" + acceptcontentspecific + ";version=5.7"
  	end
    self.class.base_uri serviceroot
    puts acceptcontent
  	self.class.default_options[:headers] = { "Accept" => acceptcontent, "Authorization" => "Bearer " + token }
    customresult = self.class.get(customapicall)
    return customresult
  end #customquery


  def extractendpoint(instanceattributes) 
     #I turn the string into a hash 
     attributes = JSON.parse(instanceattributes)
     #I return the orgname and sessionuri values in the hash (note that I clean the uri to only provide the FQDN)
     return attributes["orgName"], attributes["sessionUri"][0..-14]
  end #extractendpoint 




end #Misc










