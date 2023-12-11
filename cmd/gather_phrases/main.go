package main

import (
	"encoding/json"
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
	phrases, err := getPhrases()
	if err != nil {
		log.Fatal(err)
	}
	phrasesJSON, err := buildJSON(phrases)
	if err != nil {
		log.Fatal(err)
	}
	err = writeJSONToFile(phrasesJSON)
	if err != nil {
		log.Fatal(err)
	}
}

func getPhrases() ([]string, error) {
	path := rootDir + "/patches/MinUI.patch"
	patchFileContent, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}

	var result []string
	for _, line := range strings.Split(string(patchFileContent), "\n") {
		if !strings.HasPrefix(line, "+") {
			continue
		}

		phrases, err := extractPhrasesFromLine(line)
		if err != nil {
			return nil, err
		}
		result = append(result, phrases...)
	}

	return result, nil
}

func extractPhrasesFromLine(line string) ([]string, error) {
	matches := phraseRegex.FindAllStringSubmatch(line, -1)

	result := make([]string, 0, len(matches))
	for i := range matches {
		unescaped, err := strconv.Unquote(`"` + matches[i][1] + `"`)
		if err != nil {
			return nil, err
		}
		result = append(result, unescaped)
	}

	return result, nil
}

func buildJSON(phrases []string) ([]byte, error) {
	phrasesMap := make(map[string]string)
	for _, phrase := range phrases {
		phrasesMap[phrase] = phrase
	}
	return json.MarshalIndent(phrasesMap, "", "  ")
}

func writeJSONToFile(phrasesJSON []byte) error {
	return os.WriteFile(rootDir+"/translations/template.json", phrasesJSON, 0644)
}
