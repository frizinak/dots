package image

import (
	"bufio"
	"errors"
	"os/exec"
	"strconv"
	"strings"

	"github.com/frizinak/linuxtheme/build"
)

type Image struct {
	amount   uint
	dark     bool
	contrast float64
}

func New(amount uint, dark bool, contrast float64) *Image {
	return &Image{amount, dark, contrast}
}

func (l *Image) Load(file string) (build.Font, build.FontSize, *build.Colors, error) {
	var font build.Font
	var size build.FontSize

	amount := int(l.amount)
	extra := float64(amount) * l.contrast
	cmd := exec.Command(
		"convert",
		file,
		"+dither",
		"-colors",
		strconv.Itoa(amount+2+int(extra)),
		"-define",
		"histogram:unique-colors=true",
		"-format",
		"%c",
		"histogram:info:-",
	)

	out, err := cmd.StdoutPipe()
	if err != nil {
		return font, size, nil, err
	}

	scanner := bufio.NewScanner(out)
	scanner.Split(bufio.ScanLines)
	if err := cmd.Start(); err != nil {
		return font, size, nil, err
	}

	colors := make([]build.Color, 0, 10)
	for scanner.Scan() {
		t := strings.Split(strings.TrimSpace(scanner.Text()), " ")
		ix := -1
		for i := range t {
			if len(t[i]) >= 7 && t[i][0] == '#' {
				ix = i
				break
			}
		}
		if ix == -1 {
			continue
		}

		v, err := strconv.ParseUint(t[ix][1:7], 16, 32)
		if err != nil {
			return font, size, nil, err
		}
		colors = append(colors, build.Color(v))
	}
	out.Close()

	if err := scanner.Err(); err != nil {
		return font, size, nil, err
	}

	if err := cmd.Wait(); err != nil {
		return font, size, nil, err
	}

	if len(colors) < 2 {
		return font, size, nil, errors.New("less than 2 colors in theme file")
	}

	fg, bg := colors[len(colors)-1], colors[0]
	colors = colors[1 : len(colors)-1]
	shift := len(colors) - amount
	if shift < 0 {
		shift = 0
	}
	shiftL := shift
	shiftR := 0
	if !l.dark {
		shiftL, shiftR = shiftR, shiftL
	}

	colors = colors[shiftL : len(colors)-shiftR]
	offset := len(colors) / 2
	clrs := make([]build.Color, len(colors))
	for i := 0; i < len(clrs); i += 2 {
		clrs[i], clrs[i/2+offset] = colors[i/2], colors[i+1]
		clrs[i], clrs[i+1] = colors[i/2], colors[i/2+offset]
	}

	c := build.NewColors(clrs, fg, bg)
	return font, size, c, nil
}
