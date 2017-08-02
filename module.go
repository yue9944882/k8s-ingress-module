package main

import "C"
import "fmt"

//export IngressBootstrap
func IngressBootstrap(host_c *C.char) *C.char {
	host := C.GoString(host_c)
	fmt.Println(host)
	return C.CString(host + "boot")
}

func main() {
	fmt.Println("K8S INGRESS")
}
