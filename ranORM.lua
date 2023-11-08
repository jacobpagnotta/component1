-- This module is used to help generate random HL7
-- data using the translator.

-- http://help.interfaceware.com/v6/random-message-generator

-- seed data used for generation
local data = {}
data.Sex = {'M', 'F', 'N', 'S'}
data.AltSex = {'Male', 'Female', 'Neutered', 'Spayed'}
data.LastNames = {'Muir','Smith','Adams','Garland', 'Meade', 'Fitzgerald', 'White', 'Clarke', 'Doe', 'Green', 'Henry', 'Gomez'}
data.MaleNames = {'Fred','Rudy','Gary','Tyler', 'Beaumont', 'Kai', 'Lucas', 'Riley', 'Nicholas', 'Sid', 'Cody'}
data.FemaleNames = {'Mary','Sabrina','Hannah', 'Allie', 'Sarah', 'Maxine', 'Haley', 'Terry', 'Charlie', 'Sheena', 'Sadie', 'Jane'}
data.Street = {'Delphi Crescent', 'Miller Lane', 'Yonge Street', 'Main Road', 'Sixth Avenue', 'Forty Second Street', 'Gwendolyn Avenue'}
data.Relation = {'Grandchild', 'Second Cousin', 'Sibling', 'Parent'}
data.Language = {'English', 'Spanish', 'Cantonese', 'Greek', 'Russian', 'French', 'Hindi'}
data.Species = {{'Canine', 'French Bulldog'},{'Feline', 'Callico'}, {'Canine', 'Poodle'}, {'Equus', 'Arabian'}, {'Feline', 'Maine Coon'}}
data.Event = {'O01'}
data.Facility = {'Lab', 'E&R'}
data.Application = { 'AcmeMed', 'MedPoke', 'Epic', 'Cerner' }
data.Locations = { {'Chicago', 'IL'}, {'Toronto', 'ON'}, {'ST. LOUIS', 'MO'}, {'LA', 'CA'}, {'Ann Arbor','MI'}, {'Montreal','QC'}, {'Ann Arbor','MI'} }
data.Insurance = {{'ABC Insurance', '123456'}, {'XYZ Insurance', '987654'}}
data.Order = {{'24762-7', 'X-ray Hip'}, {'41806-1', 'CT Abdomen'}, {'5794-3', 'Urinalysis'}, {'2345-7', 'Glucose Test'}, {'67183-4', 'Laparoscopy'}, {'27895-2 ', 'Gastroscopy'}, {'38766-2', 'Kidney Biopsy'}, {'718-7', 'Haemoglobin Test'}}
data.Result = {{'Abnormal', 'High levels'}, {'Normal', 'Clear'}}

local function rand(In, Max, Size)
   local Result = tostring((In + math.random(Max)) % Max)
   if '0' == Result then
      Result = '1'
   end
   
   while Size > Result:len() do
      Result = '0'..Result
   end
   return Result
end

