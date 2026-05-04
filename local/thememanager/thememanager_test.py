#!/usr/bin/env python3
import importlib.machinery
import pathlib
import unittest


THEMEMANAGER_PATH = pathlib.Path(__file__).with_name("thememanager")
thememanager = importlib.machinery.SourceFileLoader(
    "thememanager", str(THEMEMANAGER_PATH)
).load_module()


class PaletteArtifactTests(unittest.TestCase):
    def test_build_palette_artifact_uses_v2_interface_only(self):
        base16 = {
            "background": "#202020",
            "foreground": "#eeeeee",
            "color0": "#111111",
            "color1": "#aa2222",
            "color2": "#22aa22",
            "color3": "#aaaa22",
            "color4": "#2222aa",
            "color5": "#aa22aa",
            "color6": "#22aaaa",
            "color7": "#dddddd",
            "color8": "#666666",
            "color9": "#ff5555",
            "color10": "#55ff55",
            "color11": "#ffff55",
            "color12": "#5555ff",
            "color13": "#ff55ff",
            "color14": "#55ffff",
            "color15": "#ffffff",
        }

        artifact = thememanager._build_palette_artifact(base16, "test")

        self.assertEqual(artifact["version"], 2)
        self.assertEqual(artifact["themeName"], "test")
        self.assertEqual(artifact["m3surface"], "#202020")
        self.assertEqual(artifact["m3onSurface"], "#eeeeee")
        self.assertEqual(artifact["term0"], "#111111")
        self.assertEqual(artifact["term15"], "#ffffff")

        for old_key in ("schema_version", "theme_name", "bg", "fg", "color0"):
            self.assertNotIn(old_key, artifact)


class AutoPaletteTests(unittest.TestCase):
    def test_matugen_colors_map_to_complete_base16_shape(self):
        colors = {
            "source_color": {"default": "#3366cc"},
            "background": {"default": "#010101"},
            "on_background": {"default": "#f0f0f0"},
            "surface_dim": {"default": "#020202"},
            "outline": {"default": "#333333"},
            "error": {"default": "#884444"},
            "tertiary": {"default": "#448844"},
            "tertiary_fixed": {"default": "#888844"},
            "primary": {"default": "#444488"},
            "secondary": {"default": "#884488"},
            "outline_variant": {"default": "#448888"},
        }

        base16 = thememanager._base16_from_matugen_colors(colors)

        expected_keys = {"background", "foreground"} | {
            f"color{i}" for i in range(16)
        }
        self.assertEqual(set(base16), expected_keys)
        for value in base16.values():
            self.assertRegex(value, r"^#[0-9a-f]{6}$")

    def test_matugen_dark_neutrals_are_lifted(self):
        base16 = thememanager._base16_from_matugen_colors(
            {
                "source_color": {"default": "#cc0403"},
                "background": {"default": "#000000"},
                "surface_dim": {"default": "#000000"},
                "outline": {"default": "#000000"},
                "on_surface_variant": {"default": "#000000"},
                "on_background": {"default": "#000000"},
                "on_surface": {"default": "#000000"},
            }
        )

        self.assertGreaterEqual(thememanager._hex_to_lch(base16["background"])[0], 14.9)
        self.assertGreaterEqual(thememanager._hex_to_lch(base16["color0"])[0], 11.5)
        self.assertGreaterEqual(thememanager._hex_to_lch(base16["color8"])[0], 39.9)
        self.assertGreaterEqual(thememanager._hex_to_lch(base16["foreground"])[0], 79.5)


if __name__ == "__main__":
    unittest.main()
