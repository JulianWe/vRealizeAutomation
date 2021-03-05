createCisSession(restHost);

var cisSession = getCisSession(restHost);
System.log("Log in with user " + cisSession.user);


System.log("Get Tag Categories");
var categoryIds = getTagCategories(restHost);
for each(var categoryId in categoryIds) {
    var category = getTagCategory(restHost, categoryId);
    System.log("Found category " + category.name);
}

System.log("Get Tag Associations by tagId");

var tagIds = getTagIds(restHost)

for each(var tagId in tagIds){
    var results = getTagAsso(restHost, tagId)

    for each(var res in results){
        System.log("Found cluster Id: "+ res.id);
        var cluster = getCluster(restHost, res.id)
        System.log(cluster.name);

    }
}




deleteCisSession(restHost);

// This function will set the Cookie header vmware-api-session-id=[CIS Session ID] based on the Basic AUthorization header set by vRO REST plug-in
function createCisSession(restHost) {
    var request = restHost.createRequest("POST", "/com/vmware/cis/session");
    // Setting an unset vmware-api-session-id Cookie header enforce using Basic Authorization instead of using a Cookie based authentication based on a previous sesion
    request.setHeader("Cookie", "vmware-api-session-id");
    var response = request.execute();
    if (response.statusCode != 200) throw "Status code " + statusCode + "\n" + response.contentAsString;
}

function getCisSession(restHost) {
    var request = restHost.createRequest("POST", "/com/vmware/cis/session?~action=get");
    var response = request.execute();
    if (response.statusCode != 200) throw "Status code " + statusCode + "\n" + response.contentAsString;
    // Returning the object
    return JSON.parse(response.contentAsString).value;
}

function getTagCategories(restHost) {
    var request = restHost.createRequest("GET", "/com/vmware/cis/tagging/category");
    var response = request.execute();
    if (response.statusCode != 200) throw "Status code " + statusCode + "\n" + response.contentAsString;
    // Returning an array of tag category ids
    return (JSON.parse(response.contentAsString)).value;
}

function getTagIds(restHost) {
    var request = restHost.createRequest("GET", "/com/vmware/cis/tagging/tag");
    var response = request.execute();
    if (response.statusCode != 200) throw "Status code " + statusCode + "\n" + response.contentAsString;
    // Returning an array of tag category ids
    return (JSON.parse(response.contentAsString)).value;
}

function getTagCategory(restHost, categoryId) {
    var request = restHost.createRequest("POST", "/com/vmware/cis/tagging/category?~action=get&amp;category_id=" + categoryId);
    var response = request.execute();
    if (response.statusCode != 200) throw "Status code " + statusCode + "\n" + response.contentAsString;
    // Returning the object
    return JSON.parse(response.contentAsString).value;
}

function getTagAsso(restHost, tagId) {
    var request = restHost.createRequest("POST", "/com/vmware/cis/tagging/tag-association/id:"+ tagId +"?~action=list-attached-objects");
    var response = request.execute();
    if (response.statusCode != 200) throw "Status code " + statusCode + "\n" + response.contentAsString;
    // Returning the object
    return JSON.parse(response.contentAsString).value;
}

function getCluster(restHost, clusterId) {
    var request = restHost.createRequest("GET", "/vcenter/cluster/"+ clusterId);
    var response = request.execute();
    if (response.statusCode != 200) throw "Status code " + statusCode + "\n" + response.contentAsString;
    // Returning the object
    return JSON.parse(response.contentAsString).value;
}

function deleteCisSession(restHost) {
    var request = restHost.createRequest("DELETE", "/com/vmware/cis/session");
    var response = request.execute();
    if (response.statusCode != 200) throw "Status code " + statusCode + "\n" + response.contentAsString;
}