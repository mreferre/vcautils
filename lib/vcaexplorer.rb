#################################################################################
####                           Massimo Re Ferre'                             ####
####                             www.it20.info                               ####
####         vcautils, a set of utilities for vCloud Air Consumers           ####
################################################################################# 

  
#################################################################################
#### vcaexplorer.rb is a Sinatra app that visualize resources in your tenant ####
####   It leverages the vca-be.rb, vchs-be.rb and compute-be.rb libraries    ####
#################################################################################

$:.unshift File.dirname(__FILE__)

require 'sinatra'
require 'httparty'
require 'xml-fu'
require 'modules/vca-be'
require 'modules/vchs-be'
require 'modules/compute-be'
require 'gon-sinatra'
require 'json'

Sinatra::register Gon::Sinatra


enable :sessions
set :session_secret, '*&(^B831'


#set :port, 8080
#set :static, true
set :public_folder, "static"
set :views, "views"

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE


@@serviceroot = "https://vca.vmware.com/"
@@loginserviceroot = "https://vca.vmware.com/"
@@vchsloginserviceroot = "https://vchs.vmware.com/"

get '/loginbasic' do
    erb :login_basic
end #get /loginbasic



get '/' do
    erb :login_advanced
end #get /



post '/vcaexplorer' do


	session[:@@username] = params[:username]
	session[:@@password] = params[:password]

	@@iam = Iam.new()

	@@sc = Sc.new()

	@@compute = Compute.new()
	
	@@billing = Billing.new()

	@@misc = Misc.new()
	
	@@vchs = Vchs.new()


	session[:@@token] = @@iam.login(session[:@@username], session[:@@password], @@loginserviceroot)
	
	puts "vCA login done" 
	
	session[:@@vchstoken] = @@vchs.login(session[:@@username], session[:@@password], @@vchsloginserviceroot)

	puts "vCHS login done" 

	
	gon.instancesarray = @@sc.instances(session[:@@token], @@serviceroot)
	gon.plansarray = @@sc.plans(session[:@@token], @@serviceroot)	
	gon.instancesarray = @@sc.instances(session[:@@token], @@serviceroot)
	gon.usersarray = @@iam.users(session[:@@token], @@serviceroot)
	gon.servicegroupsarray = @@billing.servicegroups(session[:@@token], @@serviceroot)

    gon.servicesarray = @@vchs.services(session[:@@vchstoken], @@vchsloginserviceroot)
    
    puts "retrieved all arrays" 


################
##START Plans
################
    gon.plans_tree = {"name"=> "PlanList", "children" => [{}]}
    gon.plans_tree["children"][0] = {"name" => "plans", "children" => [{}]}
    gon.plansarray['PlanList']['plans'].length.times do |i| 
    											gon.plans_tree["children"][0]["children"][i] = {"name" => gon.plansarray['PlanList']['plans'][i]["name"] + " " + gon.plansarray['PlanList']['plans'][i]["region"],
    																						    "attribute" =>  [{"name" => "name", "value" => gon.plansarray['PlanList']['plans'][i]["name"]},
    																										     {"name" => "id", "value" => gon.plansarray['PlanList']['plans'][i]["id"]},
    																										     {"name" => "region", "value" => gon.plansarray['PlanList']['plans'][i]["region"]},
    																										     {"name" => "planVersion", "value" => gon.plansarray['PlanList']['plans'][i]["planVersion"]}
         																									    ]
         																				       }
    									end	#gon.plansarray['PlanList']['plans'].length.times do |i| 
################
##STOP Plans
################



