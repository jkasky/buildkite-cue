package main

import (
	"fmt"
	"io/fs"
	"os"
	"path/filepath"

	"cuelang.org/go/cue"
	"cuelang.org/go/cue/cuecontext"
	"cuelang.org/go/cue/errors"
	"cuelang.org/go/cue/load"
	"cuelang.org/go/encoding/yaml"
	"github.com/i582/cfmt/cmd/cfmt"
)

type SchemaTestSuite struct {
	Cases []SchemaTestCase
}

type SchemaTestCase struct {
	Yaml    string
	IsValid bool
}

func main() {
	var files []string

	filepath.Walk(
		"test",
		func(path string, info fs.FileInfo, err error) error {
			if !info.IsDir() {
				files = append(files, path)
				fmt.Println("found ", path)
			}
			return nil
		})

	ctx := cuecontext.New()

	for _, f := range files {
		entrypoints := []string{f}

		instances := load.Instances(entrypoints, nil)

		for _, t := range instances {
			if t.Err != nil {
				fmt.Println("Error loading: ", t.Err)
				os.Exit(1)
			}

			root := ctx.BuildInstance(t)

			cfmt.Printf("{{%s}}::bold\n", t.Files[0].Filename)

			tests := root.LookupPath(cue.ParsePath("tests"))

			var passCount, failCount int

			itr, _ := tests.Fields()
			for itr.Next() {
				label := itr.Label()
				value := itr.Value()
				var c SchemaTestCase
				err := value.Decode(&c)
				if err != nil {
					fmt.Println("Failed to decode: ", err)
					os.Exit(1)
				}
				schema := value.LookupPath(cue.ParsePath("schema"))
				bytes := []byte(c.Yaml)
				err = yaml.Validate(bytes, schema)
				if err != nil && c.IsValid {
					failCount++
					cfmt.Printf("[{{FAIL}}::red|bold] %s\n", label)
					fmt.Println(value.Source().Pos())
					details := errors.Details(err, nil)
					cfmt.Printf("{{%s}}::red", details)
				} else if err == nil && !c.IsValid {
					failCount++
					cfmt.Printf("[{{FAIL}}::red|bold] %s\n", label)
					fmt.Println(value.Source().Pos())
					fmt.Printf("Expected YAML to be invalid:\n%s", c.Yaml)
				} else {
					passCount++
					cfmt.Printf("[{{PASS}}::lightGreen|bold] %s\n", label)
				}
			}

			totalCount := passCount + failCount
			if failCount > 0 && passCount > 0 {
				cfmt.Printf("{{%d/%d}}::bold passed, {{%d}}::bold|red failed\n",
					passCount, totalCount, failCount)
			} else {
				cfmt.Printf("{{%d}}::bold passed\n", passCount)
			}
		}
	}
}
