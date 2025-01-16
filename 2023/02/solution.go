package main

import (
	"fmt"
	"os"
	"path"
	"strconv"
	"strings"
	"time"
)

func part1(name string) {
	input, _ := os.ReadFile(name)
	start := time.Now()

	total := 0
	for idx, line := range strings.Split(string(input), "\n") {
		maxRed := 0
		maxGreen := 0
		maxBlue := 0
		cubes := 0
		for _, part := range strings.Split(strings.Split(line, ": ")[1], " ") {
			switch part[0] {
			case 'r':
				maxRed = max(maxRed, cubes)
			case 'g':
				maxGreen = max(maxGreen, cubes)
			case 'b':
				maxBlue = max(maxBlue, cubes)
			default:
				cubes, _ = strconv.Atoi(part)
			}
		}

		if maxRed <= 12 &&
			maxGreen <= 13 &&
			maxBlue <= 14 {
			total += idx + 1
		}
	}

	fmt.Println("Part 1", path.Base(name), total, time.Now().Sub(start).String())
}

func part2(name string) {
	input, _ := os.ReadFile(name)
	start := time.Now()

	total := 0
	for _, line := range strings.Split(string(input), "\n") {
		maxRed := 0
		maxGreen := 0
		maxBlue := 0
		cubes := 0
		for _, part := range strings.Split(strings.Split(line, ": ")[1], " ") {
			switch part[0] {
			case 'r':
				maxRed = max(maxRed, cubes)
			case 'g':
				maxGreen = max(maxGreen, cubes)
			case 'b':
				maxBlue = max(maxBlue, cubes)
			default:
				cubes, _ = strconv.Atoi(part)
			}
		}

		total += maxRed * maxGreen * maxBlue
	}

	fmt.Println("Part 2", path.Base(name), total, time.Now().Sub(start).String())
}

func main() {
	part1("2023/02/example.txt")
	part1("2023/02/input.txt")
	part2("2023/02/example.txt")
	part2("2023/02/input.txt")
}
