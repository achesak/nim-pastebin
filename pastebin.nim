# Pastebin API wrapper.

# Written by Adam Chesak.
# Released under the MIT open source license.


# Import the formats and constants.
import pastebin_formats
import pastebin_constants

# Import modules.
import httpclient
import cgi
import strutils
import xmlparser
import xmltree
import streams
import times


type
    PasteDetails* = ref object
        key* : string
        dateCreated* : Time
        title* : string
        size* : int
        expirationDate* : Time
        privacy* : int
        formatLong* : string
        formatShort* : string
        url* : string
        hits* : int

    UserDetails* = ref object
        username* : string
        formatShort* : string
        expirationDate* : Time
        avatarUrl* : string
        privacy* : int
        website* : string
        email* : string
        location* : string
        accountType* : int


proc createPaste*(devKey : string, pasteData : string, pasteName : string = "", pasteFormat : string = "", pastePrivate : int = 0, pasteExpire : string = ""): string = 
    ## Creates a new paste.
    ##
    ## ``devKey`` and ``pasteData`` are required, but everything else is optional. Returns either the URL of the paste or an error message.
    
    # Build the parameters.
    var params : string = "api_option=paste&api_dev_key=" & devKey
    params = params & "&api_paste_code=" & encodeUrl(pasteData) & "&api_paste_name=" & encodeUrl(pasteName)
    params = params & "&api_paste_private=" & intToStr(pastePrivate)
    # Only add a format if one was specified.
    if pasteFormat != "":
        params = params & "&api_paste_format=" & pasteFormat
    # Only add an expiration date if one was specified.
    if pasteExpire != "":
        params = params & "&api_paste_expire_date=" & pasteExpire
    
    # Create the paste.
    var postData : MultipartData = newMultipartData()
    postData.add("Content-Type", "application/x-www-form-urlencoded")
    var response : string = newHttpClient().postContent("http://pastebin.com/api/api_post.php", params, postData)
    
    return response


proc createPasteFromFile*(devKey : string, fileName: string, pasteName : string = "", pasteFormat : string = "", pastePrivate : int = 0, pasteExpire : string = ""): string = 
    ## Creates a new paste from a file.
    ##
    ## ``devKey`` and ``fileName`` are required, but everything else is optional. Returns either the URL of the paste or an error message.
    
    var contents : string = readAll(open(fileName))
    var response : string = createPaste(devKey, contents, pasteName, pasteFormat, pastePrivate, pasteExpire)
    
    return response


proc createAPIUserKey*(devKey : string, userName : string, userPassword : string): string = 
    ## Creates a user key.
    ##
    ## All parameters are required. Returns either the user key or an error message.
    
    # Build the parameters.
    var params : string = "api_dev_key=" & devKey
    params = params & "&api_user_name=" & userName & "&api_user_password=" & userPassword
    
    # Create the paste.
    var postData : MultipartData = newMultipartData()
    postData.add("Content-Type", "application/x-www-form-urlencoded")
    var response : string = newHttpClient().postContent("http://pastebin.com/api/api_login.php", params, postData)
    
    # Return either the use key or the error message.
    return response


proc getPaste*(pasteKey : string): string = 
    ## Gets a paste.
    ##
    ## Parameter is required. Returns the contents of the paste.
    
    var data : string = newHttpClient().getContent("http://pastebin.com/raw.php?i=" & pasteKey)
    
    return data


proc getPasteToFile*(pasteKey : string, fileName : string): string = 
    ## Gets a paste and writes it to a file.
    ##
    ## All parameters are required. Returns the contents of the paste.
    
    var data : string = newHttpClient().getContent("http://pastebin.com/raw.php?i=" & pasteKey)
    write(open(fileName, fmWrite), data)
    
    return data


proc deletePaste*(devKey : string, userKey : string, pasteKey : string): string = 
    ## Deletes a paste.
    ##
    ## All parameters are required. Returns a status message.
    
    # Build the parameters.
    var params : string = "api_option=delete&api_dev_key=" & devKey
    params = params & "&api_user_key=" & userKey & "&api_paste_key=" & pasteKey
    
    # Delete the paste.
    var postData : MultipartData = newMultipartData()
    postData.add("Content-Type", "application/x-www-form-urlencoded")
    var response : string = newHttpClient().postContent("http://pastebin.com/api/api_post.php", params, postData)
    
    return response


