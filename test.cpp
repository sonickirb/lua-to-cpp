#include <iostream>
#include <float.h>
#include <string.h>
#include <any>
#include <bits/stdc++.h>
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

auto hurrah(auto a, auto b) {
		cout << "aoiksdok" << " "  << "\n";
		cout << a << " " << b << " "  << "\n";
		return a;

}
auto MyAwesomeGlobal = "abc";


int main() {

	cout << "hello" << " "  << "\n";
	cout << "hello my nerdy lua friends" << " " << 32.0 << " "  << "\n";
	cout << 1.0 + 1.0 << " "  << "\n";
	cout << (((1.0 + 2.0) + 3.0) + 4.0) + 5.0 << " "  << "\n";
	cout << (1.0 + 1.0) / 2.0 << " "  << "\n";
	cout << 1.0 / 2.0 << " "  << "\n";
	
	auto ass = hurrah("HELLO", 2.0);
	cout << ass << " "  << "\n";
	auto a = 1.0;
	auto b = "abc woah im so nerdy Lua String !";
	cout << b << " "  << "\n";
	cout << a << " "  << "\n";
	
	cout << MyAwesomeGlobal << " "  << "\n";
	for (double i = 1.0; i <= 3.0; i+=1.0) {
			cout << "my AMAZING FOR is" << " " << i << " "  << "\n";
	}
	for (double i = 0.0; i <= 1.0; i+=0.01) {
			cout << "my AMAZING Floats are" << " " << i << " "  << "\n";
	}
	cout << "Please give me a number between 0 and 15." << " "  << "\n";
	auto userNumber = ioread();
	auto numuser = tonumber(userNumber);
	if (numuser != 0.0) {
		cout << "Hahahah you suck loser !!" << " "  << "\n";
	}else if (numuser == 0.0) {
		cout << "You win, not much too it eh ? ?!? ?!@#?E !@? ?!@ ?!@? " << " "  << "\n";
	}

	cout << userNumber << " "  << "\n";
	cout << numuser << " "  << "\n";
	cout << "your number was either good or bad i have no idea for i am the good guy and not that evil EVIL good guy !!!@#!@#934509348034987920834988!@#(@#$(@!#))" << " "  << "\n";
	for (double i = 0.0 - 100000.0; i <= 100000.0; i+=0.01) {
			cout << i << " "  << "\n";
	}


    return 0;
}