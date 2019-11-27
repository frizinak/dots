package load

import (
	"bytes"
	"strconv"
	"strings"
)

var prefixCPU = []byte("cpu ")

func (l *Load) CPU() (Percentage, error) {
	var load [2]int
	var diff [2]float64

	cb := func(b []byte) error {
		if !bytes.HasPrefix(b, prefixCPU) {
			return nil
		}

		f := strings.Fields(string(b))
		f = f[1:]
		for i := range f {
			n, err := strconv.Atoi(f[i])
			if err != nil {
				return err
			}

			load[1] += n
			if i == 3 || i == 4 {
				load[0] += n
			}
		}

		return errorBreak
	}

	if err := scan("/proc/stat", cb); err != nil {
		return 0, err
	}

	diff[0], diff[1] = float64(load[0]-l.lastCPU[0]), float64(load[1]-l.lastCPU[1])
	l.lastCPU = load

	return Percentage(1 - diff[0]/diff[1]), nil
}
