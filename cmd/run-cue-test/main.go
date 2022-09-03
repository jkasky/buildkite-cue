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
	FilePath string
	cases    *[]*SchemaTestCase
}

func (s *SchemaTestSuite) Append(c *SchemaTestCase) {
	if s.cases == nil {
		a := []*SchemaTestCase{c}
		s.cases = &a
		return
	}
	*s.cases = append(*s.cases, c)
}

func (s *SchemaTestSuite) Cases() []*SchemaTestCase {
	if s.cases == nil {
		return []*SchemaTestCase{}
	}
	return *s.cases
}

type SchemaTestCase struct {
	Name    string
	Yaml    string
	IsValid bool

	schema   cue.Value
	cueValue cue.Value
}

func runTest(c *SchemaTestCase) error {
	bytes := []byte(c.Yaml)
	return yaml.Validate(bytes, c.schema)
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

	suites := []*SchemaTestSuite{}
	ctx := cuecontext.New()

	for _, f := range files {
		suite := SchemaTestSuite{FilePath: f}
		suites = append(suites, &suite)
		entrypoints := []string{f}

		instances := load.Instances(entrypoints, nil)

		for _, t := range instances {
			if t.Err != nil {
				fmt.Printf("Error loading %s: %s\n", f, t.Err)
				os.Exit(1)
			}

			root := ctx.BuildInstance(t)

			if root.Err() != nil {
				cfmt.Printf("{{%s}}::red\n", root.Err())
				os.Exit(1)
			}

			tests := root.LookupPath(cue.ParsePath("tests"))

			itr, _ := tests.Fields()
			for itr.Next() {
				value := itr.Value()
				c := SchemaTestCase{Name: itr.Label()}
				err := value.Decode(&c)
				if err != nil {
					fmt.Println("Failed to decode:", err)
					os.Exit(1)
				}
				c.schema = value.LookupPath(cue.ParsePath("schema"))
				c.cueValue = value
				suite.Append(&c)
			}
		}
	}

	for _, s := range suites {
		cfmt.Printf("{{%s}}::bold\n", s.FilePath)

		var passCount, failCount int

		for _, c := range s.Cases() {
			err := runTest(c)
			if err != nil && c.IsValid {
				failCount++
				cfmt.Printf("[{{FAIL}}::red|bold] %s\n", c.Name)
				fmt.Println(c.cueValue.Source().Pos())
				details := errors.Details(err, nil)
				cfmt.Printf("{{%s}}::red", details)
			} else if err == nil && !c.IsValid {
				failCount++
				cfmt.Printf("[{{FAIL}}::red|bold] %s\n", c.Name)
				fmt.Println(c.cueValue.Source().Pos())
				fmt.Printf("Expected YAML to be invalid:\n%s\n", c.Yaml)
			} else {
				passCount++
				cfmt.Printf("[{{PASS}}::lightGreen|bold] %s\n", c.Name)
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
