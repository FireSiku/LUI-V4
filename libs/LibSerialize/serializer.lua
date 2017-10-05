local MAJOR,MINOR = "LibSerialize", 2;
local LibSerialize, oldminor = LibStub:NewLibrary(MAJOR, MINOR);

--[[
E	empty string
S	new plain string (no need for escaping)
W	new escaped string

*	nil value
!	NaN		
0	0 (exact zero)
1	1 (exact one)
.  .
.  .
9	9 (exact nine)
I  inf
i	-inf
N	number from tostring function
B  positive number in big base
b  negative number in big base

F  positive double precison float
f  negative double precison float

D function declaration

T	new table
Q  empty table

+ boolean true
- boolean false

R reference

Vv protocol version
]]--

local tinsert,type,format,find,gsub,concat,char,byte,modf,frexp,floor=tinsert,type,string.format,string.find,string.gsub,table.concat,string.char,string.byte,math.modf,math.frexp,math.floor;
local INF = math.huge
local NaN = INF*0

function LibSerialize:InitSera()
local sera={refs={[1]={};arrcnt=0;refcnt=0;curarr=1};serialized={""};row=1;rowcount=0};
	return sera;
end;

function LibSerialize:AppendSera(sera,datatype,data)
	
	if sera.row > 5000 then
		sera.serialized ={concat(sera.serialized)};		
		sera.row=1;	
		end;
	sera.row=sera.row+1;
	sera.serialized [sera.row] = "~"..datatype..(data or "");	
end;

function LibSerialize:FinishSera(sera)
	sera.serialized  =concat(sera.serialized);
end;

local num2char={};
for i=0,99 do num2char[i]=char(i+26);end; 


local function num2big (number)
   local res="";
   local sign=1;
   if number<0 then  sign=-1;  number=abs(number); end;
   while number>99 do
      res=num2char[number % 100]..res;
      number=floor(number/100);
      end;
   res=num2char[number]..res;
   return res,sign; 
end;

local function big2num (big,sign)
	sign=sign or 1;
   local res=0;
   for i=1,#big do
      res=res*100+byte(big,i)-26;
   end;    
   return sign*res; 
end;

local function format_index(number)
	return num2big (number);
end;

local function checkref (sera,anIt)
	local refs=sera.refs;
	local ref; 
	for i=1,refs.curarr do 
		ref=refs[i][anIt];
		if ref~=nil then return ref,true;end;
		end;
	return nil,false;
end;

local function getref (sera,anIt)
	local refs=sera.refs;
	local ref; 
	for i=1,refs.curarr do 
		ref=refs[i][anIt];
		if ref~=nil then return ref,true;end;
		end;
	if refs.arrcnt<65535 then
		refs.arrcnt=refs.arrcnt+1;
		else
		refs.arrcnt=0;
		refs.curarr=refs.curarr+1;
		sera.refs[refs.curarr]={};
		end;
	refs.refcnt=refs.refcnt+1;
	ref=format_index(refs.refcnt);
	sera.refs[refs.curarr][anIt]=ref;
	return ref,false;
end;

local function getdesref (sera,anIt)
	local refs=sera.refs;
	local ref; 
	for i=1,refs.curarr do 
		ref=refs[i][anIt];
		if ref~=nil then return ref,true;end;
		end;
	if refs.arrcnt<65535 then
		refs.arrcnt=refs.arrcnt+1;
		else
		refs.arrcnt=0;
		refs.curarr=refs.curarr+1;
		sera.refs[refs.curarr]={};
		end;
	refs.refcnt=refs.refcnt+1;
	ref=format_index(refs.refcnt);
	sera.refs[refs.curarr][anIt]=ref;
	return ref,false;
end;


local function numtostring(aNumber)  
	if (modf(aNumber))==aNumber then -- integer?		
		local big,sign=num2big(aNumber);		
		return big,((sign<0) and "b" or "B");
		else
		local numstr=tostring(aNumber);
		if tonumber(numstr)==aNumber then
			return numstr,"N";
			else
			local m,e=frexp(aNumber);
			return format("%s\025%d",(num2big (abs(m)*2^53)),e-53),(m<0) and "f" or "F";
			end;
		end;
end;


