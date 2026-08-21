# Polygon Counter Plugin

## Description
A Godot plugin that counts polygons and vertices for selected `MeshInstance3D`, `CSGShape3D`, and `CSGCombiner3D` nodes in the scene.

## Installation
1. Download the `polygon_counter` folder.
2. Place it in your project's `addons/` directory.
3. Enable the plugin in `Project > Project Settings > Plugins`.
4. Restart Godot or re-enable the plugin.

## Usage
- Select a 3D node (e.g., `MeshInstance3D` or `CSGBox3D`) in the scene tree.
- The "Polygon Counter" dock at the bottom will display the polygon and vertex counts.
- Toggle visibility with the "Poly Count" button in the toolbar.

## Known Limitations
- CSG node counting uses manual values (12 polygons, 8 vertices for a default `CSGBox3D`) due to a bug in Godot 4.4 alpha with `get_meshes()`. This may not reflect modified shapes.
- Tested on Godot 4.4 alpha; compatibility with other versions (e.g., 4.3) is unverified.

## License
MIT License (see LICENSE.md)
