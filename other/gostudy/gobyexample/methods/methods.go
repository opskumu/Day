package main

import "fmt"

type rect struct {
	width, height int
}

// golang 声明方法，r *rect, 加 * 和没有加 * 的区别在于一个是传递指针对象，一个是传递值对象
// For types such as basic types, slices, and small structs,
// a value receiver is very cheap so unless the semantics of the method requires a pointer,
// a value receiver is efficient and clear.
// http://golang.org/doc/faq#methods_on_values_or_pointers
func (r *rect) area() int {
	return r.width * r.height
}

func (r rect) perim() int {
	return 2*r.width + 2*r.height
}

func main() {
	r := rect{width: 10, height: 5}

	fmt.Println("area: ", r.area())
	fmt.Println("perim:", r.perim())

	rp := &r
	fmt.Println("area: ", rp.area())
	fmt.Println("perim:", rp.perim())
}
