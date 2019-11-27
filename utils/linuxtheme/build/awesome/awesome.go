package awesome

import (
	"log"

	"github.com/frizinak/linuxtheme/build"
)

type Awesome struct {
	file string
}

func New(file string) *Awesome {
	return &Awesome{file}
}

func (a *Awesome) Name() string {
	return "awesomewm"
}

func (a *Awesome) Finalize(l *log.Logger) error {
	return nil
}

func (a *Awesome) HasTest() bool {
	return false
}

func (a *Awesome) Test(l *log.Logger) error {
	return nil
}

func (a *Awesome) Restore(l *log.Logger, file string) error {
	return build.CopyFile(a.file, file)
}

func (a *Awesome) Backup() (string, error) {
	tmp := build.TempFile(a.file)
	return tmp, build.CopyFile(tmp, a.file)
}

func (a *Awesome) Build(l *log.Logger, f build.Font, s build.FontSize, c *build.Colors) error {
	return build.Simple(
		[]byte("local color"),
		[]byte("local font"),
		[]byte("local fontSize"),
		[]byte("\""),
		nil,
		true,
		a.file,
		f,
		s,
		c,
	)
}