local function ranChoose(T)
   return T[math.random(#T)]
end

local function ranTimeStamp()
   local T = os.date('*t')
   
   local newDate = '20'..rand(T.year,tostring(T.year):sub(-2),2)..
   rand(T.month,12,2)..
   rand(T.day,29,2)..
   rand(T.hour,12,2)..
   rand(T.min,60,2)..
   rand(T.sec,60,2)
   
   return newDate
end

local function ranNameAndSex(PID)
   if math.random(2) == 1 then
      PID[8] = 'M'
      PID[5][1][2] = ranChoose(data.MaleNames)
   else   
      PID[8] = 'F'
      PID[5][1][2] = ranChoose(data.FemaleNames)      
   end
end

local function ranLastName() return ranChoose(data.LastNames) end

local function ranDate()
   local T = os.date('*t')
  
   local newDate = '19'..rand(T.year,99,2)..
   rand(T.month,12,2)..
   rand(T.day,29,2)
   
   return newDate
end

local function ranAcctNo()
   return math.random(99)..'-'..math.random(999)..'-'..math.random(999)
end

local function ranLocation()
   local R = ranChoose(data.Locations)
   return R[1], R[2]
end

local function ranSpecies()
   local R = ranChoose(data.Species)
   return R[1], R[2]
end

local function ranResult()
   local R = ranChoose(data.Result)
   return R[1], R[2]
end

local function ranSSN()
   return math.random(999)..'-'
          ..math.random(999)..'-'
          ..math.random(999)
end

local function ranFirstName()
   if math.random(2) == 1 then
      return ranChoose(data.MaleNames)
   else   
      return ranChoose(data.FemaleNames)      
   end
end

local function ranInsuranceCo()
   local R = ranChoose(data.Insurance)
   return R
end 

local function ranAltSex()
local R = ranChoose(data.AltSex)
   return R
end


local function ranLanguage()
   local R = ranChoose(data.Language)
   return R
end 

local function ranNTE()
   local R = ranChoose(data.AltSex)
   return R
end 

local function ranScrubMSH(MSH)
   MSH[3][1] = ranChoose(data.Application)
   MSH[4][1] = ranChoose(data.Facility)
   MSH[5][1] = 'Main HIS'
   MSH[6][1] = 'St. Micheals'
   MSH[7][1] = ranTimeStamp()
   MSH[9][1] = 'ORM'
   MSH[9][2] = ranChoose(data.Event)
   MSH[10] = util.guid(256)
   MSH[11][1] = 'P'
   MSH[12][1] = '2.6'
   MSH:S()
end


local function ranScrubPID(PID)
   PID[3][1][1] = math.random(999999)
   ranNameAndSex(PID)
   PID[5][1][1][1] = ranLastName()
   PID[7][1] = ranDate()
   PID[18][1] = ranAcctNo()
	PID[15][1] = ranLanguage()
   PID[11][1][3], PID[11][1][4] = ranLocation()
   PID[11][1][5] = math.random(99999)
   PID[11][1][1][1] = math.random(999)..
      ' '..ranChoose(data.Street)
   PID[19] = ranSSN()
   --PID[35][2], PID[36][2] = ranSpecies() 
   PID:S()
end

local function ranPV1(PV1)
   PV1[2] = 'I'
   PV1[8][1][2][1] = ranLastName()
   PV1[8][1][3] = ranFirstName()
   PV1[8][1][4] = 'F'
   PV1[19][1] = math.random(9999999)
   PV1[44][1] = ranTimeStamp()
   PV1:S()
end

local function ranIN1(IN1)
   IN1[1] = math.random(9999)
   IN1[2][1] = math.random(999999)
   local r = ranInsuranceCo()
   IN1[3][1][1] = r[2]
   IN1[4][1][1] = r[1]
   IN1:S()
end

local function ranORC(ORC)
   ORC[1] = 'RE'
   ORC[2][1] = math.random(99999)
   ORC:S()
end

local function ranOBR(OBR)
	local r = ranChoose(data.Order)
   OBR[1] = '1'
   OBR[2][1] = math.random(9999)
   OBR[2][2] = 'LabTech'
   OBR[3][1] = math.random(9999)
   OBR[3][2] = 'ABC Labs'
   OBR[6] = ranTimeStamp()
   OBR[4][1] = r[1]
   OBR[4][2] = r[2]
   OBR:S()
end

local function ranOBX(OBX)
   local r = ranChoose(data.Result)
   OBX[1] = '1'
   OBX[2] = 'TX'
   OBX[3][1] = 'SR Text'
   OBX[8][1], OBX[5][1][2] = ranResult()
   OBX[19] = ranTimeStamp()
   end 

local function RandomMessage()
   local Out = hl7.message{vmd='random/generator.vmd', name='Lab'} 
   ranScrubMSH(Out.MSH)
   --Out.MSH = nil
   ranScrubPID(Out.PATIENT.PID)
   ranPV1(Out.PATIENT.PATIENT_VISIT.PV1)
   ranIN1(Out.PATIENT.INSURANCE[1].IN1)
   ranORC(Out.ORDER[1].ORC)
   ranOBR(Out.ORDER[1].ORDER_DETAIL.OBR)
   ranOBX(Out.ORDER[1].ORDER_DETAIL.OBSERVATION[1].OBX)
   return Out:S()   
end




local HELP_DEF={
   SummaryLine = "Generates HL7 sample messages",
   Desc = "Generates sample HL7 ORM messages from the seed data (hard-coded into the module)",
   Usage = "ran.RandomMessage()",
   ParameterTable=false,
   Parameters = none,
   Returns = {{Desc='A generated HL7 ORM message <u>string</u>'}},
   Title = 'ran.RandomMessage',  
   SeeAlso = {{Title='Source code for the ran.lua module on github', Link='https://github.com/interfaceware/iguana-tools/blob/master/shared/ran.lua'},
      {Title='HL7 Random Message Generator', Link='http://help.interfaceware.com/v6/random-message-generator'}},
   Examples={'data=ran.RandomMessage()'}
}
 
help.set{input_function=RandomMessage,help_data=HELP_DEF}

return RandomMessage