function LibSerialize:Serialize_string (sera,aString)
	local ref,refok= getref (sera,aString);
	if refok then
		self:AppendSera (sera,"R",ref);			
	else						
		if find(aString, "%~")==nil then
			self:AppendSera (sera,"S",aString);				
			else
			local replaces;
			aString,replaces=gsub(aString, "\\", "\\e"); --\\ make the escape char free :)
			aString,replaces=gsub(aString, "%~", "\\!");
			self:AppendSera (sera,"W",aString);
			end;
	end;
end;

function LibSerialize:DeSerialize_escapedstring(sera,stype,sdata)
	sera.refcnt=sera.refcnt+1;
	local refindex=format_index(sera.refcnt);
	sera.refs[refindex]="";
	local newstring=sdata;
	newstring=gsub(newstring, "\\!", "~");
	newstring=gsub(newstring, "\\e", "\\"); --undo the escape char escapping 					
	sera.refs[refindex]=newstring;
	return newstring;     
end;

function LibSerialize:DeSerialize_simplestring(sera,stype,sdata)
	sera.refcnt=sera.refcnt+1;
   sera.refs[format_index(sera.refcnt)]=sdata;
   return sdata;
end;


function LibSerialize:DeSerialize_ref(sera,stype,sdata)
	return sera.refs[sdata];
end;


local serdirectarr={ --switch array   
   [0]="0";
   [1]="1";
   [2]="2";
   [3]="3";
   [4]="4";
   [5]="5";
   [6]="6";
   [7]="7";
   [8]="8";
   [9]="9";
   [10]="A";      
   [(INF)]="I";
   [(-INF)]="i";
   [""]="E";
   [true]="+";
   [false]="-";
};

function LibSerialize:Serialize_number (sera,aNumber)
	local sNumber,stype=numtostring(aNumber);
	self:AppendSera (sera,stype,sNumber);		
end;

local function numberfromfloat(sdata)
	local m,e=string.match(sdata, "([^\025]+)\025([+-]*%d*)");
	return ldexp(big2num(m),e or 0);
end;


function LibSerialize:DeSerialize_number(sera,stype,sdata)
	return (stype=="F" and numberfromfloat(sdata))or (stype=="f" and -numberfromfloat(sdata)) or tonumber(sdata); 
end;

function LibSerialize:DeSerialize_numberbig(sera,stype,sdata)
	return (stype=="B" and big2num(sdata)) or (stype=="b" and -big2num(sdata)); 	
end;


function LibSerialize:Serialize_function (sera,aFunction)
	local ref,refok= getref (sera,aFunction);
	if refok then
		self:AppendSera (sera,"R",ref);					      
		else      		
		self:AppendSera (sera,"D");
		self:Serialize_any(sera,string.dump(aFunction));--well..that got to do for a moment
		end;
end;

function LibSerialize:Serialize_table (sera,aTable)
	local ref,refok= getref (sera,aTable);
	if refok then
		self:AppendSera (sera,"R",ref);					      
		elseif next(aTable) == nil then
			self:AppendSera (sera,"Q");
		else
		self:AppendSera (sera,"T");
		for key, value in pairs (aTable) do
			self:Serialize_any (sera,key);
			self:Serialize_any (sera,value);         
			end;
		self:AppendSera (sera,"t");
		end;
end;

function LibSerialize:DeSerialize_table(sera,stype,sdata,tokenizer)
   local newtable={};
   sera.refcnt=sera.refcnt+1;
   sera.refs[format_index(sera.refcnt)]=newtable;
   if stype=="T" then
	   stype,sdata=tokenizer();      
      while stype~="t" do                 
         local key=self:DeSerialize_any(sera,stype,sdata,tokenizer);
         stype,sdata=tokenizer();
         newtable [key] = self:DeSerialize_any(sera,stype,sdata,tokenizer);
         stype,sdata=tokenizer();
      end;
      end;
   return newtable;   
end;

function LibSerialize:DeSerialize_function (sera,stype,sdata,tokenizer)
	local fdef=self:DeSerialize_any(sera,stype,sdata,tokenizer);	
	local newfunction = loadstring (fdef);
	sera.refcnt=sera.refcnt+1;
   sera.refs[format_index(sera.refcnt)]=newfunction;
	return newfunction;
end;


