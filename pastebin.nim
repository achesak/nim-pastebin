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
import xmldom
import xmldomparser
import xmltree


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


proc deletePaste*(devKey : string, userKey : string, pasteKey : string): string = 
    # Deletes a paste.
    
    # Build the parameters.
    var params : string = "api_option=delete&api_dev_key=" & devKey
    params = params & "&api_user_key=" & userKey & "&api_paste_key=" & pasteKey
    
    # Delete the paste.
    var response : string = postContent("http://pastebin.com/api/api_post.php", "Content-Type: application/x-www-form-urlencoded;\c\L", params)
    
    # Returns the status message.
    return response


proc getUserInfo*(devKey : string, userKey : string): array[9, string] = 
    # Gets user info.
    
    # Build the parameters.
    var params : string = "api_option=userdetails&api_dev_key=" & devKey
    params = params & "&api_user_key=" & userKey
    
    # Create the paste.
    var response : string = postContent("http://pastebin.com/api/api_post.php", "Content-Type: application/x-www-form-urlencoded;\c\L", params)
    
    # This next part is far from ideal, but Nimrod's XML parsing capabilities
    # are rather sub-par right now, so I have to do this to get around that.
    # TODO: fix!
    
    # Remove the tags.
    response = response.replace("<user_name>").replace("</user_name>")
    response = response.replace("<user_format_short>").replace("</user_format_short>")
    response = response.replace("<user_expiration>").replace("</user_expiration>")
    response = response.replace("<user_avatar_url>").replace("</user_avatar_url>")
    response = response.replace("<user_private>").replace("</user_private>")
    response = response.replace("<user_website>").replace("</user_website>")
    response = response.replace("<user_email>").replace("</user_email>")
    response = response.replace("<user_location>").replace("</user_location>")
    response = response.replace("<user_account_type>").replace("</user_account_type>")
    
    # Split into lines.
    var response_array : seq[string] = response.splitLines()
    
    # Create the user info array.
    var info : array[9, string]
    info[0] = response_array[1]
    info[1] = response_array[2]
    info[2] = response_array[3]
    info[3] = response_array[4]
    info[4] = response_array[5]
    info[5] = response_array[6]
    info[6] = response_array[7]
    info[7] = response_array[8]
    info[8] = response_array[9]
    
    # Return the user info.
    return info    


proc getPaste*(pasteKey : string): string = 
    # Gets a paste.
    
    # Get the data.
    var data : string = getContent("http://pastebin.com/raw.php?i=" & pasteKey)
    
    # Return the paste data.
    return data


proc getPasteToFile*(pasteKey : string, fileName : string): string = 
    # Gets a paste and stores it in a file.
    
    # Get the data.
    var data : string = getContent("http://pastebin.com/raw.php?i=" & pasteKey)
    
    # Write the data to the file.
    write(open(fileName, fmWrite), data)
    
    # Return the paste data.
    return data
  