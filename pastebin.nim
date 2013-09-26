# Main Pastebin API wrapper.

# Written by Adam Chesak.
# Code released under the MIT open source license.

# Import the constants.
import pastebin_formats
import pastebin_constants


proc createPaste*(devKey : string, pasteData : string, pasteName : string = "", pasteFormat : string = "", pastePrivate : int = 0, pasteExpire : string = ""): string = 
    # stuff goes here


proc createPasteFromFile*(devKey : string, fileName: string, pasteName : string = "", pasteFormat : string = "", pastePrivate : int = 0, pasteExpire : string = ""): string = 
    # stuff goes here


proc createAPIUserKey*(devKey : string, userName : string, userPassword : string): string = 
    # stuff goes here


proc listUsersPastes*(devKey : string, resultsLimit : int = 50): string = 
    # stuff goes here


proc listTrendingPastes*(devKey : string): string = 
    # stuff goes here


proc deletePaste*(devKey : string, userKey : string, pasteKey : string): bool = 
    # stuff goes here


proc getUserInfo*(devKey : string, userKey : string): array[] = 
    # stuff goes here


proc getPaste*(devKey : string, pasteKey : string): string = 
    # stuff goes here


proc getPasteToFile*(devKey : string, pasteKey : string, fileName : string): string = 
    # stuff goes here
    # also return paste data

