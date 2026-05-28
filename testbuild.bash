lua compiler.lua $1 temp
g++ $1.cpp -o $1
./$1