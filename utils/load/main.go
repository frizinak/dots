package main

import (
	"bufio"
	"flag"
	"fmt"
	"io"
	"os"
	"time"

	"github.com/frizinak/load/load"
)

var nl = []byte{32}

func log(err error) {
	if err == nil {
		return
	}
	fmt.Fprintln(os.Stderr, err)
}

type mem struct {
	mem        load.Percentage
	memUnalloc load.Bytes
	memTotal   load.Bytes
}

type net struct {
	down load.Bytes
	up   load.Bytes
}

type data struct {
	clock load.ClockMHz
	cpu   load.Percentage
	temp  load.Temperature
	mem   mem
	net   net
}

func (d *data) writeTo(w io.Writer) error {
	var wErr error
	buf := bufio.NewWriter(w)
	wr := func(s string) {
		if wErr != nil {
			return
		}

		var err error
		if _, err = buf.WriteString(s); err != nil {
			wErr = err
			return
		}
		if _, err = buf.Write(nl); err != nil {
			wErr = err
		}
	}

	memtotal := d.mem.memTotal.Human()
	netunit := d.net.up.Human().Unit()
	if netunit < load.KiB {
		netunit = load.KiB
	}
	if downunit := d.net.down.Human().Unit(); downunit > netunit {
		netunit = downunit
	}

	wr(d.clock.GHz())
	wr(d.cpu.String())
	wr(d.temp.String())
	wr(d.mem.mem.String())
	wr(
		fmt.Sprintf("%s/%s",
			d.mem.memUnalloc.Convert(memtotal.Unit()).StringNoUnit(),
			memtotal.String(),
		),
	)
	wr(
		fmt.Sprintf("%s %s",
			d.net.up.Convert(netunit).StringNoUnit(),
			d.net.down.Convert(netunit).String(),
		),
	)

	if err := buf.Flush(); err != nil {
		return err
	}

	return wErr
}

func (d *data) write(file string) error {
	f, err := os.Create(file)
	if err != nil {
		return err
	}
	defer f.Close()
	return d.writeTo(f)
}

func main() {
	var flagIface string
	flag.StringVar(&flagIface, "iface", "", "network interface to monitor")
	flag.Parse()
	if flagIface == "" {
		fmt.Fprintln(os.Stderr, "Please provide a network interface")
		os.Exit(0)
	}

	l := load.New()

	clockCh := make(chan load.ClockMHz)
	cpuCh := make(chan load.Percentage)
	tempCh := make(chan load.Temperature)
	memCh := make(chan mem)
	netCh := make(chan net)

	type runner func() error
	make := func(sleep time.Duration, runner runner) {
		go func() {
			var err error
			for {
				err = runner()
				log(err)
				time.Sleep(sleep)
			}
		}()
	}

	make(time.Second*5, func() error {
		v, err := l.ClockMHz()
		clockCh <- v
		return err
	})
	make(time.Millisecond*500, func() error {
		v, err := l.CPU()
		cpuCh <- v
		return err
	})
	make(time.Millisecond*500, func() error {
		v, err := l.Temp(-1)
		tempCh <- v
		return err
	})
	make(time.Second, func() error {
		v1, v2, v3, err := l.Mem()
		memCh <- mem{v1, v2, v3}
		return err
	})
	make(time.Second, func() error {
		v1, v2, err := l.Net(flagIface)
		netCh <- net{v1, v2}
		return err
	})

	data := data{}
	after := func() <-chan time.Time {
		return time.After(time.Millisecond * 100)
	}

	a := after()
	var err error
	var u = false
	for {
		select {
		case data.clock = <-clockCh:
			u = true
		case data.cpu = <-cpuCh:
			u = true
		case data.temp = <-tempCh:
			u = true
		case data.mem = <-memCh:
			u = true
		case data.net = <-netCh:
			u = true
		case <-a:
			a = after()
			if !u {
				continue
			}
			u = false
			err = data.write("/tmp/load.log")
			log(err)
		}
	}
}
