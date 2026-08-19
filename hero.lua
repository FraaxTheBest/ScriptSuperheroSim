warn("[XTRACE] START")

local URL =
"https://raw.githubusercontent.com/TrixAde/scripts/main/superheosim.lua"

local events={}
local order={}
local total=0

local function record(s)
    total=total+1

    if not events[s] then
        events[s]=0
        order[#order+1]=s
    end

    events[s]=events[s]+1

    if total>10000 then
        error("XTRACE EVENT LIMIT")
    end
end

local MT={}

local function proxy(path)
    return setmetatable({
        __path=path
    },MT)
end

local function show(v)
    if type(v)=="table"
    and getmetatable(v)==MT then
        return v.__path
    end

    if type(v)=="string" then
        return string.format("%q",v)
    end

    return tostring(v)
end

MT.__tostring=function(a)
    return a.__path
end

MT.__index=function(a,k)
    local p=a.__path.."."..tostring(k)
    record("GET "..p)
    return proxy(p)
end

MT.__newindex=function(a,k,v)
    record(
        "SET "..
        a.__path.."."..tostring(k)..
        " = "..show(v)
    )
end

MT.__call=function(a,...)
    local n=select("#",...)
    local args={}

    for i=1,n do
        args[#args+1]=show(select(i,...))
    end

    record(
        "CALL "..a.__path..
        "("..table.concat(args,", ")..")"
    )

    if a.__path=="game.GetService"
    and n>=2 then
        return proxy(
            "game:GetService("..
            show(select(2,...))..
            ")"
        )
    end

    return proxy(a.__path.."()")
end

MT.__add=function(a,b)
    return proxy("("..show(a).."+"..show(b)..")")
end

MT.__sub=function(a,b)
    return proxy("("..show(a).."-"..show(b)..")")
end

MT.__mul=function(a,b)
    return proxy("("..show(a).."*"..show(b)..")")
end

MT.__div=function(a,b)
    return proxy("("..show(a).."/"..show(b)..")")
end

MT.__mod=function(a,b)
    return proxy("("..show(a).."%"..show(b)..")")
end

MT.__pow=function(a,b)
    return proxy("("..show(a).."^"..show(b)..")")
end

MT.__unm=function(a)
    return proxy("(-"..show(a)..")")
end

MT.__concat=function(a,b)
    return proxy("("..show(a)..".."..show(b)..")")
end

MT.__len=function()
    return 0
end

MT.__eq=function(a,b)
    return show(a)==show(b)
end

MT.__lt=function()
    return false
end

MT.__le=function()
    return false
end


-- ambiente completamente finto dato al programma Xen

local ENV={}

ENV.game=proxy("game")

ENV.wait=function(...)
    local n=select("#",...)
    local args={}

    for i=1,n do
        args[#args+1]=show(select(i,...))
    end

    record(
        "CALL wait("..
        table.concat(args,", ")..
        ")"
    )

    return 0
end

ENV.getfenv=function()
    return ENV
end

ENV.getrenv=function()
    return ENV
end

ENV.PROTOSMASHER_LOADED=false

ENV.debug=debug
ENV.string=string
ENV.table=table
ENV.math=math
ENV.pairs=pairs
ENV.ipairs=ipairs
ENV.type=type
ENV.tostring=tostring
ENV.tonumber=tonumber
ENV.select=select
ENV.pcall=pcall
ENV.xpcall=xpcall
ENV.print=function(...)
    record("PAYLOAD PRINT")
end

ENV.warn=ENV.print

ENV.unpack=unpack or table.unpack
ENV._G=ENV

setmetatable(ENV,{
    __index=function(_,k)
        local safe={
            next=next,
            assert=assert,
            error=error,
            rawequal=rawequal,
            rawget=rawget,
            rawset=rawset,
            setmetatable=setmetatable,
            getmetatable=getmetatable
        }

        if safe[k]~=nil then
            return safe[k]
        end

        record(
            "UNKNOWN_GLOBAL "..tostring(k)
        )

        return proxy(
            "GLOBAL."..tostring(k)
        )
    end
})

_G.__XENV=ENV


-- scarica Xen
local src=game:HttpGet(URL)

-- impedisce l'esecuzione immediata del payload
local patched,n=
    src:gsub("%(%s*%)%s*$","",1)

if n~=1 then
    warn("[XTRACE] FINAL CALL PATCH FAIL")
    return
end

patched=patched:gsub("%s+$","")

-- sostituisce l'ambiente reale con quello finto
local suffix=",getfenv())"

if patched:sub(-#suffix)~=suffix then
    warn("[XTRACE] ENV PATCH FAIL")
    return
end

patched=
    patched:sub(1,#patched-#suffix)
    ..",__XENV)"

patched=
    "local __XENV=_G.__XENV;"
    ..patched

local compiled,err=
    loadstring(patched)

if not compiled then
    warn("[XTRACE] LOAD FAIL",err)
    return
end

local ok,vm,chunk=
    pcall(compiled)

if not ok then
    warn("[XTRACE] PARSE FAIL",vm)
    return
end

warn(
    "[XTRACE] DECODED",
    type(vm),
    type(chunk)
)

local ok2,result=
    pcall(vm)

warn(
    "[XTRACE] VM FINISHED",
    ok2,
    tostring(result)
)

warn("")
warn("========== [XTRACE] SUMMARY ==========")

for i,s in ipairs(order) do
    warn(
        "[XTRACE]",
        "COUNT",events[s],
        s
    )
end

warn("[XTRACE] EVENTS",total)
warn("========== [XTRACE] END ==========")
