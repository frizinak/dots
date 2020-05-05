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

var nl = []byte{10}
var colon = []byte(": ")

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
	bat   load.Percentage
}

func (d *data) writeTo(w io.Writer) error {
	var wErr error
	buf := bufio.NewWriter(w)
	wr := func(l, s string) {
		if wErr != nil {
			return
		}

		var err error
		if _, err = buf.WriteString(l); err != nil {
			wErr = err
			return
		}
		if _, err = buf.Write(colon); err != nil {
			wErr = err
			return
		}
		if _, err = buf.WriteString(s); err != nil {
			wErr = err
			return
		}
		if _, err = buf.Write(nl); err != nil {
			wErr = err
		}
	}

	memtotal := d.mem.memTotal.Human()

	wr("clock", d.clock.GHz())
	wr("load", d.cpu.String())
	wr("temp", d.temp.String())
	wr("memLoad", d.mem.mem.String())
	wr(
		"mem",
		fmt.Sprintf("%s/%s",
			d.mem.memUnalloc.Convert(memtotal.Unit()).StringNoUnit(),
			memtotal.String(),
		),
	)
	wr("netUp", d.net.up.Human().String())
	wr("netDown", d.net.down.Human().String())
	wr("bat", d.bat.String())
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
	batCh := make(chan load.Percentage)
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
	make(time.Second*5, func() error {
		v, err := l.Bat(0)
		batCh <- v
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
		case data.bat = <-batCh:
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
