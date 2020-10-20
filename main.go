package main

import (
	"fmt"

	"github.com/go-playground/validator/v10"
	"github.com/google/uuid"
	"github.com/jinzhu/now"
)

func main() {
	fmt.Println(uuid.New())

	fmt.Println(now.BeginningOfHour())

	validate := validator.New()
	errs := validate.Var("abc.qq.com", "required,email")
	if errs != nil {
		fmt.Println("validator works")
	}
}
