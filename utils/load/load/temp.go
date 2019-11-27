package load

import (
	"fmt"
	"io/ioutil"
	"math"
	"path/filepath"
	"strconv"
	"strings"
)

type Temperature int

func (t Temperature) String() string {
	return strconv.Itoa(int(t))
}

func (l *Load) Temp(zone int) (Temperature, error) {
	if zone < 0 {
		if l.thermalZones == nil {
			glob, err := filepath.Glob("/sys/class/thermal/thermal_zone*/temp")
			if err != nil {
				return 0, err
			}
			l.thermalZones = make([]int, 0, len(glob))

			for i := range glob {
				p := strings.Split(glob[i], "/")
				n, err := strconv.Atoi(p[len(p)-2][12:])
				if err != nil {
					return 0, err
				}
				l.thermalZones = append(l.thermalZones, n)
			}

		}

		var max Temperature
		for _, n := range l.thermalZones {
			t, err := l.Temp(n)
			if err != nil {
				return 0, err
			}
			if t > max {
				max = t
			}
		}

		return max, nil

	}

	d, err := ioutil.ReadFile(
		fmt.Sprintf("/sys/class/thermal/thermal_zone%d/temp", zone),
	)
	if err != nil {
		return 0, err
	}

	t, err := strconv.Atoi(string(d[:len(d)-1]))

	if err != nil {
		return 0, err
	}

	return Temperature(math.Round(float64(t / 1000))), nil
}
