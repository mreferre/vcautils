#################################################################################
####                           Massimo Re Ferre'                             ####
####                             www.it20.info                               ####
####         vcautils, a set of utilities for vCloud Air Consumers           ####
################################################################################# 

class Vchs 
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
  

  def login(username, password, subscriptionserviceroot)
    self.class.base_uri subscriptionserviceroot
  	#Avoid setting the basic_auth as (due to an httparty problem) it propagates and gets retained for other calls inside the class 
  	#self.class.basic_auth username, password
  	auth_token = Base64.encode64(username + ":" + password)
  	self.class.default_options[:headers] = {"Accept" => "application/xml;version=5.6", "Authorization" => "Basic " + auth_token}
    response = self.class.post('/api/vchs/sessions')
    token = response.headers['x-vchs-authorization']
    return token
  end #login


  def services(token, subscriptionserviceroot)
    self.class.base_uri subscriptionserviceroot
  	self.class.default_options[:headers] = { "Accept" => "application/xml;version=5.6", "x-vchs-authorization" => token }
    servicesarray = self.class.get('/api/vchs/services')
    servicesarray["Services"]["Service"] = hashtoarray(servicesarray["Services"]["Service"])
    return servicesarray
  end #services


  def vdcs(token,href)
    self.class.base_uri href
  	self.class.default_options[:headers] = { "Accept" => "application/xml;version=5.6", "x-vchs-authorization" => token }
    vdcssarray = self.class.get('')
    vdcssarray["Compute"]["VdcRef"] = hashtoarray(vdcssarray["Compute"]["VdcRef"])
    return vdcssarray
  end #vdcs


  def computeattributes(token,href)
    self.class.base_uri href
  	self.class.default_options[:headers] = { "Accept" => "application/xml;version=5.6", "x-vchs-authorization" => token }
    computeattributes = self.class.post('')
    return computeattributes
  end #computeattributes


end #Subscription