################
##START Instances
################
    gon.instances_tree = {"name"=> "InstanceList", "children" => [{}]}
    gon.instances_tree["children"][0] = {"name" => "instances", "children" => [{}]}
    gon.instancesarray["InstanceList"]["instances"].length.times do |i| 
    
           
    			gon.instances_tree["children"][0]["children"][i] = {"name" => gon.instancesarray["InstanceList"]["instances"][i]["name"] + " - " + gon.instancesarray["InstanceList"]["instances"][i]["region"], 
     																"attribute" => [{"name" => "name", "value" => gon.instancesarray["InstanceList"]["instances"][i]["name"]},
     																			    {"name" => "id", "value" => gon.instancesarray["InstanceList"]["instances"][i]["id"]},
     																			    {"name" => "serviceGroupId", "value" => gon.instancesarray["InstanceList"]["instances"][i]["serviceGroupId"]},
     																			    {"name" => "region", "value" => gon.instancesarray["InstanceList"]["instances"][i]["region"]},
     																			    {"name" => "planId", "value" => gon.instancesarray["InstanceList"]["instances"][i]["planId"]},
     																			    {"name" => "apiUrl", "value" => gon.instancesarray["InstanceList"]["instances"][i]["apiUrl"]}
     																			   ],
    																"children" => [{}]
    																}
    		    
				case gon.instancesarray["InstanceList"]["instances"][i]["planId"].chomp  		
    		    
				  #OnDemand (and DR on OnDemand)    								
    			  when "region:us-virginia-1-12.vchs.vmware.com:planID:67538ff0-f4c3-48cb-8a6f-b0a3ac5aa324",
			 		   "region:au-south-1-15.vchs.vmware.com:planID:c65d5821-aa97-4141-915a-7d7eab0a9d51",
			 		   "region:de-germany-1-16.vchs.vmware.com:planID:c65d5821-aa97-4141-915a-7d7eab0a9d51",
			 		   "region:uk-slough-1-6.vchs.vmware.com:planID:c65d5821-aa97-4141-915a-7d7eab0a9d51",
			 		   "region:us-california-1-3.vchs.vmware.com:planID:c65d5821-aa97-4141-915a-7d7eab0a9d51",
			 		   "region:us-virginia-1-4.vchs.vmware.com:planID:c65d5821-aa97-4141-915a-7d7eab0a9d51"
    				gon.instances_tree["children"][0]["children"][i]["children"][0] = {"name" => "instanceAttributes",
    																			  	 "attribute" => [{"name" => "orgName", "value" => gon.instancesarray["InstanceList"]["instances"][i]["instanceAttributes"]["orgName"]},
    																			  	                 {"name" => "sessionUri", "value" => gon.instancesarray["InstanceList"]["instances"][i]["instanceAttributes"]["sessionUri"]}
    																			   		            ]
    																			 	  }
    			    																
    				orgname, sessionuri = @@misc.extractendpoint(gon.instancesarray["InstanceList"]["instances"][i]["instanceAttributes"])
     	  	  		tempapiversionsarray = @@compute.apiversions(sessionuri)
					apiversionsarray = Array.new
					tempapiversionsarray['SupportedVersions']['VersionInfo'].length.times do |i| 
																	apiversionsarray.push(tempapiversionsarray['SupportedVersions']['VersionInfo'][i]['Version'])
																  end
					apiversionsarray = apiversionsarray.sort_by do |x|
    																x.split(".").map {|i| i.to_i}
  																end
					apiversion = apiversionsarray.last
    	  	  		
    	  	  		computetoken = @@compute.login(session[:@@username], session[:@@password], orgname, sessionuri, apiversion) 
    		    
    		   		#puts "computetoken:" + computetoken
    		    
    		   		gon.vdcsarray = @@compute.vdcs(computetoken, sessionuri, apiversion)
    				#puts JSON.pretty_generate(gon.vdcsarray)
    				#puts gon.vdcsarray["QueryResultRecords"]["OrgVdcRecord"].length
  	  	  		
     	  	  		gon.vdcsarray["QueryResultRecords"]["OrgVdcRecord"].length.times do |e|
     	  	  	     			puts gon.vdcsarray["QueryResultRecords"]["OrgVdcRecord"][e]["name"]
								gon.instances_tree["children"][0]["children"][i]["children"][e] = {"name" => gon.vdcsarray["QueryResultRecords"]["OrgVdcRecord"][e]["name"],
    																						       "attribute" => [{"name" => "status", "value" => gon.vdcsarray["QueryResultRecords"]["OrgVdcRecord"][e]["status"]},
    																						                       {"name" => "numberOfVApps", "value" => gon.vdcsarray["QueryResultRecords"]["OrgVdcRecord"][e]["numberOfVApps"]},
    																						                       {"name" => "cpuUsedMhz", "value" => gon.vdcsarray["QueryResultRecords"]["OrgVdcRecord"][e]["cpuUsedMhz"]},
    																						                       {"name" => "memoryUsedMB", "value" => gon.vdcsarray["QueryResultRecords"]["OrgVdcRecord"][e]["memoryUsedMB"]},
    																						                       {"name" => "storageUsedMB", "value" => gon.vdcsarray["QueryResultRecords"]["OrgVdcRecord"][e]["storageUsedMB"]}
    																						                       ],
    																						       "children" => [{}]
    																						      }

								
								
								
								
								############### gon.vappssarray = @@compute.vapps(computetoken, sessionuri, apiversion)																			          	  	  	 
    							############### gon.networkssarray = @@compute.vdcs(computetoken, sessionuri, apiversion)																			          	  	  	 
     	  	  	    			############### gon.Edgesarray = @@compute.vdcs(computetoken, sessionuri, apiversion)																			          	  	  	 

     	  	  	
     	  	  		end	# gon.vdcsarray["QueryResultRecords"]["OrgVdcRecord"].length.times do |e|   	 

     	  	  		gon.catalogsarray = @@compute.catalogs(computetoken, sessionuri, apiversion)
     	  	  		#puts JSON.pretty_generate(gon.catalogsarray)
     	  	  		gon.catalogsarray["QueryResultRecords"]["CatalogRecord"].length.times do |e|
     	  	  					puts gon.catalogsarray["QueryResultRecords"]["CatalogRecord"][e]["name"]
     	  	  					gon.instances_tree["children"][0]["children"][i]["children"] << {"name" => gon.catalogsarray["QueryResultRecords"]["CatalogRecord"][e]["name"],
     	  	  																					 "attribute" => [{"name" => "creationDate", "value" => gon.catalogsarray["QueryResultRecords"]["CatalogRecord"][e]["creationDate"]},
    																						                     {"name" => "isPublished", "value" => gon.catalogsarray["QueryResultRecords"]["CatalogRecord"][e]["isPublished"]},
    																						                     {"name" => "isShared", "value" => gon.catalogsarray["QueryResultRecords"]["CatalogRecord"][e]["isShared"]},
    																						                     {"name" => "numberOfMedia", "value" => gon.catalogsarray["QueryResultRecords"]["CatalogRecord"][e]["numberOfMedia"]},
    																						                     {"name" => "numberOfVAppTemplates", "value" => gon.catalogsarray["QueryResultRecords"]["CatalogRecord"][e]["numberOfVAppTemplates"]},
    																						                     {"name" => "orgName", "value" => gon.catalogsarray["QueryResultRecords"]["CatalogRecord"][e]["orgName"]},
    																						                     {"name" => "owner", "value" => gon.catalogsarray["QueryResultRecords"]["CatalogRecord"][e]["owner"]},
    																						                     {"name" => "ownerName", "value" => gon.catalogsarray["QueryResultRecords"]["CatalogRecord"][e]["ownerName"]},
    																						                     {"name" => "href", "value" => gon.catalogsarray["QueryResultRecords"]["CatalogRecord"][e]["href"]}
    																						                     ],
    																						      "children" => [{}]
     	  	  					    															}
    	  	  					
     	  	  					gon.catalogitemsarray = @@compute.catalogitems(computetoken, gon.catalogsarray["QueryResultRecords"]["CatalogRecord"][e]["href"], apiversion)
     	  	  					#puts JSON.pretty_generate(gon.catalogitemsarray)
     	  	  					if gon.catalogitemsarray['Catalog']['CatalogItems'] != nil 
     	  	  							gon.catalogitemsarray["Catalog"]["CatalogItems"]["CatalogItem"].length.times do |x|
     	  	  							  gon.instances_tree["children"][0]["children"][i]["children"][-1]['children']<< {"name" => gon.catalogitemsarray["Catalog"]["CatalogItems"]["CatalogItem"][x]["name"],
																												"attribute" => [{"name" => "name", "value" => gon.catalogitemsarray["Catalog"]["CatalogItems"]["CatalogItem"][x]["name"]},
     	  	  							  																						{"name" => "id", "value" => gon.catalogitemsarray["Catalog"]["CatalogItems"]["CatalogItem"][x]["id"]},
     	  	  							  																						{"name" => "type", "value" => gon.catalogitemsarray["Catalog"]["CatalogItems"]["CatalogItem"][x]["type"]},
     	  	  							  																						{"name" => "href", "value" => gon.catalogitemsarray["Catalog"]["CatalogItems"]["CatalogItem"][x]["href"]}
     	  	  							  																						],
     	  	  							  																		}
     	  	  							end #gon.catalogitemsarray["Catalog"]["CatalogItems"].length.times do |x|
     	  	  							gon.instances_tree["children"][0]["children"][i]["children"][-1]['children'].shift
     	  	  					end #if gon.catalogitemsarray["Catalog"]["CatalogItems"].any?  															
     	  	  					    															
     	  	  					    															
     	  	  					    															
     	  	  					    															
					
					
					end #gon.catalogsarray["QueryResultRecords"]["CatalogRecord"].length.times do |e|
 	  	  					
     	  	    
     	  	    
     	  	    
     	  	    end #case gon.instancesarray["InstanceList"]["instances"][i]["planId"].chomp    	
												
	end #gon.instancesarray["InstanceList"]["instances"].length.times do |i|
    		
												
