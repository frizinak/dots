package load

import (
	"bufio"
	"errors"
	"os"
	"time"
)

type Load struct {
	lastCPU      [2]int
	thermalZones []int
	lastNet      [2]int
	lastNetStamp time.Time
}

func New() *Load {
	return &Load{}
}

var errorBreak = errors.New("break")

type cb func([]byte) error

func scan(file string, cb cb) error {
	f, err := os.Open(file)
	if err != nil {
		return err
	}
	defer f.Close()

	scanner := bufio.NewScanner(f)
	scanner.Split(bufio.ScanLines)
	for scanner.Scan() {
		if err := cb(scanner.Bytes()); err != nil {
			if err == errorBreak {
				break
			}
			return err
		}
	}

	return scanner.Err()
}
