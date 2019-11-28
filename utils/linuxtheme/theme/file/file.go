package file

import (
	"bufio"
	"errors"
	"io"
	"os"
	"strconv"
	"strings"

	"github.com/frizinak/linuxtheme/build"
	"github.com/frizinak/linuxtheme/color"
)

type File struct {
}

func New() *File {
	return &File{}
}

func (l *File) Load(file string) (build.Font, build.FontSize, *build.Colors, error) {
	var font build.Font
	var size build.FontSize

	f, err := os.Open(file)
	if err != nil {
		return font, size, nil, err
	}
	defer f.Close()

	colors := make([]color.Color, 0, 10)

	scanner := bufio.NewScanner(f)
	scanner.Split(bufio.ScanLines)
	for scanner.Scan() {
		l := strings.TrimSpace(scanner.Text())
		if l == "" {
			continue
		}
		if l[0] == '#' {
			l = strings.ToLower(l)
			v, err := strconv.ParseUint(l[1:], 16, 32)
			if err != nil {
				return font, size, nil, err
			}
			colors = append(colors, color.Color(v))
			continue
		}

		font = build.Font(l)
		ps := strings.Split(l, " ")
		if len(ps) < 2 {
			continue
		}

		s, err := strconv.Atoi(ps[len(ps)-1])
		if err == nil {
			size = build.FontSize(s)
			font = build.Font(strings.TrimSpace(strings.Join(ps[:len(ps)-1], " ")))
			continue
		}

		s, err = strconv.Atoi(ps[0])
		if err == nil {
			size = build.FontSize(s)
			font = build.Font(strings.TrimSpace(strings.Join(ps[1:], " ")))
			continue
		}
	}

	if len(colors) < 2 {
		return font, size, nil, errors.New("less than 2 colors in theme file")
	}

	c := build.NewColors(colors[2:], colors[0], colors[1])
	return font, size, c, nil
}

func (l *File) Export(w io.Writer, f build.Font, s build.FontSize, c *build.Colors) error {
	nl := []byte{10}
	buf := bufio.NewWriter(w)
	var werr error
	wb := func(b []byte) {
		if werr != nil {
			return
		}
		if _, err := buf.Write(b); err != nil {
			werr = err
		}
	}
	ws := func(b string) {
		if werr != nil {
			return
		}
		if _, err := buf.WriteString(b); err != nil {
			werr = err
		}
	}
	ws(c.FG().Hex("#"))
	wb(nl)
	ws(c.BG().Hex("#"))
	wb(nl)
	wb(nl)

	for i, c := range c.Colors() {
		ws(c.Hex("#"))
		wb(nl)
		if (i+1)%8 == 0 {
			wb(nl)
		}
	}

	ws(string(f))
	ws(" ")
	ws(strconv.Itoa(int(s)))

	if err := buf.Flush(); err != nil {
		return err
	}
	return werr
}
