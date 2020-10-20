# gomod-replace-pseudo

Simple experiment: when `go.mod ` contains `replace` directive, it may generate pseudo version row in `require` if extact version on the left of `=>` is not specified .

# `go.mod`: Before `go run` or `go build`

After clone this repository, and before running go command, `go.mod`:

```go.mod
module github.com/vikyd/gomod-replace-pseudo

go 1.15

replace (
	github.com/go-playground/validator/v10 => github.com/vikyd/validator/v10 v10.4.0
	github.com/google/uuid => github.com/vikyd/uuid v1.1.2
	github.com/jinzhu/now v1.1.1 => github.com/vikyd/now v1.1.1
)
```

# `go.mod`: After `go run` or `go build`

After running `go run main.go` or `go build -v`, `go.mod`:

```go.mod
module github.com/vikyd/gomod-replace-pseudo

go 1.15

replace (
	github.com/go-playground/validator/v10 => github.com/vikyd/validator/v10 v10.4.0
	github.com/google/uuid => github.com/vikyd/uuid v1.1.2
	github.com/jinzhu/now v1.1.1 => github.com/vikyd/now v1.1.1
)

require (
	github.com/go-playground/validator/v10 v10.0.0-00010101000000-000000000000 // indirect
	github.com/google/uuid v0.0.0-00010101000000-000000000000 // indirect
	github.com/jinzhu/now v1.1.1 // indirect
)
```

# Pseudo Version Explain

- `v0.0.0-00010101000000-000000000000`
  - because `github.com/google/uuid => github.com/vikyd/uuid v1.1.2` dose not know the version of `github.com/google/uuid`
- `v10.0.0-00010101000000-000000000000`
  - because `github.com/go-playground/validator/v10 => github.com/vikyd/validator/v10 v10.4.0` knows the major version is `v10`, but also dose not know the minor and patch version of `github.com/go-playground/validator/v10`
- `v1.1.1`
  - because `github.com/jinzhu/now v1.1.1 => github.com/vikyd/now v1.1.1` know the exact version(major, minor, patch) of `github.com/jinzhu/now`

# Go Source Code

[`cmd/go/internal/modload/import.go`](https://github.com/golang/go/blob/go1.15.3/src/cmd/go/internal/modload/import.go#L229-L243):

```go
if _, pathMajor, ok := module.SplitPathVersion(p); ok && len(pathMajor) > 0 {
	v = modfetch.PseudoVersion(pathMajor[1:], "", time.Time{}, "000000000000")
} else {
	v = modfetch.PseudoVersion("v0", "", time.Time{}, "000000000000")
}
```

↓

[`cmd/go/internal/modfetch/pseudo.go`](https://github.com/golang/go/blob/go1.15.3/src/cmd/go/internal/modfetch/pseudo.go#L53-L77):

```go
func PseudoVersion(major, older string, t time.Time, rev string) string {
	if major == "" {
		major = "v0"
	}
	segment := fmt.Sprintf("%s-%s", t.UTC().Format(pseudoVersionTimestampFormat), rev)
	build := semver.Build(older)
	older = semver.Canonical(older)
	if older == "" {
		return major + ".0.0-" + segment // form (1)
	}
	if semver.Prerelease(older) != "" {
		return older + ".0." + segment + build // form (4), (5)
	}

	// Form (2), (3).
	// Extract patch from vMAJOR.MINOR.PATCH
	i := strings.LastIndex(older, ".") + 1
	v, patch := older[:i], older[i:]

	// Reassemble.
	return v + incDecimal(patch) + "-0." + segment + build
}
```

# More

- [Debug How Pseudo Version Generated（chinese）](https://github.com/vikyd/note/blob/master/vscode_goland_debug_go_mod_go_build_go_get.md#vscode-%E8%B0%83%E8%AF%95-go-build-%E7%BC%96%E8%AF%91%E5%99%A8%E6%9C%AC%E8%BA%AB), or see: `.vscode/launch.json`
- [More Pseudo Version (chinese)](https://github.com/vikyd/note/blob/master/go_pseudo_version.md)
