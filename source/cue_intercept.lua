-- BBLX Cue Intercept Plugin v1
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
-- local plugin variables
-- ****************************************************************

local C = Cmd -- Execute commandline string
local E = Echo -- Echo to System Monitor


-- ****************************************************************
-- sendOSC(number, string)
-- ****************************************************************

local function sendOSC(num, name)
    C(string.format("SendOSC 1 '/out/cue,fs,%s,%s'",num,name))
end


-- ****************************************************************
-- findQ(array, number, number, number, number) : number, boolean
-- ****************************************************************

local function findQ(array, target, first, last, lower)
    if (first > last) then return lower, false end

    local middle = math.floor((first + last)/2)
    local q = array[middle]
    local i = q.no

    if (i == target) then return i, true end

    if (i > target) then
        return findQ(array, target, first, middle-1, lower)
    end

    if (i < target) then
        return findQ(array, target, middle+1, last, i)
    end
end


-- ****************************************************************
-- main plugin entry point
-- ****************************************************************

local function main()
    local mySequence = SelectedSequence()
    local cueTX = mySequence:CurrentChild()

    local rawNum = cueTX.no -- MA integer cue number x1000
    local oscNum = cueTX.no/1000 -- Floating point Cue Number
    local cueName = cueTX.name -- Current selected sequence cue name

    local object, seq, found, exact

    if (useOSC) then sendOSC(oscNum, cueName) end

    if (exeSeq ~= nil) then
        object = ObjectList(string.format("Sequence %s", exeSeq))
        seq = object[1]
        found, exact = findQ(seq, rawNum, 1, seq.count, 1)

        if (exact) then
            C(string.format("Goto Sequence %s Cue %s", exeSeq, oscNum))
        end
    end

    if (not oosEnable) then
        return
    end

    for i,v in ipairs(oosSeq) do
        object = ObjectList(string.format("Sequence %s", v))
        seq = object[1]
        local current = seq:CurrentChild()
        found, exact = findQ(seq, rawNum, 1, seq.count, 1)

        if (current ~= nil) then
            if (found ~= current.no) then
                C(string.format("Goto Sequence %s Cue %s", v, found/1000))
            end
        end
    end
end

return main