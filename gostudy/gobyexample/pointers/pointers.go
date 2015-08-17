package main

import "fmt"

func zeroval(ival int) {
	ival = 0
}

func zeroptr(iptr *int) {
	*iptr = 0
}

func main() {
	i := 1
	fmt.Println("inital:", i)

	zeroval(i)
	fmt.Println("zeroval:", i)

	// zeroval doesn’t change the i in main,
	// but zeroptr does because it has a reference to the memory address for that variable.
	zeroptr(&i)
	fmt.Println("zeroptr:", i)

	fmt.Println("pointer:", &i)
}
