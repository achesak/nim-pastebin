# Pastebin API wrapper.

# Written by Adam Chesak.
# Code released under the MIT open source license.

# Import the formats and constants.
import pastebin_formats
import pastebin_constants

# Import modules.
import httpclient
import cgi
import strutils


proc createPaste*(devKey : string, pasteData : string, pasteName : string = "", pasteFormat : string = "", pastePrivate : int = 0, pasteExpire : string = ""): string = 
    # Creates a new paste.
    
    # Build the parameters.
    var params : string = "api_option=paste&api_dev_key=" & devKey
    params = params & "&api_paste_code=" & urlEncode(pasteData) & "&api_paste_name=" & urlEncode(pasteName)
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
    # Creates a new paste from a file.
    
    # Get the contents of the file.
    var contents : string = readAll(open(fileName))
    
    # Create the paste.
    var response : string = createPaste(devKey, contents, pasteName, pasteFormat, pastePrivate, pasteExpire)
    
    # Return either the URL or the error message.
    return response


proc createAPIUserKey*(devKey : string, userName : string, userPassword : string): string = 
    # Gets a user session key.
    
    # Build the parameters.
    var params : string = "api_dev_key=" & devKey
    params = params & "&api_user_name=" & userName & "&api_user_password=" & userPassword
    
    # Create the paste.
    var response : string = postContent("http://pastebin.com/api/api_login.php", "Content-Type: application/x-www-form-urlencoded;\c\L", params)
    
    # Return either the use key or the error message.
    return response


proc listUsersPastes*(devKey : string, resultsLimit : int = 50): string = 
    # stuff goes here


proc listTrendingPastes*(devKey : string): string = 
    # stuff goes here


proc deletePaste*(devKey : string, userKey : string, pasteKey : string): bool = 
    # stuff goes here


#proc getUserInfo*(devKey : string, userKey : string): array[] = 
#    # stuff goes here


proc getPaste*(devKey : string, pasteKey : string): string = 
    # stuff goes here


proc getPasteToFile*(devKey : string, pasteKey : string, fileName : string): string = 
    # stuff goes here
    # also return paste data

