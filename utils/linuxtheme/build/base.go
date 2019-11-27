package build

import (
	"bufio"
	"bytes"
	"io"
	"os"
	"strconv"
	"strings"
)

func Simple(
	colorPrefix,
	fontPrefix,
	fontSizePrefix []byte,
	stringDelim,
	lineEnd []byte,
	prepend bool,
	file string,
	f Font,
	s FontSize,
	c *Colors,
) error {
	scratch := bytes.NewBuffer(nil)
	config, err := os.Open(file)
	if err != nil {
		return err
	}

	colors := c.Colors()
	scanner := bufio.NewScanner(config)
	scanner.Split(bufio.ScanLines)
	for scanner.Scan() {
		d := scanner.Bytes()
		d = append(d, 10)
		if f != "" &&
			bytes.HasPrefix(d, fontPrefix) &&
			len(d) > len(fontPrefix)+1 {
			v := d[len(fontPrefix)]
			if v == ' ' || v == '=' {
				continue
			}
		}

		if f != "" &&
			bytes.HasPrefix(d, fontSizePrefix) &&
			len(d) > len(fontSizePrefix)+1 {
			v := d[len(fontSizePrefix)]
			if v == ' ' || v == '=' {
				continue
			}
		}

		if bytes.HasPrefix(d, colorPrefix) &&
			len(d) > len(colorPrefix)+2 {
			v := d[len(colorPrefix) : len(colorPrefix)+3]
			if v[len(v)-1] == ' ' || v[len(v)-1] == '=' {
				s := strings.Trim(string(v), " =")
				n, err := strconv.Atoi(s)
				if (err == nil && n-1 >= 0 && n-1 < len(colors)) ||
					s == "Fg" || s == "Bg" {
					continue
				}
			}
		}

		scratch.Write(d)
	}
	config.Close()

	if err := scanner.Err(); err != nil {
		return err
	}

	scratch2 := bytes.NewBuffer(nil)
	eol := []byte{10}
	equalSign := []byte(" = ")
	wr := func(b ...[]byte) {
		for i := range b {
			scratch2.Write(b[i])
		}
	}

	wcolor := func(s string, c Color) {
		wr(colorPrefix)
		scratch2.WriteString(s)
		wr(equalSign, stringDelim)
		scratch2.WriteString(c.Hex("#"))
		wr(stringDelim, lineEnd, eol)
	}

	for i, c := range colors {
		wcolor(strconv.Itoa(i+1), c)
	}
	wcolor("Fg", c.FG())
	wcolor("Bg", c.BG())

	if f != "" {
		wr(fontPrefix, equalSign, stringDelim)
		scratch2.WriteString(string(f))
		wr(stringDelim, lineEnd, eol)
		wr(fontSizePrefix, equalSign)
		scratch2.WriteString(strconv.Itoa(int(s)))
		wr(eol)
	}

	w, err := os.Create(file)
	if err != nil {
		return err
	}
	defer w.Close()

	if !prepend {
		scratch, scratch2 = scratch2, scratch
	}

	_, err = io.Copy(w, io.MultiReader(scratch2, scratch))
	if err != nil {
		return err
	}

	return nil
}
