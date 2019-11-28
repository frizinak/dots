package image

import (
	"bufio"
	"errors"
	"os/exec"
	"strconv"
	"strings"

	"github.com/frizinak/linuxtheme/build"
	"github.com/frizinak/linuxtheme/color"
)

type Image struct {
	amount   uint
	dark     bool
	contrast float64
}

func New(amount uint, dark bool, contrast float64) *Image {
	return &Image{amount, dark, contrast}
}

func (l *Image) colors(file string, amount int) ([]color.Color, error) {
	cmd := exec.Command(
		"convert",
		file,
		"+dither",
		"-colors",
		strconv.Itoa(amount),
		"-define",
		"histogram:unique-colors=true",
		"-format",
		"%c",
		"histogram:info:-",
	)

	out, err := cmd.StdoutPipe()
	if err != nil {
		return nil, err
	}

	scanner := bufio.NewScanner(out)
	scanner.Split(bufio.ScanLines)
	if err := cmd.Start(); err != nil {
		return nil, err
	}

	colors := make([]color.Color, 0, amount)
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
			return nil, err
		}
		colors = append(colors, color.Color(v))
	}
	out.Close()

	if err := scanner.Err(); err != nil {
		return nil, err
	}

	return colors, cmd.Wait()
}

func (l *Image) Load(file string) (build.Font, build.FontSize, *build.Colors, error) {
	var font build.Font
	var size build.FontSize

	amount := int(l.amount)
	extra := float64(amount) * l.contrast
	colors, err := l.colors(file, amount+2+int(extra))
	if err != nil {
		return font, size, nil, err
	}

	if len(colors) < 2 {
		return font, size, nil, errors.New("less than 2 colors in theme file")
	}

	hsl := color.NewHSLs(colors)
	hsl.SortLightness()
	bg, fg := hsl[0].Modify(1, 1.1), hsl[len(hsl)-1].Modify(1, 0.9)
	hsl = hsl[1 : len(hsl)-1]
	hsl.SortHue()
	if len(hsl) < amount {
		amount = len(hsl)
	}

	jump := 2 * len(hsl) / amount
	hsl2 := make(color.HSLs, amount)
	n := 0
	hsl.SortHue()
	for i := 1; i < amount/2; i++ {
		next := hsl[n : n+jump]
		next.SortIntensity()
		hsl2[i] = next[len(next)-1]
		n += jump
	}

	hsl2[0] = bg.Modify(1, 1.8)
	hsl2[len(hsl2)/2-1] = fg
	if !l.dark {
		hsl2[0] = fg.Modify(1, 0.55)
		hsl2[len(hsl2)/2-1] = bg
	}

	for i := amount / 2; i < amount; i++ {
		hsl2[i] = hsl2[i-amount/2].Modify(0.9, 0.7)
	}

	colors = hsl2.Colors()
	c := build.NewColors(colors, fg.Color(), bg.Color())
	return font, size, c, nil
}
