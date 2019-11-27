package build

import "testing"

func TestHex(t *testing.T) {
	asserts := map[string]Color{
		"#ffffff": Color(16777215),
		"#0000ff": Color(0x0000ff),
		"#3300ff": Color(0x3300ff),
		"#333333": Color(0x333333),
		"#003333": Color(0x003333),
	}
	for s, u := range asserts {
		if tt := u.Hex("#"); s != tt {
			t.Errorf("%s is not expected %s", tt, s)
		}
	}
}
