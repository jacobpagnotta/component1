--[[
If you have old code from Iguana 6 it might access
APIs which no longer make sense in Iguana X.

It's overwhelming trying to port code and have
everything break on you.  So iguana_shim.lua is intended
to re-create the old APIs in a manner you deal with
these older calls in your own time.

THIS CODE IS MEANT TO BE TEMPORARY!!!!!!
IF IT IS 2025 and you are still shipping your interfaces with it then you are DOING SOMETHING WRONG

The purpose of this library is to enable you to more easily port your code to Iguana X by not having
an overwhelming number of things break when you import your code.

The smart way to use this file is to gradually delete each 'shim' function which simulates an old Iguana 6 routine
and modify your own code not to use these old API calls.

When you have done that - you can delete the shim library.

See https://interfaceware.atlassian.net/wiki/spaces/IXB/pages/2657845249/Iguana+shim.lua
]]



--[[ 
Mea culpa.  One of mistakes we made with Iguana 6 was to replace
the built in os.time, os.date and os.difftime functions with our
own implementation.  I have generally advised clients to stick with
the vanilla APIs from Lua - we put them into a different spot under
the os.ts namespace.  For Iguana X we removed the implementations
we had and moved those APIs back to their rightful spot
but it's common for client code to be accessing the new place
we put these functions.  Reach out if you have more questions - Eliot
]]

os.ts ={}
os.ts.time = os.time
os.ts.date = os.date
os.ts.difftime = os.difftime
os.ts.gmtime = os.time

-- These are all functions that relate to channels
-- which obviously don't exist in Iguana 6....

iguana.setChannelStatus = function(T)
   component.setStatus{data=T.text}
   -- TODO handle light
end

iguana.channelName = function()
   return "ChannelNameDepreciated"
end

iguana.project = {}

iguana.project.root = function()
   return "components".."/".."repository".. "/";
end

iguana.project.guid = function()
   return iguana.translatorGuid()
end

iguana.channelGuid = function()
   return iguana.translatorGuid()
end

iguana.channelConfig = function()
    return "<channel></channel>"
end

--We have a better help system than the Iguana 6 one
--The new system is simpler and has a GUI editor.

help = {}

help.set = function(T)
   _help[T.input_function] = T.help_data
end

help.get = function(T)
   function FILread(FileName)
      local F = io.open(FileName,'rb')
      Result = F:read("*a")
      F:close()
      return Result
   end
   if _help[T] then 
      return FILread(_help[T])
   end
end

help.example = function()
   return json.parse{data=[[{
   "SeeAlso": [{"Title": "Title of a webpage for more information", "Link": "http://mydomain/my_extra_help.html"}],
   "Returns": [
      { "Desc": "What the function returns, e.g. 'string'"},
      {"Desc": "A second return value, e.g. 'number'"}
   ],
   "Title": "Typically the full path to the function, e.g. 'string.gsub'",
   "Parameters": [
      {"parameter_name_1": {"Desc": "Description of the first parameter"}},
      {"parameter_name_2": {"Desc": "Description of the optional second parameter", "Opt": true}}
   ],
   "ParameterTable": "Set this to true or false depending on how the function takes parameters.",
   "Usage": "A declaration of the function with the expected parameters, e.g. 'string.gsub (s, pattern, repl [, n])'",
   "Examples": ["An example invocation, e.g. x = string.gsub(\"hello world\", \"(%w+)\", \"%1 %1\")"],
   "Desc": "A description of the function and what it does. e.g. 'Replaces substrings in a string"
}]]}
end


_EnvVarList = {}
-- WHY DO WE DO THIS?
-- In working with customers we frequently ran into problems running scripts without environmental variables defined
-- So this shim sets them to something obviously wrong and builds up a catalogue of variables in _EnvVarList
_GetEnv = os.getenv
os.getenv = function(K)
   local X = _GetEnv(K)

   if (X == nil) then 
      X = "ENVIRONMENTAL VARIABLE "..K.." is not defined - this is in iguana_shim.lua!"
    end
    _EnvVarList[K] = X
    return X
end
_help[os.getenv] = _help[_GetEnv]

_HL7parse = hl7.parse
hl7.parse = function(T)
   if os.posix() then
      T.vmd = T.vmd:gsub("\\","/")
   end
   local Success, Msg, Errors = pcall(_HL7parse, T)
   if (not Success) then
      error(Msg, 2)
   end
   return Msg, Errors
end
_help[hl7.parse] = _help[_HL7parse]	


_HL7message = hl7.message
hl7.message = function(T)
   if os.posix() then
      T.vmd = T.vmd:gsub("\\","/")
   end
   local Success, Msg, Errors = pcall(_HL7message, T)
   if (not Success) then
      error(Msg, 2)
   end
   return Msg, Errors
end
_help[hl7.message] = _help[_HL7message]

dbs = {}

dbs.init = function(T)
   local FileName = T.filename:gsub(".dbs", ".vdb")
	local Out = {}
	Out.tables = function()
	   return db.tables{vdb=FileName}
	end
   return Out
end