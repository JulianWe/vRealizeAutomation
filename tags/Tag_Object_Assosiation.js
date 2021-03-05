System.log("====================== find deployment Target =================================");
// Modify with the name of the desired category SITECODES
var categoryName = "Infrastrastructure_Flavor";


var location = "ZHGR05";
var flavor = "rhel";
var environment = "prod"
var zone = "dmz";
var purpose = "";


// Set the VAPI endpoint to the first endpoint returned
var endpoints = VAPIManager.getAllEndpoints();  

for each (var endpoint in endpoints){

    if (endpoint.endpointUrl == "https://jw-vcsa7.vdi.sclabs.net/api") {

        System.log(endpoint.endpointUrl);

        // Fetch tags and tag categories
        var client = endpoint.client();  
        var category = new com_vmware_cis_tagging_category(client);  
        var categories = category.list();  
        var tagging = new com_vmware_cis_tagging_tag(client);  
        var asso = new com_vmware_cis_tagging_tag__association(client);
        var tags = tagging.list();  
        var outputTags = [];

        // Iterate through tag categories to find the category specified in categoryName
        for (var i in categories)  
        {   
            System.log(category.get(categories[i]).name + " Searching for: "+ categoryName);
            if (category.get(categories[i]).name == categoryName) {
                categoryId = categories[i];
                System.log("Name: " + category.get(categoryId).name + " Id: " + categoryId);
                var found = true;
                break;
            }
        }

        // Iterate through tags to find the tags that belong to the categoryName and add them to the outputTags array
        if(found) {
            for (var i in tags)  
            {
                var tagId = tags[i];
                var tagCatId = tagging.get(tagId).category_id.toString();
                
                if (tagCatId == categoryId.toString()) {
                    if(tagging.get(tagId).name.indexOf(siteCode) > -1) {
                        System.log("tagCatId " + tagCatId);
                        System.log("tagName " + tagging.get(tagId).name);
                        System.log("tagId "+tagId);
                        break;
                    }
                }
            }

            
            break;
        }
    }

    var attachedObjects = asso.list_attached_objects(tagId);

    //==============================================================================================================


    var categoryName = "SiteInformation"

    for each (var endpoint in endpoints){

        System.log(endpoint.endpointUrl);

        // Fetch tags and tag categories
        var client = endpoint.client();  
        var category = new com_vmware_cis_tagging_category(client);  
        var categories = category.list();  
        var tagging = new com_vmware_cis_tagging_tag(client);  
        var asso = new com_vmware_cis_tagging_tag__association(client);
        var tags = tagging.list();  
        var outputTags = [];

        // Iterate through tag categories to find the category specified in categoryName
        for (var i in categories)  
        {   
            System.log(category.get(categories[i]).name + " Searching for: "+ categoryName);
            if (category.get(categories[i]).name == categoryName) {
                categoryId = categories[i];
                System.log("Name: " + category.get(categoryId).name + " Id: " + categoryId);
                var found = true;
                break;
            }
        }

        // Iterate through tags to find the tags that belong to the categoryName and add them to the outputTags array
        if(found) {
            for (var i in tags)  
            {
                var tagId = tags[i];
                var tagCatId = tagging.get(tagId).category_id.toString();
                
                if (tagCatId == categoryId.toString()) {
                    if(tagging.get(tagId).name.indexOf("DeploymentTarget") > -1) {
                        System.log("tagCatId " + tagCatId);
                        System.log("tagName " + tagging.get(tagId).name);
                        System.log("tagId "+tagId);
                        break;
                    }
                }
            }

            
            break;
        }
    }
    foundObj = false;
    var attachedObjects2 = asso.list_attached_objects(tagId);
    for each(var obj2 in attachedObjects2 ) {
        for each(var obj in attachedObjects ) {
            if(obj.id == obj2.id && obj.type == obj2.type) {
                System.log("found DeploymentTarget id "+obj.id);
                System.log("found DeploymentTarget type "+obj.type);
                foundObj = true;
                break;
            }
        }
        if(foundObj) break;
    }

    System.log("+++++++++++++++++++++++++++++++++++ find id in Datacenter +++++++++++++++++++++++++++++++++++");
    var foundHost = false;
    for each( var entity in Datacenter.hostFolder.childEntity) {
        System.log("id "+entity.id);
        System.log("name "+entity.name);
        System.log("type "+entity.type);
        if(entity.id == obj.id && entity.type == obj.type) {
            System.log("found DeploymentTarget: " + entity.name)
            var DeploymentTarget = entity;
            break;
        }
        else if (entity.type == "ClusterComputeResource" ) {
            for each( var host in entity.host) {
                if(host.id == obj.id && host.type == obj.type) {
                    System.log("found DeploymentTarget: " + host.name)
                    foundHost = true;
                    var DeploymentTarget = host;
                    break;
                }
            
            }
        }
        if(foundHost) break;
    }
    if(DeploymentTarget) System.log("found "+DeploymentTarget.name + " of type " + obj.type);
    else throw "couldn't find DeploymentTarget";

    //TODO: get best Host
    if(obj.type == "ClusterComputeResource") {
        cluster = DeploymentTarget;
        //host = cluster.host[0];

    }
    else {
        host = DeploymentTarget;
        cluster = host.parent;
        hostname = host.name.split(".")[0];

        hostid = host.id;
    }

    /*

    var hosts = VcPlugin.getAllHostSystems();

    var hostFolder = Datacenter.hostFolder;
    System.log("HostFolder: "+hostFolder.name);
    var cluster = hostFolder.childEntity;
    System.log("Cluster: "+cluster);

    for each (var host in hosts){

        System.log("HostName: "+host.name);
        System.log("TAG: "+host.tag("DeploymentTarget"));
        if(host.parent.vimType == "ComputeResource"){

            System.log("Parent is Host: "+host.parent.name);

        } else if (host.parent.vimType == "ClusterComputeResource"){

            System.log("Parent is Cluster: "+host.parent.name);

        }

        var parentDC = host.parent.parent.parent.name;

        System.log("Datacenter: "+ parentDC);
        
        if (parentDC.indexOf(siteCode) > 0){

            var tag = host.tag("DeploymnetTarget");
            System.log(tag);
            System.log("+++++++++++++++++++++++++++++++++++ found Host DC +++++++++++++++++++++++++++++++++++");
            break;
        }

    }
    */

    System.log("============================ END find deployment Target =====================");

    /*
    var hosts = Datacenter.vimHost;
    System.log(hosts);
    for each (var host in hosts){

        System.log(host);

    }

    */


    }
    

