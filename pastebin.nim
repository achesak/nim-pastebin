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
    var response : string = postContent("http://pastebin.com/api/api_post.php", "Content-Type: application/x-www-form-urlencoded;\c\L", params)
    
    # Return either the URL or the error message.
    return response


proc createPasteFromFile*(devKey : string, fileName: string, pasteName : string = "", pasteFormat : string = "", pastePrivate : int = 0, pasteExpire : string = ""): string = 
    ## Creates a new paste from a file.
    ##
    ## ``devKey`` and ``fileName`` are required, but everything else is optional. Returns either the URL of the paste or an error message.
    
    # Get the contents of the file.
    var contents : string = readAll(open(fileName))
    
    # Create the paste.
    var response : string = createPaste(devKey, contents, pasteName, pasteFormat, pastePrivate, pasteExpire)
    
    # Return either the URL or the error message.
    return response


proc createAPIUserKey*(devKey : string, userName : string, userPassword : string): string = 
    ## Creates a user key.
    ##
    ## All parameters are required. Returns either the user key or an error message.
    
    # Build the parameters.
    var params : string = "api_dev_key=" & devKey
    params = params & "&api_user_name=" & userName & "&api_user_password=" & userPassword
    
    # Create the paste.
    var response : string = postContent("http://pastebin.com/api/api_login.php", "Content-Type: application/x-www-form-urlencoded;\c\L", params)
    
    # Return either the use key or the error message.
    return response


proc listUserPastes*(devKey : string, userKey : string, resultsLimit : int = 50): seq[seq[string]] = 
    ## Lists a user's pastes.
    ##
    ## All parameters are required except for ``resultsLimit``.
    ## 
    ## Returns a sequence of sequences of strings, with the information at the folling indicies:
    ## * 0 - paste key
    ## * 1 - date created
    ## * 2 - title
    ## * 3 - size
    ## * 4 - expiration date
    ## * 5 - privacy setting
    ## * 6 - long format
    ## * 7 - short format
    ## * 8 - paste URL
    ## * 9 - number of hits
    
    # Build the parameters.
    var params : string = "api_option=list&api_dev_key=" & devKey
    params = params & "&api_user_key=" & userKey & "&api_results_limit=" & intToStr(resultsLimit)
    
    # Create the paste.
    var response : string = postContent("http://pastebin.com/api/api_post.php", "Content-Type: application/x-www-form-urlencoded;\c\L", params)
    response = "<pastebin>" & response & "</pastebin>"
    
    # Parse the XML.
    var xml : XmlNode = parseXML(newStringStream(response))
    
    # Create the top level array.
    var pasteArray : array[resultsLimit, seq[string]]
    
    # Loop through the list of pastes.
    for i in 0..(len(xml) - 1):
        
        # Get the paste info.
        var p1 : string = xml[i][0].innerText
        var p2 : string = xml[i][1].innerText
        var p3 : string = xml[i][2].innerText
        var p4 : string = xml[i][3].innerText
        var p5 : string = xml[i][4].innerText
        var p6 : string = xml[i][5].innerText
        var p7 : string = xml[i][6].innerText
        var p8 : string = xml[i][7].innerText
        var p9 : string = xml[i][8].innerText
        var p10 : string = xml[i][9].innerText
        
        # Add the paste info to the array.
        pasteArray[0] = @[p1, p2, p3, p4, p5, p6, p7, p8, p9, p10]
    
    # Return the list of the pastes.
    return @pasteArray


proc listTrendingPastes*(devKey : string): seq[seq[string]] = 
    ## Lists the top 18 trending pastes.
    ##
    ## Parameter is required. Returns a sequence of sequences of strings, in the same format as the return value of ``listUserPastes()``.
    
    # Build the parameters.
    var params : string = "api_option=trends&api_dev_key=" & devKey
    
    # Create the paste.
    var response : string = postContent("http://pastebin.com/api/api_post.php", "Content-Type: application/x-www-form-urlencoded;\c\L", params)
    response = "<pastebin>" & response & "</pastebin>"
    
    # Parse the XML.
    var xml : XmlNode = parseXML(newStringStream(response))
    
    # Create the top level array.
    var pasteArray : array[18, seq[string]]
    
    # Loop through the list of pastes.
    for i in 0..(len(xml) - 1):
        
        # Get the paste info.
        var p1 : string = xml[i][0].innerText
        var p2 : string = xml[i][1].innerText
        var p3 : string = xml[i][2].innerText
        var p4 : string = xml[i][3].innerText
        var p5 : string = xml[i][4].innerText
        var p6 : string = xml[i][5].innerText
        var p7 : string = xml[i][6].innerText
        var p8 : string = xml[i][7].innerText
        var p9 : string = xml[i][8].innerText
        var p10 : string = xml[i][9].innerText
        
        # Add the paste info to the array.
        pasteArray[0] = @[p1, p2, p3, p4, p5, p6, p7, p8, p9, p10]
    
    # Return the list of the pastes.
    return @pasteArray


proc deletePaste*(devKey : string, userKey : string, pasteKey : string): string = 
    ## Deletes a paste.
    ##
    ## All parameters are required. Returns a status message.
    
    # Build the parameters.
    var params : string = "api_option=delete&api_dev_key=" & devKey
    params = params & "&api_user_key=" & userKey & "&api_paste_key=" & pasteKey
    
    # Delete the paste.
    var response : string = postContent("http://pastebin.com/api/api_post.php", "Content-Type: application/x-www-form-urlencoded;\c\L", params)
    
    # Returns the status message.
    return response


proc getUserInfo*(devKey : string, userKey : string): seq[string] = 
    ## Gets info about a user.
    ##
    ## All parameters are required.
    ##
    ## Returns a sequence with the information at the following indices:
    ## * 0 - user name
    ## * 1 - short format
    ## * 2 - user expiration date
    ## * 3 - avatar URL
    ## * 4 - privacy setting
    ## * 5 - website
    ## * 6 - email
    ## * 7 - location
    ## * 8 - account type
    
    # Build the parameters.
    var params : string = "api_option=userdetails&api_dev_key=" & devKey
    params = params & "&api_user_key=" & userKey
    
    # Create the paste.
    var response : string = postContent("http://pastebin.com/api/api_post.php", "Content-Type: application/x-www-form-urlencoded;\c\L", params)
    
    # Parse the XML.
    var xml : XmlNode = parseXML(newStringStream(response))
    
    # Return the user info.
    return @[xml[0].innerText, xml[1].innerText, xml[2].innerText, xml[3].innerText, xml[4].innerText, xml[5].innerText, xml[6].innerText, xml[7].innerText, xml[7].innerText]


proc getPaste*(pasteKey : string): string = 
    ## Gets a paste.
    ##
    ## Parameter is required. Returns the contents of the paste.
    
    # Get the data.
    var data : string = getContent("http://pastebin.com/raw.php?i=" & pasteKey)
    
    # Return the paste data.
    return data


proc getPasteToFile*(pasteKey : string, fileName : string): string = 
    ## Gets a paste and writes it to a file.
    ##
    ## All parameters are required. Returns the contents of the paste.
    
    # Get the data.
    var data : string = getContent("http://pastebin.com/raw.php?i=" & pasteKey)
    
    # Write the data to the file.
    write(open(fileName, fmWrite), data)
    
    # Return the paste data.
    return data
  