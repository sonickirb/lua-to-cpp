-- qar_ty amazing lua code youve got here of all code and codes of all code

local Str = ""
local At = 0
local Look = ""
local SkipWhitespace
function GetChar()
  At = At + 1
  Look = string.sub(Str, At, At)
  if string.sub(Str, At, At + 1) == "--" then
    while Look ~= "\n" do
      GetChar()
    end
    GetChar() SkipWhitespace()
  end
end

function View(n)
  return string.sub(Str, At+n, At+n)
end
function Read(n)
  return string.sub(Str, At, At+(n-1))
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
  if string.match(c, "[a-zA-Z_]") then return true end
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
  while IsName(Look) or IsNumber(Look) do
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
    while Read(termlen) ~= term do
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
    elseif Na == "return" then
      return {"return", top()}
    elseif Na == "function" then
      local fname = GetName()
      Match("(")
      local fparam_names = {}
      while Look ~= ")" do
        table.insert(fparam_names, GetName())
        if Look == "," then Match(",") end
      end
      Match(")")
      local o = {}
      while Read(3) ~= "end" do -- IF YOU CHANGE THIS, CHANGE THE DO CODE!
        table.insert(o, top())
      end
      Match("e")Match("n")Match("d")

      return {"function", fname, fparam_names, o}
    elseif Na == "while" then
      return {"while", top(), top()}
    elseif Na == "break" then
      return {"break"}
    elseif Na == "do" then
      --print("hiiii")
      -- [code block]
      local o = {}
      while Read(3) ~= "end" do -- IF YOU CHANGE THIS, CHANGE THE FUNCTIONS CODE!
        table.insert(o, top())
      end
      Match("e")Match("n")Match("d")
      return o
    elseif Na == "if" then
          --print(Look, Read(30))
      local condition = top()
      --print(condition)
      --print(Look, Read(30))
      if GetName() ~= "then" then Expected("then") end
      local o = {"if"}
      local current_t = {condition, {}}
      while Read(3) ~= "end" do
        while Read(6) ~= "elseif" and Read(3) ~= "end" do
          table.insert(current_t[2], top())
        end
        table.insert(o, current_t)
        current_t = {{}, {}}
        if Read(6) == "elseif" then
          if GetName() ~= "elseif" then Expected("elseif") end -- cry about it
          current_t[1] = top()
          if GetName() ~= "then" then Expected("then") end
        end
      end
      Match("e")Match("n")Match("d")
      return o--{"if", condition, top()}
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
  if not parameter_1 then
  if Look == "~" and View(1) ~= "=" then
    Match("~")
    return {"~", parameter_1}
  elseif Look == "#" then
    Match("#")
    return {"#", parameter_1}
  elseif Look == "-" then
    Match("-")
    return {"-", parameter_1}
  end
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
function priority_6()
  local parameter_1 = priority_5()
  while Read(2) == ".." do
    local op = ".." GetChar() Match(".")
    parameter_1 = {"..", parameter_1, priority_5()}
  end
  return parameter_1
end
function priority_7()
  local parameter_1 = priority_6()
  while Read(2) == ">>" or Read(2) == "<<" do -- lua has these, btw, lol
    local op = Look; GetChar(); GetChar(); SkipWhitespace()
    parameter_1 = {op..op, parameter_1, priority_6()}
  end
  return parameter_1
end
function priority_8()
  local parameter_1 = priority_7()
  while Look == "&" do
    Match("&")
    parameter_1 = {"&", parameter_1, priority_7()}
  end
  return parameter_1
end
function priority_9()
  local parameter_1 = priority_8()
  while Look == "~" and View(1) ~= "=" do
    Match("~")
    parameter_1 = {"~", parameter_1, priority_8()}
  end
  return parameter_1
end
function priority_10()
  local parameter_1 = priority_9()
  while Look == "|" do
    Match("|")
    parameter_1 = {"|", parameter_1, priority_9()}
  end
  return parameter_1
end
function priority_11()
  local parameter_1 = priority_10()
  --print(Read(2) .. "!")
  while Look == ">" or Look == "<" or Look == "~" or Look == "=" do
    local op = Look; GetChar()
    if Look == "=" then op = op .. Look; GetChar() end
    SkipWhitespace()
    parameter_1 = {op, parameter_1, priority_10()}
  end
  return parameter_1
end
function priority_12()
  local parameter_1 = priority_11()
  while Read(3) == "and" do
    GetChar() GetChar() Match("d")
    parameter_1 = {"and", parameter_1, priority_11()}
  end
  return parameter_1
end
function priority_13()
  local parameter_1 = priority_12()
  while Read(2) == "or" do
    GetChar() Match("r")
    parameter_1 = {"or", parameter_1, priority_12()}
  end
  return parameter_1
end

top = priority_13

function CreateLinesTable(lua)
  Str = lua
  At = 0
  GetChar()
  local o = {}
  while Look ~= "" do
    --SkipWhitespace()
    table.insert(o, top())

    --print(Read(40))
  end
  return o
end


Str = [[(1 + 1)/2 --hello
1>>2 << 1
"a" .. "b"
1 | 2 & 3 | 4
1 > 2
1 >= 2
1 < 2
1 <= 2
1 ~= 2
1 == 2
print(1, (24))
a = true or false
b = true and true
]]
Str = [[
if cond1 then 1 2 elseif cond2 then 3 4 elseif cond3 then 5 6 end
]]
Str = [[
while true do while true do print("hi") end end
]]
Str = [[
print(abc + (98238998 - (29834792834 / (893478.281289 * (982389.109 * 3.145)))))
]]
Str = [[
a = 2 - 2
]]
-- print(CreateLinesTable(Str))