proc listUserPastes*(devKey : string, userKey : string, resultsLimit : int = 50): seq[PasteDetails] = 
    ## Lists a user's pastes.
    ##
    ## All parameters are required except for ``resultsLimit``.
    
    # Build the parameters.
    var params : string = "api_option=list&api_dev_key=" & devKey
    params = params & "&api_user_key=" & userKey & "&api_results_limit=" & intToStr(resultsLimit)
    
    # Get the XML.
    var postData : MultipartData = newMultipartData()
    postData.add("Content-Type", "application/x-www-form-urlencoded")
    var response : string = newHttpClient().postContent("http://pastebin.com/api/api_post.php", params, postData)
    response = "<pastebin>" & response & "</pastebin>"
    var xml : XmlNode = parseXML(newStringStream(response))
    
    var pasteList : seq[PasteDetails] = @[]
    
    # Loop through the list of pastes.
    for i in 0..len(xml) - 1:

        var paste : PasteDetails
        paste.key = xml[i][0].innerText
        paste.dateCreated = fromSeconds(parseInt(xml[i][1].innerText))
        paste.title = xml[i][2].innerText
        paste.size = parseInt(xml[i][3].innerText)
        paste.expirationDate = fromSeconds(parseInt(xml[i][4].innerText))
        paste.privacy = parseInt(xml[i][5].innerText)
        paste.formatLong = xml[i][6].innerText
        paste.formatShort = xml[i][7].innerText
        paste.url = xml[i][8].innerText
        paste.hits = parseInt(xml[i][9].innerText)
        
        pasteList.add(paste)
    
    return pasteList


proc listTrendingPastes*(devKey : string): seq[PasteDetails] = 
    ## Lists the top 18 trending pastes.
    ##
    ## Parameter is required.
    
    # Build the parameters.
    var params : string = "api_option=trends&api_dev_key=" & devKey
    
    # Get the XML.
    var postData : MultipartData = newMultipartData()
    postData.add("Content-Type", "application/x-www-form-urlencoded")
    var response : string = newHttpClient().postContent("http://pastebin.com/api/api_post.php", params, postData)
    response = "<pastebin>" & response & "</pastebin>"
    var xml : XmlNode = parseXML(newStringStream(response))
    
    # Create the top level array.
    var pasteList : seq[PasteDetails] = @[]
    
    # Loop through the list of pastes.
    for i in 0..len(xml) - 1:
        
        var paste : PasteDetails
        paste.key = xml[i][0].innerText
        paste.dateCreated = fromSeconds(parseInt(xml[i][1].innerText))
        paste.title = xml[i][2].innerText
        paste.size = parseInt(xml[i][3].innerText)
        paste.expirationDate = fromSeconds(parseInt(xml[i][4].innerText))
        paste.privacy = parseInt(xml[i][5].innerText)
        paste.formatLong = xml[i][6].innerText
        paste.formatShort = xml[i][7].innerText
        paste.url = xml[i][8].innerText
        paste.hits = parseInt(xml[i][9].innerText)
        
        pasteList.add(paste)
    
    return pasteList


proc getUserInfo*(devKey : string, userKey : string): UserDetails = 
    ## Gets info about a user.
    ##
    ## All parameters are required.
    
    # Build the parameters.
    var params : string = "api_option=userdetails&api_dev_key=" & devKey
    params = params & "&api_user_key=" & userKey
    
    # Get the XML
    var postData : MultipartData = newMultipartData()
    postData.add("Content-Type", "application/x-www-form-urlencoded")
    var response : string = newHttpClient().postContent("http://pastebin.com/api/api_post.php", params, postData)
    var xml : XmlNode = parseXML(newStringStream(response))

    var user : UserDetails
    user.username = xml[0].innerText
    user.formatShort = xml[1].innerText
    user.expirationDate = fromSeconds(parseInt(xml[2].innerText))
    user.avatarUrl = xml[3].innerText
    user.privacy = parseInt(xml[4].innerText)
    user.website = xml[5].innerText
    user.email = xml[6].innerText
    user.location = xml[7].innerText
    user.accountType = parseInt(xml[8].innerText)
    
    return user
