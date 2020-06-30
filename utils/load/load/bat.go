package load

import (
	"fmt"
	"io/ioutil"
	"os"
	"strconv"
)

func (l *Load) Bat(which int) (Percentage, error) {
	d, err := ioutil.ReadFile(
		fmt.Sprintf("/sys/class/power_supply/BAT%d/capacity", which),
	)

	if err != nil {
		if os.IsNotExist(err) {
			return 0, nil
		}
		return 0, err
	}

	bat, err := strconv.Atoi(string(d[:len(d)-1]))
	if err != nil {
		return 0, err
	}

	return Percentage(float64(bat) / 100), nil
}
