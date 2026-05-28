print("hello")
print("hello my nerdy lua friends", 32)
print(1 + 1)
print(1+2+3+4+5)
print((1 + 1) / 2)
print(1 / 2)

function hurrah(a, b)
    print('aoiksdok')
    print(a, b)

    return a
end

local ass = hurrah('HELLO', 2)

print(ass)

local a = 1
local b = "abc woah im so nerdy Lua String !"
print(b)

print(a)

MyAwesomeGlobal = 'abc'

print(MyAwesomeGlobal)

for i = 1, 3 do
    print('my AMAZING FOR is', i)
end

for i = 0, 1, 0.01 do
    print('my AMAZING Floats are', i)
end

--local tabletest = {}
--tabletest[1] = 67
--print(tabletest[1])

--local inittable = {89}
--print(inittable[1])

print('Please give me a number between 0 and 15.')
local userNumber = io.read()

local numuser = tonumber(userNumber)

if numuser ~= 0 then
    print('Hahahah you suck loser !!')
elseif numuser == 0 then
    print('You win, not much too it eh ? ?!? ?!@#?E !@? ?!@ ?!@? ')
end

print(userNumber)
print(numuser)

print('your number was either good or bad i have no idea for i am the good guy and not that evil EVIL good guy !!!@#!@#934509348034987920834988!@#(@#$(@!#))')

--local PARTICLEBAR = 0
--while true do
--    PARTICLEBAR = PARTICLEBAR + 1
--    print(PARTICLEBAR)
--
--    if PARTICLEBAR == 100 then
--        break
--    end
--end

--print('you lose.')

for i = 0 - 100000, 100000, 0.01 do
    print(i)
end