local serarr={ --switch array
   ["string"]=LibSerialize.Serialize_string;
   ["number"]=LibSerialize.Serialize_number;
   ["table"]=LibSerialize.Serialize_table;
   ["function"]=LibSerialize.Serialize_function;   
};
function LibSerialize:Serialize_any (sera,anItem)
	local direct=((anItem==nil) and "*") or ((anItem~=anItem) and "!") or serdirectarr[anItem]; 
	
	if type(direct)=="string" then self:AppendSera (sera,direct);
	  else
	  local ref,refok= checkref (sera,anItem);
	  if refok then self:AppendSera (sera,"R",ref);
	     else
	     local anItemType=type(anItem);
	     local handler=serarr[type(anItem)];
	     if type(handler)=="function" then handler (self,sera,anItem);end;
	  end;
	end;
end;



function LibSerialize:Serialize (anItem)
	local sera;
	sera=self:InitSera();
	self:AppendSera (sera,"V","5");
	self:Serialize_any(sera,anItem);
	self:AppendSera (sera,"v");
	self:FinishSera(sera);
	return sera.serialized;   
end;

--and deserialization
local deserarr={ --switch array
   ["+"]=true;
   ["-"]=false;
   ["0"]=0;
   ["1"]=1;
   ["2"]=2;
   ["3"]=3;
   ["4"]=4;
   ["5"]=5;
   ["6"]=6;
   ["7"]=7;
   ["8"]=8;
   ["9"]=9;
   ["A"]=10;   
   ["I"]=(INF);
   ["i"]=(-INF);
   ["!"]=(NaN);
   ["*"]=nil;
   ["N"]=LibSerialize.DeSerialize_number;
   ["F"]=LibSerialize.DeSerialize_number;
   ["f"]=LibSerialize.DeSerialize_number;
   ["B"]=LibSerialize.DeSerialize_numberbig;
   ["b"]=LibSerialize.DeSerialize_numberbig;   
   ["E"]="";
   ["W"]=LibSerialize.DeSerialize_escapedstring;
   ["S"]=LibSerialize.DeSerialize_simplestring;    
   ["Q"]=LibSerialize.DeSerialize_table;
   ["T"]=LibSerialize.DeSerialize_table;
   ["D"]=LibSerialize.DeSerialize_function;
   ["R"]=LibSerialize.DeSerialize_ref;
};

function LibSerialize:DeSerialize_any(sera,stype,sdata,tokenizer)
   local handler=sera.handlers[stype];
   if type(handler)=="function" then return handler (self,sera,stype,sdata,tokenizer); else return handler; end;
end;



function LibSerialize:DeSerialize (anSerializedItem)
   local sera={handlers=deserarr;refs={};refcnt=0};
   local result=anSerializedItem;
   local tokenizer=string.gmatch(anSerializedItem, "[^~]-[~](.)([^~]*)");
   local stype,sdata=tokenizer();
   if stype=="V" and sdata=="5" then
   	stype,sdata=tokenizer();
		result = self:DeSerialize_any(sera,stype,sdata,tokenizer);
		stype,sdata=tokenizer();
   	end;
   return result;   
end;

local function CompareByValue (t1,t2)    
   local ty = type(t1);    
   if ty ~= type(t2) then return false end;
   if t1==t2 then return true;end;
   if ty ~= 'table' then return t1 == t2 end;
   
   local cnt=0; 
   local tablecnt=0; 
   for k1,v1 in pairs(t1) do
   	local v2 = t2[k1];
   	if v2 == nil then return false end;
   	cnt=cnt+1;
      if type(v1)~= 'table' then 
         if not CompareByValue(v1,v2) then return false end
         else
         tablecnt=tablecnt+1;
      end;      
   end
   
   if tablecnt>0 then   
		for k1,v1 in pairs(t1) do
			if type(v1)== 'table' then 
				local v2 = t2[k1];
				if not CompareByValue(v1,v2) then return false end
			end
		end;
	end;
   
   if #t1 ~= #t2 then return false end;
   
   for k2,v2 in pairs(t2) do cnt=cnt-1; end;
   return cnt==0;
end;


function LibSerialize:DoCheck (testdata)
	local test=self:Serialize(testdata);
	return CompareByValue (testdata,self:DeSerialize(test));      
end;


