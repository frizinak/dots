package load

import (
	"bytes"
	"fmt"
	"strconv"
)

var prefixCPUMHz = []byte("cpu MHz")

type ClockMHz float64

func (c ClockMHz) MHz() string {
	return fmt.Sprintf("%dMHz", int(c))
}

func (c ClockMHz) GHz() string {
	return fmt.Sprintf("%.1fGHz", c/1024)
}

func (l *Load) ClockMHz() (ClockMHz, error) {
	mhz := make([]float64, 0, 8)
	cb := func(b []byte) error {
		if !bytes.HasPrefix(b, prefixCPUMHz) {
			return nil
		}
		i := len(b) - 1
		for ; i > 0; i-- {
			if b[i] == ' ' {
				break
			}
		}
		v, err := strconv.ParseFloat(string(b[i+1:]), 16)
		if err != nil {
			return err
		}
		mhz = append(mhz, v)
		return nil
	}

	if err := scan("/proc/cpuinfo", cb); err != nil {
		return 0, err
	}

	var val float64
	for _, v := range mhz {
		val += v
	}

	return ClockMHz(val / float64(len(mhz))), nil
}
