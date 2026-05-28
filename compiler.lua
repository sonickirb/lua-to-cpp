
-- lua 5.1 dosent have math.clamp
function math.clamp(a, b, c)
    if a < b then a = b end
    if a > c then a = c end

    return a
end

-- lua 5.1 yet again does NOT have string.split
function string.split(s, seperator)
    local a = {}
    local b = ""

    local length = string.len(s)

    for i = 1, length do
        local c = string.sub(s, i, i)

        if c == seperator or i == length then
            if i == length then b = b .. c end
            a[#a+1] = b
            b = ""
        else b = b .. c end
    end

    return a
end

local cppReplace = "LUACODE"

require('parser')

local function translate(luafile, cpptemplateFile)
    local file = io.open(luafile .. '.lua', 'r')
    if not file then error(luafile .. ".lua was not accessible") end
    local lua = file:read('a')

    local luainfo = CreateLinesTable(lua)

    local file = io.open(cpptemplateFile .. '.cpp', 'r')
    if not file then error(cpptemplateFile .. ".cpp was not accessible") end
    local cpp = file:read('a')
    file:close()

    local translated = ''

    local function parseBlock(blk)
        print(blk)

        local parsed = ''
        local operation
        local operationA
        local operationB

        for i, v in pairs(blk) do
            local t = type(v)
            local z = ''
            if t == 'table' then
                z = parseBlock(v)
                if string.match(z, '+') or string.match(z, '-') or string.match(z, '/') or string.match(z, '*') then
                    z = '(' .. z .. ')'
                end
                if operation then
                    if not operationA then
                        operationA = z
                    else
                        operationB = z
                    end
                    z = ''
                end
            elseif v == '+' or v == '-' or v == '/' or v == '*' or v == '^' then
                operation = v
            elseif t == 'number' then
                if string.match(tostring(v), "[.]") then
                    z = v .. 'f'
                else
                    z = v .. '.0f'
                end
            else
                z = v
            end
            parsed = parsed .. z
        end

        if operation then
            parsed = operationA .. operation .. operationB
        end

        return parsed
    end

    local GLOBALVAR = ''

    for _, com in pairs(luainfo) do
        local f = ''

        print(com)
        
        local action = com[1]

        if action == 'call' then
            local func = com[2][1]
            local inputs = com[3]

            if func == 'print' then
                f = f .. 'cout '
                for inputIndex, input in pairs(inputs) do
                    local interpreted = parseBlock(input)
                    
                    f = f .. '<< ' .. interpreted .. ' << " " '
                end
                f = f .. ' << "\\n";'
            end
        elseif action == 'local' or action == 'global' then
            local name = com[2][1]
            local set = parseBlock(com[3])

            local cpptype = 'string'
            if tonumber(string.sub(set, 1, string.len(set)-1)) then
                cpptype = 'float'
            end

            f = f .. cpptype .. ' ' .. name .. ' = ' .. set

            f = f .. ';'

            if action == 'global' then
                GLOBALVAR = GLOBALVAR .. f .. '\n'
                f = ''
            end
        end


        translated = translated .. '\t' .. f .. '\n'
    end

    print(translated)

    cpp = string.gsub(cpp, 'LUACODE', translated)
    cpp = string.gsub(cpp, 'GLOBALVAR', GLOBALVAR)

    print(cpp)

    local file = io.open(luafile .. '.cpp', 'w')
    if not file then error(luafile .. ".cpp was not accessible") end
    file:write(cpp)
end

translate(io.read(), io.read())