########################
##STOP Instances
########################



################
##START Users
################
    gon.users_tree = {"name"=> "Users", "children" => [{}]}
    gon.users_tree["children"][0] = {"name" => "User", "children" => [{}]}
    gon.usersarray['Users']['User'].length.times do |i| 
    					gon.users_tree["children"][0]["children"][i] = {"name" => gon.usersarray['Users']['User'][i]["email"], 
    					    											"attribute" => [{"name" => "state", "value" => gon.usersarray['Users']['User'][i]["state"]},
    					    											                {"name" => "email", "value" => gon.usersarray['Users']['User'][i]["email"]},
    					    											                {"name" => "userName", "value" => gon.usersarray['Users']['User'][i]["userName"]}
    					    											                ],
    																	"children" => [{}]
    																	}
    					gon.users_tree["children"][0]["children"][i]["children"][0] = {"name" => "id", 
    																				   "attribute" => [{"name" => "id", "value" => gon.usersarray['Users']['User'][i]["id"]},
    																				                   {"name" => "created", "value" => gon.usersarray['Users']['User'][i]["created"]},
    																				                   {"name" => "modified", "value" => gon.usersarray['Users']['User'][i]["modified"]}
    																				   	              ]
    																				  }												
    					gon.users_tree["children"][0]["children"][i]["children"][1] = {"name" => "roles", 
    																				"children" => [{}]
    																				}												

						gon.usersarray['Users']['User'][i]["roles"]["role"].length.times do |x|
										gon.users_tree["children"][0]["children"][i]["children"][1]["children"][x] = {"name" => gon.usersarray['Users']['User'][i]["roles"]["role"][x]["name"],
																													  "attribute" => [{"name" => "name", "value" =>gon.usersarray['Users']['User'][i]["roles"]["role"][x]["name"]},
																													  				  {"name" => "id", "value" =>gon.usersarray['Users']['User'][i]["roles"]["role"][x]["id"]},
																													  				  {"name" => "description", "value" =>gon.usersarray['Users']['User'][i]["roles"]["role"][x]["description"]}
																													  				 ]
     																											     }					
						end # gon.usersarray['Users']['User']["roles"]["role"].length.times do |x|					
    																	
    																	
	end # gon.usersarray['Users']['User'].length.times do |i|
    																										
