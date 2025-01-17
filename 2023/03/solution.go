package main

import (
	"fmt"
	"os"
	"path"
	"strings"
	"time"
)

func isSymbol(input string, idx int) bool {
	if idx < 0 || idx >= len(input) {
		return false
	}
	char := rune(input[idx])
	return char != '.' && char != '\n' && (char < '0' || char > '9')
}

func part1(name string) {
	raw, _ := os.ReadFile(name)
	start := time.Now()

	input := string(raw)
	width := strings.Index(input, "\n")
	total := 0
	number := 0
	symbol := false
	for idx, char := range input {
		if char >= '0' && char <= '9' {
			// Number
			if !symbol && number == 0 {
				// First digit, check prev three characters
				symbol = isSymbol(input, idx-1) || isSymbol(input, idx-width-2) || isSymbol(input, idx+width)
			}
			if !symbol {
				// Check above and below
				symbol = isSymbol(input, idx-width-1) || isSymbol(input, idx+width+1)
			}
			number = number*10 + int(char-'0')
		} else if number > 0 {
			// End of number
			if !symbol {
				// Check this and above/below
				symbol = isSymbol(input, idx) || isSymbol(input, idx-width-1) || isSymbol(input, idx+width+1)
			}
			if symbol {
				total += number
				symbol = false
			}
			number = 0
		}
		if char == '\n' {
			// New line, reset
			number = 0
			symbol = false
		}
	}
	if symbol {
		total += number
		symbol = false
	}

	fmt.Println("Part 1", path.Base(name), total, time.Now().Sub(start).String())
}

func isNumber(input string, idx int) bool {
	if idx < 0 || idx >= len(input) {
		return false
	}
	char := rune(input[idx])
	return char >= '0' && char <= '9'
}

func readNumber(input string, idx int) int {
	if !isNumber(input, idx) {
		return 0
	}
	for isNumber(input, idx-1) {
		idx--
	}
	number := 0
	for isNumber(input, idx) {
		number = number*10 + int(input[idx]-'0')
		idx++
	}
	return number
}

func part2(name string) {
	raw, _ := os.ReadFile(name)
	start := time.Now()

	input := string(raw)
	width := strings.Index(input, "\n") + 1
	total := 0
	for idx, char := range input {
		if char == '*' {
			numbers := make([]int, 0, 6)

			for _, offset := range []int{-width, 0, width} {
				center := readNumber(input, idx+offset)
				if center > 0 {
					numbers = append(numbers, center)
				} else {
					left := readNumber(input, idx+offset-1)
					if left > 0 {
						numbers = append(numbers, left)
					}
					right := readNumber(input, idx+offset+1)
					if right > 0 {
						numbers = append(numbers, right)
					}
				}
			}

			if len(numbers) == 2 {
				total += numbers[0] * numbers[1]
			}
		}
	}

	fmt.Println("Part 2", path.Base(name), total, time.Now().Sub(start).String())
}

func main() {
	part1("2023/03/example.txt")
	part1("2023/03/input.txt")
	part2("2023/03/example.txt")
	part2("2023/03/input.txt")
}
