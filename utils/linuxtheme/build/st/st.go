package st

import (
	"bufio"
	"bytes"
	"errors"
	"fmt"
	"io"
	"log"
	"os"
	"os/exec"
	"path/filepath"

	"github.com/frizinak/linuxtheme/build"
)

type St struct {
	install bool
	dir     string
	file    string
}

func New(dir string, install bool) *St {
	return &St{install, dir, filepath.Join(dir, "config.h")}
}

func (st *St) Name() string {
	return "st"
}

func (st *St) Finalize(l *log.Logger) error {
	if !st.install {
		return nil
	}
	return makeInstall(l, st.dir)
}

func (st *St) HasTest() bool {
	return true
}

func (st *St) Test(l *log.Logger) error {
	if err := make(st.dir); err != nil {
		return fmt.Errorf("build failed: %w", err)
	}
	return nil
}

func (st *St) Restore(l *log.Logger, file string) error {
	return build.CopyFile(st.file, file)
}

func (st *St) Backup() (string, error) {
	tmp := build.TempFile(st.file)
	if err := make(st.dir); err != nil {
		return "", errors.New(
			"build failed as is, check dir or fix whatever keeps st from building",
		)
	}
	return tmp, build.CopyFile(tmp, st.file)
}

func (st *St) Build(l *log.Logger, f build.Font, s build.FontSize, c *build.Colors) error {
	config := filepath.Join(st.dir, "config.h")
	scratch := bytes.NewBuffer(nil)
	configf, err := os.Open(config)
	if err != nil {
		return err
	}

	scanner := bufio.NewScanner(configf)
	scanner.Split(bufio.ScanLines)
	fontLine := []byte(" *font =")
	colorStart := []byte(" *colorname[] =")
	defaultStartFg := []byte("defaultfg =")
	defaultStartBg := []byte("defaultbg =")
	defaultStartCs := []byte("defaultcs =")
	defaultStartRcs := []byte("defaultrcs =")
	colorEnd := []byte("};")
	comment := []byte("/")
	var color bool

	for scanner.Scan() {
		d := scanner.Bytes()
		if !bytes.HasPrefix(d, comment) {
			if f != "" && bytes.Contains(d, fontLine) {
				continue
			}

			if bytes.Contains(d, defaultStartFg) ||
				bytes.Contains(d, defaultStartBg) ||
				bytes.Contains(d, defaultStartCs) ||
				bytes.Contains(d, defaultStartRcs) {
				continue
			}

			if color && bytes.Contains(d, colorEnd) {
				color = false
				continue
			} else if color {
				continue
			} else if bytes.Contains(d, colorStart) {
				color = true
				continue
			}
		}

		d = append(d, 10)
		scratch.Write(d)
	}
	configf.Close()

	if err := scanner.Err(); err != nil {
		return err
	}

	w, err := os.Create(config)
	if err != nil {
		return err
	}
	defer w.Close()

	if _, err := io.Copy(w, scratch); err != nil {
		return err
	}

	if _, err := w.Write(formatColors(c)); err != nil {
		return err
	}

	if _, err := w.Write(formatDefaults()); err != nil {
		return err
	}

	if f != "" {
		if _, err := w.Write(formatFont(f, s)); err != nil {
			return err
		}
	}

	return nil
}

func make(dir string) error {
	return exec.Command("make", "-C", dir).Run()
}

func makeInstall(l *log.Logger, dir string) error {
	return exec.Command("sudo", "make", "-C", dir, "install").Run()
	// cmd := exec.Command("sudo", "make", "-C", dir, "install")
	// if cmd.Run() == nil {
	// 	return nil
	// }

	// l.Println("Installing st (sudo make install)")
	// // cmd.Stdin = os.Stdin
	// // cmd.Stderr = os.Stderr
	// // cmd.Stdout = os.Stdout
	// return cmd.Run()
}

func formatDefaults() []byte {
	d := bytes.NewBuffer(nil)
	d.WriteString("unsigned int defaultfg = 256;\n")
	d.WriteString("unsigned int defaultbg = 257;\n")
	d.WriteString("unsigned int defaultcs = 7;\n")
	d.WriteString("unsigned int defaultrcs = 0;\n")

	return d.Bytes()
}

func formatFont(f build.Font, s build.FontSize) []byte {
	quote := []byte("\"")
	eol := []byte(";\n")
	d := bytes.NewBuffer(nil)
	d.WriteString("static char *font = ")
	d.Write(quote)
	d.WriteString(f.FontConfig(s))
	d.Write(quote)
	d.Write(eol)
	return d.Bytes()
}

func formatColors(c *build.Colors) []byte {
	indent := []byte("    ")
	eol := []byte(",\n")
	quote := []byte("\"")
	nl := []byte("\n")

	colors := c.Colors()
	d := bytes.NewBuffer(nil)
	d.WriteString("static const char *colorname[] = {")
	d.Write(nl)

	for i := range colors {
		d.Write(indent)
		d.Write(quote)
		d.WriteString(colors[i].Hex("#"))
		d.Write(quote)
		d.Write(eol)
		if (i+1)%8 == 0 {
			d.Write(nl)
		}
	}
	d.Write(indent)
	d.WriteString("[255] = 0")
	d.Write(eol)
	d.Write(nl)

	d.Write(indent)
	d.Write(quote)
	d.WriteString(c.FG().Hex("#"))
	d.Write(quote)
	d.Write(eol)

	d.Write(indent)
	d.Write(quote)
	d.WriteString(c.BG().Hex("#"))
	d.Write(quote)
	d.Write(nl)

	d.WriteString("};")
	d.Write(nl)
	return d.Bytes()
}
