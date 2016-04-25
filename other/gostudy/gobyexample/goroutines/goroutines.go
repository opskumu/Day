package main

import "fmt"

func f(from string) {
	for i := 0; i < 3; i++ {
		fmt.Println(from, ":", i)
	}
}

// When we run this program, we see the output of the blocking call first,
// then the interleaved output of the two gouroutines.
// This interleaving reflects the goroutines being run concurrently by the Go runtime.
func main() {
	f("direct")
	go f("goroutine")
	go func(msg string) {
		fmt.Println(msg)
	}("going")

	var input string
	fmt.Scanln(&input)
	fmt.Println("done")
}
