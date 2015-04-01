#################################################################################
####                           Massimo Re Ferre'                             ####
####                             www.it20.info                               ####
####         vcautils, a set of utilities for vCloud Air Consumers           ####
################################################################################# 



class Compute
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
  

  def apiversions(apiendpoint)
      self.class.base_uri apiendpoint
      apiversionsarray = self.class.get('/api/versions')
	  return apiversionsarray
  end #setapiversion

  
  def login(username, password, orgname, computeapiendpoint, apiversion)
  	credentials = username + "@" + orgname
    self.class.base_uri computeapiendpoint
  	self.class.basic_auth credentials, password
  	self.class.default_options[:headers] = {"Accept" => "application/*+xml;version=" + apiversion}
    response = self.class.post('/api/sessions')
    computetoken = response.headers['x-vcloud-authorization']
    return computetoken 
  end #login
  
  
  def instancedetails(computetoken, computeapiendpoint, query, apiversion)
	self.class.default_options[:headers] = { "Accept" => "application/*+xml;version=" + apiversion, "x-vcloud-authorization" => computetoken }    
	instancedetails = self.class.get(computeapiendpoint + query)
    return instancedetails 
  end #login

  
  def vdcs (computetoken, computeapiendpoint, apiversion)
     vdcsarray = instancedetails(computetoken, computeapiendpoint, "/api/admin/vdcs/query", apiversion)
     vdcsarray["QueryResultRecords"]["OrgVdcRecord"] = hashtoarray(vdcsarray["QueryResultRecords"]["OrgVdcRecord"])
     return vdcsarray
  end #vdcs
    
    
  def catalogs (computetoken, computeapiendpoint, apiversion)
     catalogsarray = instancedetails(computetoken, computeapiendpoint, "/api/catalogs/query", apiversion)
     catalogsarray["QueryResultRecords"]["CatalogRecord"] = hashtoarray(catalogsarray["QueryResultRecords"]["CatalogRecord"])
     return catalogsarray
  end #catalogs
  
  
  def catalogitems (computetoken, cataloghref, apiversion)
     catalogitemsarray = instancedetails(computetoken, cataloghref, "", apiversion)
     if catalogitemsarray["Catalog"]["CatalogItems"] != nil 
     	catalogitemsarray["Catalog"]["CatalogItems"]["CatalogItem"] = hashtoarray(catalogitemsarray["Catalog"]["CatalogItems"]["CatalogItem"])
     end
     return catalogitemsarray
  end #catalogitems
    
    
  def orgvms (computetoken, computeapiendpoint, apiversion)
     orgvmsarray = instancedetails(computetoken, computeapiendpoint, "/api/vms/query", apiversion)
     return orgvmsarray
  end #orgvms
  

  def orgvapps (computetoken, computeapiendpoint, apiversion)
     orgvappsarray = instancedetails(computetoken, computeapiendpoint, "/api/vApps/query", apiversion)
     return orgvappsarray
  end #orgvapps

    
  def networks (computetoken, vdchref, apiversion)
     vdcdetails = instancedetails(computetoken, vdchref, "", apiversion)
     networksarray = vdcdetails["Vdc"]["AvailableNetworks"]
     networksarray["Network"] = hashtoarray(networksarray["Network"])
     return networksarray
  end #networks


  def networkdetails (computetoken, networkhref, apiversion)
     networkdetails = instancedetails(computetoken, networkhref, "", apiversion)
     if networkdetails["OrgVdcNetwork"]["Configuration"]["IpScopes"]["IpScope"]["IpRanges"]
     	networkdetails["OrgVdcNetwork"]["Configuration"]["IpScopes"]["IpScope"]["IpRanges"]["IpRange"] = hashtoarray(networkdetails["OrgVdcNetwork"]["Configuration"]["IpScopes"]["IpScope"]["IpRanges"]["IpRange"]) 
     end #if networkdetails["OrgVdcNetwork"]["Configuration"]["IpScopes"]["IpScope"]["IpRanges"]
     return networkdetails
  end #networkdetails




  
end #Compute  


