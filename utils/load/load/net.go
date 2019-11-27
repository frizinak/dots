package load

import (
	"fmt"
	"io/ioutil"
	"strconv"
	"time"
)

func amount(file string) (int, error) {
	n, err := ioutil.ReadFile(file)
	if err != nil {
		return 0, err
	}

	v := n[:len(n)-1]
	return strconv.Atoi(string(v))
}

func (l *Load) Net(iface string) (Bytes, Bytes, error) {
	downf := fmt.Sprintf("/sys/class/net/%s/statistics/rx_bytes", iface)
	upf := fmt.Sprintf("/sys/class/net/%s/statistics/tx_bytes", iface)

	now := time.Now()
	var vals [2]int
	var err error

	if vals[0], err = amount(downf); err != nil {
		return ZeroBytes, ZeroBytes, err
	}
	if vals[1], err = amount(upf); err != nil {
		return ZeroBytes, ZeroBytes, err
	}

	timeDiff := now.Sub(l.lastNetStamp).Seconds()
	diff := [2]float64{
		float64(vals[0] - l.lastNet[0]),
		float64(vals[1] - l.lastNet[1]),
	}

	l.lastNet = vals
	l.lastNetStamp = now

	return NewBytes(diff[0]/timeDiff, B),
		NewBytes(diff[1]/timeDiff, B),
		nil
}
