package qutebrowser

import (
	"log"

	"github.com/frizinak/linuxtheme/build"
)

type Qutebrowser struct {
	file string
}

func New(file string) *Qutebrowser {
	return &Qutebrowser{file}
}

func (q *Qutebrowser) Name() string {
	return "qutebrowser"
}

func (q *Qutebrowser) Finalize(l *log.Logger) error {
	return nil
}

func (q *Qutebrowser) HasTest() bool {
	return false
}

func (q *Qutebrowser) Test(l *log.Logger) error {
	return nil
}

func (q *Qutebrowser) Restore(l *log.Logger, file string) error {
	return build.CopyFile(q.file, file)
}

func (q *Qutebrowser) Backup() (string, error) {
	tmp := build.TempFile(q.file)
	return tmp, build.CopyFile(tmp, q.file)
}

func (q *Qutebrowser) Build(l *log.Logger, f build.Font, s build.FontSize, c *build.Colors) error {
	return build.Simple(
		[]byte("color"),
		[]byte("font"),
		[]byte("fontSize"),
		[]byte("\""),
		nil,
		true,
		q.file,
		f,
		s,
		c,
	)
}
