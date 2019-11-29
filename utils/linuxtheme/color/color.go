package color

import (
	"fmt"
	"math"
	"sort"
)

type HSL struct {
	c         Color
	h         float64
	s         float64
	l         float64
	intensity float64
}

func (hsl HSL) Hue() float64        { return hsl.h }
func (hsl HSL) Saturation() float64 { return hsl.s }
func (hsl HSL) Lightness() float64  { return hsl.l }
func (hsl HSL) Intensity() float64  { return hsl.intensity }
func (hsl HSL) Color() Color        { return hsl.c }

func (hsl HSL) Modify(saturation float64, lightness float64) HSL {
	hsl.s = (hsl.s + saturation) / 2
	if hsl.s < 0 {
		hsl.s = 0
	} else if hsl.s > 1 {
		hsl.s = 1
	}
	hsl.l = (hsl.l + lightness) / 2
	if hsl.l < 0 {
		hsl.l = 0
	} else if hsl.l > 1 {
		hsl.l = 1
	}

	if hsl.s == 0 {
		l := uint32(255 * hsl.l)
		hsl.c = Color(l<<16 + l<<8 + l)
		return hsl
	}

	v1 := hsl.l * (1.0 + hsl.s)
	if hsl.l >= 0.5 {
		v1 = hsl.l + hsl.s - hsl.l*hsl.s
	}
	v2 := 2*hsl.l - v1

	const m float64 = 255.0
	const th float64 = 1.0 / 3.0

	conv := func(v float64) uint32 {
		if v > 1 {
			v -= 1
		} else if v < 0 {
			v += 1
		}

		switch {
		case v < 1.0/6:
			return uint32(m * (v2 + (v1-v2)*6*v))
		case v < 1.0/2:
			return uint32(m * v1)
		case v < 2.0/3:
			return uint32(m * (v2 + (v1-v2)*(2.0/3-v)*6))
		}
		return uint32(m * v2)
	}

	hsl.c = Color(conv(hsl.h+th)<<16 + conv(hsl.h)<<8 + conv(hsl.h-th))
	return hsl
}

func (hsl HSL) String() string {
	return fmt.Sprintf("#%06x %.2f %.2f %.2f %.2f", hsl.c, hsl.h, hsl.s, hsl.l, hsl.intensity)
}

type HSLs []HSL

func (hsls HSLs) Colors() []Color {
	clrs := make([]Color, len(hsls))
	for i := range hsls {
		clrs[i] = hsls[i].c
	}

	return clrs
}

func (hsls HSLs) SortIntensity() {
	sort.Slice(hsls, func(i, j int) bool {
		return hsls[i].intensity < hsls[j].intensity
	})
}
func (hsls HSLs) SortHue() {
	sort.Slice(hsls, func(i, j int) bool {
		return hsls[i].h < hsls[j].h
	})
}

func (hsls HSLs) SortSaturation() {
	sort.Slice(hsls, func(i, j int) bool {
		return hsls[i].s < hsls[j].s
	})
}

func (hsls HSLs) SortLightness() {
	sort.Slice(hsls, func(i, j int) bool {
		return hsls[i].l < hsls[j].l
	})
}

func NewHSLs(cs []Color) HSLs {
	c := make(HSLs, len(cs))
	for i := range cs {
		c[i] = cs[i].HSL()
	}
	return c
}

type Color uint32

func (c Color) Hex(prefix string) string {
	return fmt.Sprintf("%s%06x", prefix, c)
}

func (c Color) HSL() HSL {
	_r := c >> 16
	_g := (c - _r<<16) >> 8
	_b := (c - _r<<16 - _g<<8)
	r, g, b := float64(_r)/255, float64(_g)/255, float64(_b)/255
	max := math.Max(math.Max(r, g), b)
	min := math.Min(math.Min(r, g), b)
	var h, s, l float64

	l = (max + min) / 2
	s = (max - min) / (2 - max - min)
	if l < 0.5 {
		s = (max - min) / (max + min)
	}
	if s < 0 || s > 1 || math.IsNaN(s) {
		s = 1
	}

	h = 0
	switch {
	case max == min:
	case max == r:
		h = 0 + (g-b)/(max-min)
	case max == g:
		h = 2 + (b-r)/(max-min)
	case max == b:
		h = 4 + (r-g)/(max-min)
	}
	h = 60 * h
	if h < 0 {
		h += 360
	}
	h /= 360

	nl := l - 0.5
	if nl > 0 {
		nl = -nl
	}

	return HSL{c, h, s, l, s + 2*(nl+0.5)}
}
