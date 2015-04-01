## Massimo Re Ferre' [www.it20.info](http://www.it20.info) ##

# Table of Contents
1. [What is vcatools?](#What-is-vcatools?)
2. [Why did you create vcautils? What's its purpose?](#Why-did-you-create-vcautils?-What's-its-purpose?)
3. [Are you maintaining vcautils? ](#Are-you-maintaining-vcautils?)
4. [How do I install vcautils? ](#How-do-I-install-vcautils?)
5. [How do I use vcautils? ](#How-do-I-use-vcautils?)
6. [Technical Background ](#Technical-Background)
7. [License](#License)

<div id='What-is-vcatools?'/>
## What is vcatools?  ##

vcautils is a package of loosely coupled Ruby programs that contain: 

 - Back-end libraries for the various vCloud Air components
 - Front-end programs (CLIs) for the various vCloud Air components
 - A Sinatra app (vcaexplorer) that leverages the backend components to build a graph view of your tenant 

At the time of this writing the components (and CLIs) available are: ***vca***, ***vchs*** and ***compute***. 

Each of them is used to query the components outlined in the the **Technical Background** section below. 

Additional components such as DBaaS or ObjectStorage are not currently available. 

Note that error handling and test is super limited (if existent at all). Use at your own risk. On the other hand the tool only queries components so there is limited damage it could cause. 

This is a visual representation of it: 

![enter image description here](http://it20.info/misc/pictures/vcautils0.png)

Tip: the layout will make more sense upon reading the **Technical Background** section at the end of this document.

<div id='Why-did-you-create-vcautils?-What's-its-purpose?'/>
## Why did you create vcautils? What's its purpose?  ##

I have created this project primarily for the following reasons: 
 
 - Provide a sample implementation of a consumer of the various vCloud Air loosely coupled service interfaces
 - Expose to developers that want to integrate with vCloud Air the API structure of the service 
 - Exercise my (very limited) Ruby skills (and programming skills in general)
 - Possibly/Eventually use this set of tools as a fake application to exercise and test CI/CD workflows 
	 - including pushing to RubyGems.org, CloudFoundry, Docker Hub, etc. 

Because of this, I am not providing extensive documentation and how-to. I am opening this repo and flag it public but it is truly intended for personal use (but you are free to hack it if you want to).  

<div id='Are-you-maintaining-vcautils?'/>
## Are you maintaining vcautils? ##

Mostly for fun (and for the purposes above). If you are looking for a solid, truly community supported vCloud Air CLI either use [vca-cli](https://github.com/vmware/vca-cli) or PowerCli. 

<div id='How-do-I-install-vcautils?'/>
## How do I install vcautils? ##

Right now the easiest way to install vcautils is to grab it from RubyGems.org with: 

    gem install vcautils

I have developed vcautils using Ruby 1.9.3 but I have noticed it working with Ruby 2.x too.  It goes without saying that tests have been very limited.

You can also create the gem and install it on your own if you wish so with: 

    gem build vcautils.gemspec

    gem install vcautils-xxx.gem

A component of vcautils (i.e. vcaexplorer, which is a graphical user interface that provides a tree view of the resources in your tenant) is also available on-line at http://vcaexplorer.cfapps.io.

<div id='How-do-I-use-vcautils?'/>
## How do I use vcautils? ##

Once you have installed vcautils, the only thing you need to do is to createa a file called *vcautils.yml* with the following structure: 

    :username: email@domain
    :password: password
    :serviceroot: https://vca.vmware.com
    :mode: admin | developer 

Where username is a valid vCloud Air account. 

The ***mode*** is what makes this tool a bit unique as ***developer*** instructs the CLI to print a raw json representation of the query requested in addition to a more polished output. 

Easiest way to get started with the CLI interfaces is to type the various executables to get a list of supported commands. 

This is the **vca** CLI to interface with the *vca platform*:

    mreferre$ vca
    
    Use any of the following operations
    
    	e.g. vca token
    	e.g. vca plans
    	e.g. vca instances
    	e.g. vca instance <instance id>
    	e.g. vca users
    	e.g. vca servicegroups
    	e.g. vca billedcosts
    	e.g. vca billablecosts
    	e.g. vca customquery <REST GET query> <ContentType>

This is the **vchs** CLI to interface with the *vchs platform*:
 
    mreferre$ vchs
    
    Use any of the following operations
    
    	e.g. vchs services
    	e.g. vchs service <serviceId>
    	e.g. vchs service <serviceId> <VDC name>

This is the **compute** CLI to interface with the *compute service*: 

    mreferre$ compute
    
    You must specify the <API-URL-endpoint>, the <Org name> and a valid operation
    e.g. https://us-virginia-1-4.vchs.vmware.com 616ge553-342d-e4-be4a-d50e5sde5283 vdcs
    e.g. https://iaas.vcdcloud.com acme catalogs
    
    	e.g. compute <API-URL-endpoint> <Org name> computetoken
    	e.g. compute <API-URL-endpoint> <Org name> catalogs
    	e.g. compute <API-URL-endpoint> <Org name> catalog <catalog id>
    	e.g. compute <API-URL-endpoint> <Org name> orgvms
    	e.g. compute <API-URL-endpoint> <Org name> orgvapps
    	e.g. compute <API-URL-endpoint> <Org name> vdcs
    	e.g. compute <API-URL-endpoint> <Org name> vdc <vdc id>
    	e.g. compute <API-URL-endpoint> <Org name> vdc <vdc id> vapps
    	e.g. compute <API-URL-endpoint> <Org name> vdc <vdc id> networks

The easiest way to consume **vcaexplorer** is to connect to http://vcaexplorer.cfapps.io and login with your credentials. 

Alternatively (if you don't want to enter your credentials in an on-line service out of the blue) you can start the app on your own workstation and connect to https://localhost:4567. You can start it with the following command:

    ruby vcaexplorer.rb

The vcaexplorer output looks something like this and it represents a tree layout of the resources in your tenant: 

![enter image description here](http://it20.info/misc/pictures/vcautils5.png)

Note that vcaexplorer is centered around the output of the vca platform but it does support the view of resources attached to the vchs platform (see the *[vchs]Services* node in the graph).

In other words vcaexplorer is the graphical and live representation of the following architectural slide: 

![enter image description here](http://it20.info/misc/pictures/vcautils7.png)
 
Also note that the page takes a long time to load given all the queries run in the backend to retrieve the information to build the tree. 

Waiting for 3-5 minutes for the graph to materialize isn't uncommon, unless you get an Internal Server Error on your face, which is always possible. :)

<div id='Technical-Background'/>
## Technical Background ##

**Introduction**	

Welcome to the section dedicated to programmatically access vCloud Air.

This introduction is intended to serve as a background for engineers that need a better understanding of the vCloud Air architecture and how to consume vCloud Air via APIs (or through higher level constructs such as CLIs and automation tools). 

There are a number of fundamental tenets of the service (and its constructs) that you need to familiarize with to better consume it programmatically. 

**Modularity**

vCloud Air is a set of modular services that are tight to a platform.

The vCloud Air platform is an overarching construct that governs the various services and provides common features (identity and access management, service discovery, billing and metering reporting, etc. etc.).

The vCloud Air services are the actual cloud services you are consuming and where you are running your workloads. Examples of vCloud Air services include the compute service, DB as a Service, Object Storage Services and so on. 

It is important to understand that, when the service was introduced, the platform piece was very thin. That's "the vchs platform".  This platform is very much skewed towards the compute service (with a focus on the Dedicated Cloud service) and only supports limited features (i.e. service discovery)

Later, a more powerful platform has been introduced that is intended to be service agnostic and that supports many more features (e.g. compute service, DBaaS etc.). All new services will be delivered through this new engineering enhanced platform: "the vca platform". 

The picture below should help stitching this concept in mind: 
![enter image description here](http://it20.info/misc/pictures/vcautils1.png)

**Hand-off**

As part of the modularity concept above it is important to understand that there is a hand-off that will happen when you move from the platform to a given service. 

The nature of this hand-off depends on the platform that controls the service and the service itself. 

For example, with the compute service controlled by the vchs stack, the service discovery process will provide the compute end point as well as the credentials to consume that end-point.  

With the compute service controlled by the vca stack, the service discovery process will provide the compute end point against which you will need to login explicitly (in the future you will be able to use the same platform token to consume the compute service but for now you need to login explicitly until Oauth support is added to vCloud Director). 

With the Object Storage services (both powered by EMC and by Google Cloud Platform) the process involves grabbing the keys from the vCloud Air UI and then using them against the proper end-points advertised by the platform service discovery process. 

As you can see the hand-off is very peculiar to the service you are using and there is no one single process for it.  

**Code re-usability** 

The modularity and hand-off processes just described brings to the table a very important aspect: code re-usability. Another couple of examples may help here. 

vCloud Director is the product being leveraged to deliver the compute service to vCloud Air tenants. There is a process to discover those end-points and from that moment on you are talking to a standard vCloud Director interface. This means that you can re-use all the code (and existing integrations) that exist today for this ecosystem, including the incredible amount of public and private clouds that are built on that technology. So, in a way, vCloud Air compute is API compatible with all those public and private cloud environments. 

Similarly, vCloud Air tenants that want to leverage the Object Storage powered by Google Cloud Platform, they can re-use any piece of code that is compatible with this Google Service (including Google's own gsutil CLI). The vCloud Air platform only manages the access keys but Google does the actual delivery of the service and this is the standard Google service.   


**You need to abstract from the commercial models and nomenclatures**

As an engineer consuming vCloud Air through API interfaces you carry a responsibility: you need to abstract from the commercial models and focus more on the architecture and delivery mechanisms. 

There are two examples here that will help you better understand this concept. 

There are different SKUs for compute services (e.g. VPC Subscription) and a SKU for DR services (e.g. DR VPC Subscription). While these are separate commercial SKUs, the consumption model and the path you need to take to consume those services may be exactly the same since DR services, technically, are just extensions of a compute service. In other words a DR VPC will have DR APIs available whereas a standard VPC will not.   

Conversely, two identical VPC Subscription SKUs may be implemented differently and connected to different vCloud Air platforms depending on the region. For example in a region the VPC Subscription service may be delivered through the vchs platform, while in another region the VPC Subscription service may be delivered through the vca platform. This is an example of when identical commercial models and SKUs could be consumed via API in different ways. 

As a rule of thumb, everything that appears under this icon in the UI is delivered through the vchs platform:
![enter image description here](http://it20.info/misc/pictures/vcautils2.png)

A better way to (programmatically) find out which services are delivered through which platform is to query the service discovery service for both platforms. 

**A word on the vCloud Air compute service**

As an example, we will dive a bit deeper into the compute service (delivered via the vca stack). In this example we will not cover the delivery via the vchs stack but if you are interested the whole hand-off flow you can refer to the official vCloud Air documentation.

When you query the service controller of the vca stack (GET https://vca.vmware.com/api/sc/instances) you will see the list of service instances that you have available in your tenant. Some of these instances could be compute instances if you have VMs deployed in your tenant. 

This is an example of an entry of a compute instance as represented in the service controller: 

    "name": "Virtual Private Cloud OnDemand",
    "id": "bc129d20-770a-456f-b23a-4a4ac112aae7",
    "description": "Create virtual machines, and easily scale up or down as your needs change.",
    "region": "us-california-1-3.vchs.vmware.com",
    "instanceVersion": "1.0",
    "planId": "region:us-california-1-3.vchs.vmware.com:planID:c65d5821-aa97-4141-915a-7d7eab0a9d51",
    "serviceGroupId": "49d03ec7-15c3-4f62-ac73-ea99d7ad0cc9",
    "apiUrl": "https://us-california-1-3.vchs.vmware.com/api/compute/api/org/bc129d20-770a-456f-b23a-4a4ac112aae7",
    "dashboardUrl": "https://us-california-1-3.vchs.vmware.com/api/compute/compute/ui/index.html?orgName=92402aa7-5176-4a29-956a-5be4d0b401fb&serviceInstanceId=bc129d20-770a-456f-b23a-4a4ac112aae7&servicePlan=c65d5821-aa97-4141-915a-7d7eab0a9d51",
    "instanceAttributes": "{\"orgName\":\"92402aa7-5176-4a29-956a-5be4d0b401fb\",\"sessionUri\":\"https://us-california-1-3.vchs.vmware.com/api/compute/api/sessions\",\"apiVersionUri\":\"https://us-california-1-3.vchs.vmware.com/api/compute/api/versions\"}"

Note: even on the new vca platform some of the URLs have *vchs* in them. Do not get confused by that. 

These are the relevant fields you should focus on: 

- **Id**: this represents the uniqe ID of the instance. It also represents the vCD Org ID (as found in the apiUrl entry).

- **region**: this tells you the region where this instance is deployed

- **serviceGroupId**: this is the cost center tight to the instance (more on this later)

- **apiUrl**: this is the actual compute service Url for the hand-off  

- **instanceAttributes**: this includes the parameters to login into the instance

Since vCloud Director does not support (yet) the Oauth, you cannot use the vca platform token you have received at login and pass it to vCloud Director pointing to the apiUrl. This flow can be achieved as soon as Oauth support for vCloud Director gets implemented. 

Instead, as of today, you will have to use the instanceAttributes coordinates to login into the Org. There you have everything you need: sessionUri (the login end-point) and orgName (the Organization name).  

From this point on you can treat your instance as a standard vCloud Director Organization.  

Important: you will need to query the service controller to get a list of plans (GET https://vca.vmware.com/api/sc/plans) and match it with the planId as found in the instance to actually understand the nature of that instance. It could be an OnDemand instance or it could be a Subscription instance: you can find it out by the plan that this instance has been originated from.  

Note that there is going to be one vCD Org per region, per serviceGroupId.  If in your tenant you have more than one serviceGroupId provisioned you may have more than one vCD Org per region. 

The easiest way to find out if you have more than one serviceGroupId is to hover your mouse on VPC OnDemand in the UI. If you see something similar to the picture below it means you have more than one serviceGroupId: 

![enter image description here](http://it20.info/misc/pictures/vcautils3.png)

You can look up the relation between the serviceGroupId and the code above by querying the vca platform using:

 `GET https://vca.vmware.com/api/billing/service-group/`

A good way to look at this is as if this was a matrix where the serviceGroupId adds another dimension to the equation. This picture is intended to capture the essence of this 3D view where, inside a single vCloud Air tenant, there are multiple layers (serviceGroupIds) each with a potential global footprint: 

![enter image description here](http://it20.info/misc/pictures/vcautils4.png)

<div id='License'/>
## License ##

Apache Licensing version 2


