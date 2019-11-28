package build

import (
	"fmt"
	"github.com/frizinak/linuxtheme/color"
	"io"
	"log"
	"os"
	"time"
)

type Colors struct {
	main []color.Color
	fg   color.Color
	bg   color.Color
}

func NewColors(colors []color.Color, fg, bg color.Color) *Colors {
	return &Colors{colors, fg, bg}
}

func (c *Colors) Colors() []color.Color {
	return c.main
}

func (c *Colors) FG() color.Color {
	return c.fg
}

func (c *Colors) BG() color.Color {
	return c.bg
}

func (c *Colors) Swap() {
	c.fg, c.bg = c.bg, c.fg
}

type Font string
type FontSize int

func (f Font) FontConfig(s FontSize) string {
	return fmt.Sprintf("%s-%d", f, s)
}

type Builder interface {
	Name() string
	Backup() (string, error)
	Build(*log.Logger, Font, FontSize, *Colors) error
	HasTest() bool
	Test(*log.Logger) error
	Restore(*log.Logger, string) error
	Finalize(*log.Logger) error
}

func TempFile(file string) string {
	return fmt.Sprintf("%s.linuxtheme.%s", file, time.Now().Format("2006-01-02--15-04-05"))
}

func CopyFile(dst, src string) error {
	dstf, err := os.Create(dst)
	if err != nil {
		return err
	}
	defer dstf.Close()
	srcf, err := os.Open(src)
	if err != nil {
		return err
	}
	defer srcf.Close()
	_, err = io.Copy(dstf, srcf)
	return err
}

func Build(b Builder, l *log.Logger, f Font, fs FontSize, c *Colors) error {
	err := build(b, l, f, fs, c)
	if err != nil {
		fmt.Fprint(l.Writer(), " ❌ \n")
	}
	return err
}

func build(b Builder, l *log.Logger, f Font, fs FontSize, c *Colors) error {
	w := l.Writer()
	fmt.Fprintf(w, "### Running %s\n", b.Name())
	format := "%s    %-12s"
	statusdef := " ✓ \n"
	status := ""
	fmt.Fprintf(w, format, status, "backup")
	status = statusdef

	backup, err := b.Backup()
	if err != nil {
		return err
	}

	fmt.Fprintf(w, format, status, "build")

	mainErr := b.Build(l, f, fs, c)
	if mainErr == nil {
		fmt.Fprintf(w, format, status, "test")
		status = " ❌ (no test available) \n"
		if b.HasTest() {
			mainErr = b.Test(l)
			status = statusdef
		}
	}

	if mainErr != nil {
		mainErr = fmt.Errorf("%w\nrestoring from '%s'", mainErr, backup)
		err = b.Restore(l, backup)
		if err != nil {
			mainErr = fmt.Errorf("%w\nrestoring from failed", mainErr)
			return mainErr
		}

		os.Remove(backup)
		return mainErr
	}

	fmt.Fprintf(w, format, status, "finalizing")
	os.Remove(backup)
	if err = b.Finalize(l); err != nil {
		return err
	}

	fmt.Fprint(w, statusdef)
	return nil
}
