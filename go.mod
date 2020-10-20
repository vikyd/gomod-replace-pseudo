module github.com/vikyd/gomod-replace-pseudo

go 1.15

replace (
	github.com/go-playground/validator/v10 => github.com/vikyd/validator/v10 v10.4.0
	github.com/google/uuid => github.com/vikyd/uuid v1.1.2
	github.com/jinzhu/now v1.1.1 => github.com/vikyd/now v1.1.1
)

// `go run main.go` will generate below:
//
// require (
// 	github.com/go-playground/validator/v10 v10.0.0-00010101000000-000000000000 // indirect
// 	github.com/google/uuid v0.0.0-00010101000000-000000000000 // indirect
// 	github.com/jinzhu/now v1.1.1 // indirect
// )
