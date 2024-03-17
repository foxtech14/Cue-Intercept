-- Cue Intercept Plugin v1
-- By Michael Fox

-- ****************************************************************
-- USER CONFIG AREA - ONLY EDIT THIS BIT
-- ****************************************************************

local useOSC = true -- Do you want to send the additional OSC string?
local exeSeq = nil -- Sequence for Main list Executes
local oosEnable = true -- Enable the OOS Feature
local oosSeq = { -- Array for OOS Sync Sequences
    11,
    12,
    13,
    14
}

-- ****************************************************************
-- main plugin
-- ****************************************************************

local C = Cmd;local E = Echo
local function sendOSC(num, name)C(string.format("SendOSC 1 '/out/cue,fs,%s,%s'",num,name))end
local function findQ(b,c,d,e,f)if d>e then return f,false end;local g=math.floor((d+e)/2)local h=b[g]local i=h.no;if i==c then return i,true end;if i>c then return findQ(b,c,d,g-1,f)end;if i<c then return findQ(b,c,g+1,e,i)end end
local function main()local b=SelectedSequence()local c=b:CurrentChild()local d=c.no;local e=c.no/1000;local f=c.name;local g,h,i,j;if useOSC then sendOSC(e,f)end;if exeSeq~=nil then g=ObjectList(string.format("Sequence %s",exeSeq))h=g[1]i,j=findQ(h,d,1,h.count,1)if j then C(string.format("Goto Sequence %s Cue %s",exeSeq,e))end end;if not oosEnable then return end;for k,l in ipairs(oosSeq)do g=ObjectList(string.format("Sequence %s",l))h=g[1]local m=h:CurrentChild()i,j=findQ(h,d,1,h.count,1)if m~=nil then if i~=m.no then C(string.format("Goto Sequence %s Cue %s",l,i/1000))end end end end
return main