################
##STOP Users
################



################
##START ServiceGroups
################

    gon.servicegroups_tree = {"name"=> "serviceGroupList", "children" => [{}]}
    gon.servicegroups_tree["children"][0] = {"name" => "serviceGroup", "children" => [{}]}
    
    gon.servicegroupsarray["serviceGroupList"]["serviceGroup"].length.times do |i| 	
    		gon.servicegroups_tree["children"][0]["children"][i] = {"name" => gon.servicegroupsarray["serviceGroupList"]["serviceGroup"][i]["displayName"], 
    															     "attribute" => [{"name" => "displayName", "value" => gon.servicegroupsarray["serviceGroupList"]["serviceGroup"][i]["displayName"]},
    																				 {"name" => "id", "value" => gon.servicegroupsarray["serviceGroupList"]["serviceGroup"][i]["id"]},
    																				 {"name" => "billingCurrency", "value" => gon.servicegroupsarray["serviceGroupList"]["serviceGroup"][i]["billingCurrency"]}
    																				],
    															"children" => [{}]
    															}
    	    gon.servicegroups_tree["children"][0]["children"][i]["children"][0] = {"name" => "availableBills", 
    	         														       	   "children" => [{}]
    	         														       	   }
    	    gon.servicegroups_tree["children"][0]["children"][i]["children"][0]["children"][0] = {"name" => "bill", 
    	         														       	   "children" => [{}]
    	         														       	   }
    	    gon.servicegroupsarray["serviceGroupList"]["serviceGroup"][i]["availableBills"]["bill"].length.times do |x|
    	    			gon.servicegroups_tree["children"][0]["children"][i]["children"][0]["children"][0]["children"][x] = {"name" => "billingPeriod", 
    	         														       	   "children" => [{}]
    	         														       	   }
    	         		gon.servicegroups_tree["children"][0]["children"][i]["children"][0]["children"][0]["children"][x]["children"][0] = {"name" => gon.servicegroupsarray["serviceGroupList"]["serviceGroup"][i]["availableBills"]["bill"][x]["billingPeriod"]["month"].to_s + "-" + gon.servicegroupsarray["serviceGroupList"]["serviceGroup"][i]["availableBills"]["bill"][x]["billingPeriod"]["year"].to_s,
    	     																															    "attribute" => [{"name" => "month", "value" => gon.servicegroupsarray["serviceGroupList"]["serviceGroup"][i]["availableBills"]["bill"][x]["billingPeriod"]["month"].to_s},
    	     																															   					{"name" => "year", "value" => gon.servicegroupsarray["serviceGroupList"]["serviceGroup"][i]["availableBills"]["bill"][x]["billingPeriod"]["year"].to_s},
    	     																															   					{"name" => "startDate", "value" => gon.servicegroupsarray["serviceGroupList"]["serviceGroup"][i]["availableBills"]["bill"][x]["billingPeriod"]["startDate"].to_s},
    	     																															   					{"name" => "endDate", "value" => gon.servicegroupsarray["serviceGroupList"]["serviceGroup"][i]["availableBills"]["bill"][x]["billingPeriod"]["endDate"].to_s}
    	     																															   				   ]
    	     																															   }    	     																															   
    	    end #gon.servicegroupsarray["serviceGroupList"]["serviceGroup"][i]["availableBills"]["bill"].length.times do |x|
    	         														       
    
    end #gon.servicegroupsarray["serviceGroupList"]["serviceGroup"].length.times do |i| 


