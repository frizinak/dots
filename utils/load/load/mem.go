package load

import (
	"bytes"
	"strconv"
)

var (
	prefixTotal   = []byte("MemTotal:")
	prefixFree    = []byte("MemFree:")
	prefixBuffers = []byte("Buffers:")
	prefixCached  = []byte("Cached:")

	prefixListTotal   = [][]byte{prefixTotal}
	prefixListFree    = [][]byte{prefixFree, prefixBuffers, prefixCached}
	prefixListUnalloc = [][]byte{prefixFree}
)

func (l *Load) Mem() (Percentage, Bytes, Bytes, error) {
	var free int
	var total int
	var unalloc int

	add := func(v *int, list [][]byte, b []byte) error {
		for _, p := range list {
			if !bytes.HasPrefix(b, p) {
				continue
			}

			i := len(b) - 4
			for ; i > 0; i-- {
				if b[i] == ' ' {
					break
				}
			}

			n, err := strconv.Atoi(string(b[i+1 : len(b)-3]))
			if err != nil {
				return err
			}

			*v += n
		}

		return nil
	}

	cb := func(b []byte) error {
		if err := add(&free, prefixListFree, b); err != nil {
			return err
		}
		if err := add(&total, prefixListTotal, b); err != nil {
			return err
		}
		if err := add(&unalloc, prefixListUnalloc, b); err != nil {
			return err
		}

		return nil
	}

	if err := scan("/proc/meminfo", cb); err != nil {
		return 0, ZeroBytes, ZeroBytes, err
	}

	return Percentage(1 - float64(free)/float64(total)),
		NewBytes(float64(unalloc), KiB),
		NewBytes(float64(total), KiB),
		nil
}
