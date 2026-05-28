#include <iostream>
#include <float.h>
#include <string.h>
#include <any>
using namespace std;



int main() {

	auto a = 2.0f;
	if (a == 2.0f) {
		while (a < 100.0f) {
		a = a + 1.0f;
	}
}

	while (a < 10000000000000000.0f) {
		a = a + 1.0f;
	}
	cout << a << " "  << "\n";


    return 0;
}