package main

import (
	"flag"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"strings"

	"github.com/frizinak/linuxtheme/build"
	"github.com/frizinak/linuxtheme/build/awesome"
	"github.com/frizinak/linuxtheme/build/qutebrowser"
	"github.com/frizinak/linuxtheme/build/st"
	"github.com/frizinak/linuxtheme/theme"
	"github.com/frizinak/linuxtheme/theme/file"
	"github.com/frizinak/linuxtheme/theme/image"
)

func main() {
	var flagSt string
	var flagStNoInstall bool
	var flagStNoFont bool
	var flagAwesome string
	var flagQutebrowser string
	flag.StringVar(&flagSt, "st", "", "st build dir")
	flag.BoolVar(&flagStNoInstall, "st-noinstall", false, "don't install st")
	flag.BoolVar(&flagStNoFont, "st-nofont", false, "don't replace st font")
	flag.StringVar(&flagAwesome, "awesome", "", "awesomewm lua file to put colors in")
	flag.StringVar(&flagQutebrowser, "qutebrowser", "", "qutebrowser .py file to put colors in")

	var flagSwap bool
	var flagColors uint
	var flagContrast float64
	var flagExport bool
	flag.BoolVar(&flagSwap, "swap", false, "swap fg and bg")
	flag.UintVar(&flagColors, "colors", 16, "amount of colors to extract from images")
	flag.Float64Var(&flagContrast, "contrast", 0.5, "contrast multiplier (0 = even spread, 1 is double, ...)")
	flag.BoolVar(&flagExport, "export", false, "export theme to stdout")

	flag.Usage = func() {
		fmt.Printf("%s [flags] <theme|image>\n\n  flags:\n", os.Args[0])
		flag.PrintDefaults()
	}

	flag.Parse()

	logerr := log.New(os.Stderr, "", 0)
	args := flag.Args()
	if len(args) == 0 {
		logerr.Fatal("Specify an image or theme file")
	}

	builders := make([]build.Builder, 0)
	if flagSt != "" {
		builders = append(builders, st.New(flagSt, !flagStNoInstall, !flagStNoFont))
	}
	if flagAwesome != "" {
		builders = append(builders, awesome.New(flagAwesome))
	}
	if flagQutebrowser != "" {
		builders = append(builders, qutebrowser.New(flagQutebrowser))
	}

	file := file.New()
	var loader theme.Theme = file
	ext := strings.ToLower(filepath.Ext(args[0]))
	if ext == ".jpg" || ext == ".png" || ext == ".jpeg" {
		loader = image.New(flagColors, !flagSwap, flagContrast)
	}

	font, fontSize, colors, err := loader.Load(args[0])
	if err != nil {
		logerr.Fatal(err)
	}

	if fontSize < 1 {
		fontSize = 12
	}

	if flagSwap {
		colors.Swap()
	}

	log := log.New(os.Stdout, "", 0)
	if flagExport {
		if font == "" {
			font = "monospace"
		}
		if err := file.Export(os.Stdout, font, fontSize, colors); err != nil {
			logerr.Fatal(err)
		}
		return
	}

	for _, b := range builders {
		if err := build.Build(b, log, font, fontSize, colors); err != nil {
			logerr.Println(err)
		}
	}
}
