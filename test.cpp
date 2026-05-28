#include <iostream>
#include <float.h>
#include <string.h>
using namespace std;

string MyAwesomeGlobal = "abc";


int main() {

	cout << "hello" << " "  << "\n";
	cout << "hello my nerdy lua friends" << " " << 32.0f << " "  << "\n";
	cout << 1.0f + 1.0f << " "  << "\n";
	cout << (((1.0f + 2.0f) + 3.0f) + 4.0f) + 5.0f << " "  << "\n";
	cout << (1.0f + 1.0f) / 2.0f << " "  << "\n";
	cout << 1.0f / 2.0f << " "  << "\n";
	float a = 1.0f;
	string b = "abc woah im so nerdy Lua String !";
	cout << b << " "  << "\n";
	cout << a << " "  << "\n";
	
	cout << MyAwesomeGlobal << " "  << "\n";
	cout << "Please give me a number between 0 and 15." << " "  << "\n";
	float userNumber = 0.0f;
	cin >> userNumber;
	if (userNumber != 0.0f) {
		cout << "Hahahah you suck loser !!" << " "  << "\n";
}else if (userNumber == 0.0f) {
		cout << "You win, not much too it eh ? ?!? ?!@#?E !@? ?!@ ?!@? " << " "  << "\n";
}

	cout << userNumber << " "  << "\n";
	cout << "your number was either good or bad i have no idea for i am the good guy and not that evil EVIL good guy !!!@#!@#934509348034987920834988!@#(@#$(@!#))" << " "  << "\n";
	float PARTICLEBAR = 0.0f;
	while (true) {
		PARTICLEBAR = PARTICLEBAR + 1.0f;
		cout << PARTICLEBAR << " "  << "\n";
		if (PARTICLEBAR == 100.0f) {
		break;

}

	}
	cout << "you lose." << " "  << "\n";


    return 0;
}