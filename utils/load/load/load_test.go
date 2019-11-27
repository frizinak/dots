package load

import (
	"testing"
)

func new() *Load {
	return New()
}

func BenchmarkClock(b *testing.B) {
	l := new()
	var err error
	for n := 0; n < b.N; n++ {
		if _, err = l.ClockMHz(); err != nil {
			b.Fatal(err)
		}
	}
}

func BenchmarkCPU(b *testing.B) {
	l := new()
	l.CPU()
	var err error
	for n := 0; n < b.N; n++ {
		if _, err = l.CPU(); err != nil {
			b.Fatal(err)
		}
	}
}

func BenchmarkTemp(b *testing.B) {
	l := new()
	var err error
	for n := 0; n < b.N; n++ {
		if _, err = l.Temp(-1); err != nil {
			b.Fatal(err)
		}
	}
}

func BenchmarkTemp1(b *testing.B) {
	l := new()
	var err error
	for n := 0; n < b.N; n++ {
		if _, err = l.Temp(1); err != nil {
			b.Fatal(err)
		}
	}
}

func BenchmarkMem(b *testing.B) {
	l := new()
	var err error
	for n := 0; n < b.N; n++ {
		if _, _, _, err = l.Mem(); err != nil {
			b.Fatal(err)
		}
	}
}

func BenchmarkNet(b *testing.B) {
	l := new()
	var err error
	for n := 0; n < b.N; n++ {
		if _, _, err = l.Net("eno1"); err != nil {
			b.Fatal(err)
		}
	}
}
