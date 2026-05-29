#include <iostream>
#include <float.h>
#include <string.h>
#include <any>
#include <bits/stdc++.h>
#include <unistd.h>
using namespace std;

// built-in lua functions
string ioread() {
    string got;
    cin >> got;
    //cout << "LUACOMP ioread " << got << "\n";
    return got;
}

double tonumber(string str) {
	double num = stod(str);
    //cout << "LUACOMP tonumber " << num << "\n";
	return num;
}

CPPFUNC

GLOBALVAR

int main() {

LUACODE

    return 0;
}