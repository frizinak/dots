package theme

import "github.com/frizinak/linuxtheme/build"

type Theme interface {
	Load(string) (build.Font, build.FontSize, *build.Colors, error)
}