################
## END ServiceGroups
################





################
##START vCHS
################

    gon.vchs_tree = {"name"=> "[vchs]Services", "children" => [{}]}
    gon.vchs_tree["children"][0] = {"name" => "Service", "children" => [{}]}
    if gon.servicesarray['Services']['Service'].any?
    	gon.servicesarray["Services"]["Service"].length.times do |i|            
    			gon.vchs_tree["children"][0]["children"][i] = {"name" => gon.servicesarray["Services"]["Service"][i]["serviceId"], 
     																"attribute" => [{"name" => "region", "value" => gon.servicesarray["Services"]["Service"][i]["region"]},
     																			    {"name" => "serviceType", "value" => gon.servicesarray["Services"]["Service"][i]["serviceType"]},
     																			    {"name" => "type", "value" => gon.servicesarray["Services"]["Service"][i]["type"]},
     																			    {"name" => "href", "value" => gon.servicesarray["Services"]["Service"][i]["href"]}
     																			   ],
    																"children" => [{}]
    																}
    															end #gon.vchs_tree["Services"]["Service"].length.times do |i| 
    end #if gon.servicesarray['Services']['Service'].any?




################
##END vCHS
################










##########################
## Assembling vCA root ###
##########################

gon.vcaroot_tree = {"name"=> "vCloud Air", "children" => [{}]}
gon.vcaroot_tree["children"][0] = gon.plans_tree
gon.vcaroot_tree["children"][1] = gon.instances_tree
gon.vcaroot_tree["children"][2] = gon.users_tree
gon.vcaroot_tree["children"][3] = gon.servicegroups_tree
gon.vcaroot_tree["children"][4] = gon.vchs_tree

#################################
## End of Assembling vCA root ###
#################################


	erb :vcaexplorer
end #post / 



get '/token' do
	erb :token, :locals => {'username' => session[:@@username], 'serviceroot' => @@serviceroot, 'token' => session[:@@token]}
end #/token

