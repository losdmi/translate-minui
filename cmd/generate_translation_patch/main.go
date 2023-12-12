package main

import (
	"encoding/json"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"regexp"
	"strconv"
	"strings"
)

var rootDir string
var phraseRegex *regexp.Regexp

func init() {
	var err error

	rootDir, err = filepath.Abs(".")
	if err != nil {
		log.Fatal(err)
	}

	phraseRegex = regexp.MustCompile(`{{(.+?)}}`)
}

func main() {
	lang, err := getLang(os.Args)
	if err != nil {
		log.Fatal(err)
	}

	translation, err := loadTranslation(lang)
	if err != nil {
		log.Fatal(err)
	}

	patch, err := generatePatch(translation)
	if err != nil {
		log.Fatal(err)
	}

	path := fmt.Sprintf("%s/patches/MinUI-%s.patch", rootDir, lang)
	err = savePatch(patch, path)
	if err != nil {
		log.Fatal(err)
	}
}

func getLang(args []string) (string, error) {
	if len(args) < 2 {
		return "", fmt.Errorf("error: pass the translation language as the first argument. For example: `go run cmd/generate_translation_patch/main.go RU`")
	}
	return args[1], nil
}

func loadTranslation(lang string) (map[string]string, error) {
	path := fmt.Sprintf("%s/translations/%s.json", rootDir, lang)
	translationFile, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}

	result := make(map[string]string)
	err = json.Unmarshal(translationFile, &result)
	if err != nil {
		return nil, err
	}

	return result, nil
}

func generatePatch(translations map[string]string) (string, error) {
	path := rootDir + "/patches/MinUI.patch"
	patchFileContent, err := os.ReadFile(path)
	if err != nil {
		return "", err
	}

	result := strings.Split(string(patchFileContent), "\n")
	for i, line := range result {
		if !strings.HasPrefix(line, "+") {
			continue
		}

		patchedLine, err := patchLine(line, translations)
		if err != nil {
			return "", err
		}
		result[i] = patchedLine
	}

	return strings.Join(result, "\n"), nil
}

func patchLine(line string, translations map[string]string) (string, error) {
	result := line
	for phrase, translation := range translations {
		target := fmt.Sprintf("{{%s}}", strings.Trim(strconv.Quote(phrase), "\""))
		result = strings.ReplaceAll(result, target, strings.Trim(strconv.Quote(translation), "\""))
	}

	return result, nil
}

func savePatch(patch string, path string) error {
	return os.WriteFile(path, []byte(patch), 0664)
}
