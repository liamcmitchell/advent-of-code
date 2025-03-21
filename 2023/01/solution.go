package main

import (
	"fmt"
	"os"
	"path"
	"strings"
	"time"
)

func part1(name string) {
	input, _ := os.ReadFile(name)
	start := time.Now()
	lines := strings.Split(string(input), "\n")
	total := 0
	for _, line := range lines {
		var numbers []int
		for _, char := range line {
			value := int(char - '0')
			if value >= 0 && value <= 9 {
				numbers = append(numbers, value)
			}
		}
		total += numbers[0]*10 + numbers[len(numbers)-1]
	}
	fmt.Println("Part 1", path.Base(name), total, time.Now().Sub(start).String())
}

func part2(name string) {
	input, _ := os.ReadFile(name)
	start := time.Now()

	words := []string{"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"}

	lines := strings.Split(string(input), "\n")
	total := 0
	for _, line := range lines {
		first := 0
		firstIdx := len(line)
		last := 0
		lastIdx := -1
		for idx, word := range words {
			firstWordIdx := strings.Index(line, word)
			if firstWordIdx >= 0 && firstIdx > firstWordIdx {
				first = idx % 10
				firstIdx = firstWordIdx
			}
			lastWordIdx := strings.LastIndex(line, word)
			if lastWordIdx >= 0 && lastIdx < lastWordIdx {
				last = idx % 10
				lastIdx = lastWordIdx
			}
		}
		total += first*10 + last
	}
	fmt.Println("Part 2", path.Base(name), total, time.Now().Sub(start).String())
}

func main() {
	part1("2023/01/example.txt")
	part1("2023/01/input.txt")
	part2("2023/01/example2.txt")
	part2("2023/01/input.txt")
}
