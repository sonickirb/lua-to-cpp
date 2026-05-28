-- qar_ty amazing lua code youve got here of all code and codes of all code

local Str = ""
local At = 0
local Look = ""
function GetChar()
  At = At + 1
  Look = string.sub(Str, At, At)
end

function View(n)
  return string.sub(Str, At+n, At+n)
end
function Read(n)
  return string.sub(Str, At, At+n)
end

require("libs/overrides")

function Error(info)
	print("\nError: " .. info .. ".")
end

function Abort(info)
	Error(info);
	print("Aborting.")
	os.exit()
end

function Expected(s)
	Abort(s .. ' Expected')
end
function IsWhitespace(c)
  return c == " " or c == "\t" or c == "\n"
end
function SkipWhitespace()
  while IsWhitespace(Look) do
    GetChar()
  end
end
function Match(x)
	if Look == x then GetChar()
	else Expected('\'' .. x .. '\'');
	end
	SkipWhitespace()
end

function IsNumber(c)
  if string.match(c, "[0-9]") then return true end
end
function IsName(c)
  if string.match(c, "[a-zA-Z]") then return true end
end

function GetNumber()
  local o = ""
  if not IsNumber(Look) and (not Look == ".") then Expected("Number") end
  local FoundAPeriod = false

  while IsNumber(Look) or (FoundAPeriod == false and Look == ".") do
    if Look == "." then FoundAPeriod = true end
    o = o .. Look
    GetChar()
  end
  SkipWhitespace()
  return tonumber(o)
end
function GetName()
  local o = ""
  if not IsName(Look) then Expected("Name") end
  while IsName(Look) do
    o = o .. Look
    GetChar()
  end
  SkipWhitespace()
  return o
end
function IsString(c)
  return c == [[']] or c == [["]] -- block strings unsupported here, but are theroretically acceptable, getstring implements them
end
function GetString()
  local o = ""
  local term = Look --[=[]=]
  GetChar()
  if term ~= [[']] and term ~= [["]] and term ~= "[" then Expected("String") end
  if term == "[" then
    if Look == "=" then
      while Look == "=" do
        term = term .. Look
        GetChar()
      end
      GetChar() -- "[" expected
    end
    else
    while Look == "[" do
      term = term .. Look
      GetChar()
    end
  end
  term = string.reverse(term)
  local termlen = #term
  if termlen > 1 then
    while View(termlen) ~= term do
      o = o .. Look
      GetChar()
    end
    At = At + termlen
  else
    while Look ~= term do
      o = o .. Look
      GetChar()
    end
    Match(term)
  end
    SkipWhitespace()
  return [["]] .. o .. [["]]
end
--local tab = {{}}
--local tab_position = tab[1]
top = nil
function base()
  if Look == "(" then -- bracket handling
    Match("(")
    local r = top()
    Match(")")
    return r
  end
  if IsNumber(Look) then
    -- Emit Number
    return {GetNumber()}
  elseif IsString(Look) then
    return {GetString()}
  elseif IsName(Look) then
    -- Emit Name
    local Na = GetName()
    if Na == "local" then
      local VariableName = GetName()
      Match("=")
      return {Na, {VariableName}, top()} -- variablename is in a table so it can be expanded to multi-variable assignments l8r
    elseif Look == "=" and View(1) ~= "=" then -- global assign
      Match("=")
      return {"global", {Na}, top()}
    elseif Na == "false" then
      return {false}
    elseif Na == "true" then
      return {true}
    elseif Na == "nil" then
      return {nil}
    elseif Na == "not" then
      return {"not", top()}
    else
      return {Na}
    end
  elseif Look == "" then
  end
end
function priority_1()
  local parameter_1 = base()
  while Look == "(" do
    Match("(")
    local args = {}
    while Look ~= ")" do
      table.insert(args, top())
      if Look == "," then Match(",") end
    end
    Match(")")
    parameter_1 = {"call", parameter_1, args}
  end
  return parameter_1
end
function priority_2()
  local parameter_1 = priority_1()
  while Look == "^" do
    Match("^")
    --table.insert(tab_position, {"^", parameter_1, {})
    parameter_1 = {"^", parameter_1, priority_1()}
  end
  return parameter_1
end
function priority_3()
  local parameter_1 = priority_2()
  if Look == "~" then
    Match("~")
    return {"~", parameter_1}
  elseif Look == "#" then
    Match("#")
    return {"#", parameter_1}
  elseif Look == "-" then
    Match("-")
    return {"-", parameter_1}
  end
  return parameter_1
end
function priority_4()
  local parameter_1 = priority_3()
  while Look == "*" or Look == "/" or Look == "%" or Look == "/" and View(1) == "/" do
    local Op = Look
    GetChar()
    if Op == "/" and Look == "/" then Op = Op .. Look GetChar() end
    SkipWhitespace()
    parameter_1 = {Op, parameter_1, priority_3()}
  end
  return parameter_1
end
function priority_5()
  local parameter_1 = priority_4()
  while Look == "+" or Look == "-" do
    local Op = Look; GetChar() SkipWhitespace()
    parameter_1 = {Op, parameter_1, priority_4()}
  end
  return parameter_1
end

top = priority_5

function CreateLinesTable(lua)
  Str = lua
  GetChar()
  local o = {}
  while Look ~= "" do
    table.insert(o, top())
  end
  return o
end


Str = [[print("hello", 1+2+3+4+5) 1 2 3]]

--print(CreateLinesTable())
