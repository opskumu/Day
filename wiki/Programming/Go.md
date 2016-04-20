# Go 学习笔记

## Go 指针、defer、匿名函数

### Go 指针

[Go Pointers](https://www.golang-book.com/books/intro/8)

* The * and & operator
    * In Go a pointer is represented using the * (asterisk) character followed by the type of the stored value
    * \* is also used to “dereference” pointer variables

``` go
package main

import "fmt"

type number int

func main() {
    var m number
    var n *number   // 定义 n 为指针类型

    m = 1
    n = &m          // 指针 n 赋值

    fmt.Println(m)
    fmt.Println(n)  // 输出地址
    fmt.Println(*n) // 输出为 1
}
```

[Golang Pointers on the Heap](http://lexsheehan.blogspot.ca/2016/02/golang-pointers-on-heap.html)

### Go defer 表达式

[Defer, Panic, and Recover](https://blog.golang.org/defer-panic-and-recover)

 A defer statement pushes a function call onto a list. The list of saved calls is executed after the surrounding function returns. Defer is commonly used to simplify functions that perform various clean-up actions.

defer 语句会存放在一个列表中，在其它函数语句执行 return 之后再执行。

* [Stacking defers](https://tour.golang.org/flowcontrol/13)

> Deferred function calls are pushed onto a stack. When a function returns, its deferred calls are executed in last-in-first-out order.

defer 语句的执行顺序类似栈的概念，__后进先出__。

``` go
package main

import "fmt"

func main() {
	fmt.Println("counting")

	for i := 0; i < 10; i++ {
		defer fmt.Println(i)  // 输出结果是 9， 8， 7, ..., 0
	}

	fmt.Println("done")
}
```

### 匿名函数

Go 不能在函数内部显式嵌套定义函数，但是可以定义一个匿名函数，Go 通过匿名函数实现闭包（闭包，通过“捕获”自由变量的绑定对函数文本执行的"闭合"操作）。

``` go
package main                                                                     

import "fmt"                                                                     

func f(i int) func() int {                                                       
    return func() int {                                                          
        i++                                                                      
        return i                                                                 
    }                                                                            
}                                                                                

func main() {                                                                    
    m1 := f(2)                                                                    
    fmt.Println(m1())    // 指针指向 i, i = 2, 输出 3                                                         
    fmt.Println(m1())    // 指针指向 i，i = 3，输出 4

    m2 := f(2)
    fmt.Println(m2())    // 指针指向 另外一个 i，i = 2，输出 3
}
```

### 实例

前段时间在 twitter 看到一个例子，问以下代码应该输出什么，后来分析之后才知道结果，代码如下：

``` go
package main                                                                     

import "fmt"                                                                     

type number int                                                                  

func (n number) print() {                                                        
    fmt.Printf("输出 number 值 print: %v\n", n)                                  
}                                                                                
func (n *number) pprint() {                                                      
    fmt.Printf("输出 number 值 pprint: %v\n", *n)                                
}                                                                                

func main() {
    var n number                                                                 

    defer n.print()                                                              
    defer n.pprint()                                                             
    defer func() {                                                               
        n.print()                                                                
    }()                                                                          
    defer func() {                                                               
        n.pprint()                                                               
    }()                                                                          

    n = 3                                                                        
}
```

输出结果如下：

```
➜ ～ go run test.go
输出 number 值 pprint: 3
输出 number 值 print: 3
输出 number 值 pprint: 3
输出 number 值 print: 0
```

根据 defer 的后进先出原则，4 个 defer 语句的执行顺序为倒序的，最后两个属于闭包，很好的理解输出为 3。`defer n.pprint()` 语句因为是指针，所以输出结果依然为 3。`defer n.print()` 为何为 0，这个相对较难理解，根据上文的说明，`var n number` 执行后，n 被初始化为 0，之后 defer 语句就被传入内存的 list 中，因此 `defer n.print()` 输出值为 0。

--EOF--
