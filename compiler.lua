
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

    local GLOBALVAR = ''

    local AssHole = {}

    function plzsend(com, actionTable)
        local f = ''

        local action = com[1]
        if not actionTable then actionTable = {} end
        actionTable[#actionTable+1] = action

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
            elseif func == 'ioread' then
                f = f .. 'cin >> ' .. parseBlock(inputs[1]) .. ';'
            else
                f = f .. func .. '('
                for inputIndex, input in pairs(inputs) do
                    local interpreted = parseBlock(input)
                    
                    f = f .. interpreted
                    if inputIndex < #inputs then
                        f = f .. ', '
                    end
                end
                f = f .. ');'
            end
        elseif action == 'local' or action == 'global' then
            local name = com[2][1]
            local set = parseBlock(com[3])

            local cpptype = 'string'
            if tonumber(string.sub(set, 1, string.len(set)-1)) then
                cpptype = 'float'
            end
            cpptype = 'auto'
            cpptype = cpptype .. ' '

            if set ~= '' then
                set = ' = ' .. set
            end

            if AssHole[name] then
                cpptype = ''
            end

            f = f .. cpptype .. name .. set

            f = f .. ';'

            if action == 'global' and not AssHole[name] then
                GLOBALVAR = GLOBALVAR .. f .. '\n'
                f = ''
            end
            
            AssHole[name] = true
        elseif action == 'for' then
            local indexBlk  = com[2]
            local indexName = parseBlock(indexBlk[2])
            local setas     = parseBlock(indexBlk[3])

            local uncill = parseBlock(com[3])
            local increment = parseBlock(com[4])
            local blocks = com[5]

            f = f .. 'for ('
            f = f .. 'float ' .. indexName .. ' = ' .. setas .. '; '
            f = f .. 'i <= ' .. uncill .. '; '
            f = f .. 'i+=' .. increment .. ') '
            f = f .. '{\n\t'
            for _, com2 in pairs(blocks) do
                local x = ''

                x = plzsend(com2)

                f = f .. '\t\t' .. x .. '\n'
            end
            f = f .. '\t}'
        elseif action == 'if' then
            local ifIndex = 1
            for m, z in pairs(com) do
                if m ~= 1 then -- skip action var
                    if ifIndex == 1 then
                        f = f .. 'if'
                    else f = f .. 'else if' end
                    local condition = z[1]
                    f = f .. ' (' .. parseBlock(condition) .. ') {\n'
                    local blocks = z[2]
                    for _, com2 in pairs(blocks) do
                        local x = ''

                        x = plzsend(com2)

                        f = f .. '\t\t' .. x .. '\n'
                    end
                    f = f .. '\t}'
                    if m >= #com then f = f .. '\n' end
                    ifIndex = ifIndex + 1
                end
            end
        elseif action == 'while' then
            f = f .. 'while'
            local condition = com[2]
            f = f .. ' (' .. parseBlock(condition) .. ') {\n'
            local blocks = com[3]
            for _, com2 in pairs(blocks) do
                local x = ''

                x = plzsend(com2)

                f = f .. '\t\t' .. x .. '\n'
            end
            f = f .. '\t}'
        elseif action == 'break' then
            f = f .. 'break;\n'
        elseif action == 'function' then
            f = f .. 'auto '
            local name = com[2]
            f = f .. name
            local params = com[3]
            f = f .. '('
            for index, paramName in pairs(params) do
                f = f .. 'auto ' .. paramName

                if index ~= #params then f = f .. ', ' end
            end
            f = f .. ')'
            local blocks = com[4]

            f = f .. ' {\n'
            for _, com2 in pairs(blocks) do
                local x = ''

                x = plzsend(com2)

                f = f .. '\t\t' .. x .. '\n'
            end
            f = f .. '}'

            GLOBALVAR = GLOBALVAR .. f .. '\n'
            f = ''
        elseif action == 'return' then
            f = f .. 'return ' .. parseBlock(com[2]) .. ';\n'
        end

        return f
    end

    function parseBlock(blk)
        print(blk)

        local parsed = ''
        local operation
        local operationA
        local aNUM
        local operationB
        local bNUM

        if blk[1] == 'call' then
            parsed = plzsend(blk)
        else
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
                elseif v == '+' or v == '-' or v == '/' or v == '*' or v == '^' or v == '..' or v == '==' or v == '~=' or v == '<' or v == '>' then
                    operation = v
                elseif t == 'number' then
                    if string.match(tostring(v), "[.]") then
                        z = v .. ''
                    else
                        z = v .. '.0'
                    end
                else
                    z = v
                end
                parsed = parsed .. tostring(z)
            end
        end

        if operation then
            local cppoperation = {}
            cppoperation['~='] = '!='

            if operation == '..' then
                parsed = (aNUM and ('to_string('..operationA..')') or operationA) .. ' + ' .. (bNUM and ('to_string('..operationB..')') or operationB)
            else
                parsed = operationA .. ' ' .. (cppoperation[operation] or operation) .. ' ' .. operationB
            end
        end

        return parsed
    end

    for _, com in pairs(luainfo) do
        local f = ''

        print(com)

        f = plzsend(com)

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

local luausdhjij, ccccccccrioijmroiemn = ...

translate(luausdhjij or io.read(), ccccccccrioijmroiemn or io.read())