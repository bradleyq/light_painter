# Light Painter [EXPERIMENTAL!][1.21.4]
<img src="/images/2.png" alt="Image3"/>

## Overview
**MAY CONTAIN BUGS!!!**

**NOT COMPATIBLE WITH PREVIOUS VERSION!!! DO NOT LOAD OLD LIGHTS WITH THE NEW LIGHT PAINTER!!!**

Screen space point lights using MC's exposed transparency shaders. Requires "Fabulous" graphics setting.

### What it does:
- dynamic placable lights of any hue and any brightness
- customizable color using `custom_model_data` `colors` component
- fair performance hit (for what it does)
- datapack includes custom spawners for placing and deleting lights
- correctly blends with transparency
- lighting translucent blocks
- fade out at long ranges
- render occluded lights (most of the time)

### What it does not do:
- render out of frame lights
- does not factor in diffuse lighting equation (cos theta)
- shadows / occlusion checking

### What is achievable:
<table>
  <tr>
    <th width="33%">
      <img src="/images/0.png" alt="Image1"/>
      base world
    </th>
    <th width="33%">
      <img src="/images/1.png" alt="Image2"/>
      light markers added
    </th>
    <th width="33%">
      <img src="/images/2.png" alt="Image3"/>
      final result
    </th>
  </tr>
</table>

### Feature differences:
<table>
  <tr>
    <th width="15%">
      Version
    </th>
    <th width="15%">
      Range
    </th>
    <th width="15%">
      Tranlucent Shading
    </th>
    <th width="15%">
      Close Ups
    </th>
    <th width="15%">
      Long Range
    </th>
  </tr>
  <tr>
    <td width="16%">
      Universal
    </td>
    <td width="16%">
      128
    </td>
    <td width="16%">
      Yes
    </td>
    <td width="16%">
      Yes
    </td>
    <td width="16%">
      Yes
    </td>
  </tr>
  <tr>
    <td width="16%">
      Lite (deprecated)
    </td>
    <td width="16%">
      40
    </td>
    <td width="16%">
      No
    </td>
    <td width="16%">
      Yes
    </td>
    <td width="16%">
      No
    </td>
  </tr>
  <tr>
    <td width="16%">
      Standard (deprecated)
    </td>
    <td width="16%">
      48
    </td>
    <td width="16%">
      Yes
    </td>
    <td width="16%">
      Yes
    </td>
    <td width="16%">
      No
    </td>
  </tr>
  <tr>
    <td width="16%">
      Extended (deprecated)
    </td>
    <td width="16%">
      128
    </td>
    <td width="16%">
      Yes
    </td>
    <td width="16%">
      Ok...
    </td>
    <td width="16%">
      Yes
    </td>
  </tr>
</table>

## Design and Performance
This shader is composed of multiple passes in three main stages: finding light centers, constructing search tree, and computing final lighting per pixel. Performance is achieved through use of shading passes to store point light information in a designated light texture. This allows for vastly reduced texture accesses during the final rendering pass, resulting in performance that scales linarly with number of lights. This is by no means scientific, but the performance hit is around 50% with 50 lights. Real world performance scaling, however, is not linear. Use **Universal** version. Alternate versions are deprecated and not maintained.

## Usage
See License.md for license info. This utility is a resourcepack + datapack combo. Installation of the datapack is not strictly required, but it is useful for ease of use.
To get lights (datapack):
```
/function lights:give/....
```
To access lights to move or modify them (datapack):
```
/execute as @e[tag=light,sort=nearest,limit=1] ....
```

## Shading Passes and Descriptions
#### rendertype_item_entity_translucent_cull
- Transform custom model to billboard. Find approximate center pixel of marker and discard rest. Compress the marker depth to [0.0, 0.025], item entities use (0.025, 1.0].
#### filter
- Filter `minecraft:item_entity` target for light markers.
#### blur_custom
- Blur using pseudo random samples for better perf at same blur level.
#### centers
- Find centers of each light marker by discarding adjacent pixels.
#### aggregate_1, aggregate_2, aggregate_3, aggregate_4, aggregate_5
- Compute layers in search tree.
#### aggregate_6
- Traverses search tree to store light screen coordinates into a light storage texture.
#### light_apply, light_apply_t, light_apply_i
- Computes lighting color at each screen pixel and apply the lighting to designated target. `minecraft:main`, `minecraft:translucent`, `minecraft:item_entity`.
#### transparency
- Custom `transparency` pass that hides light markers and uses blend results of `light_apply` and `light_apply_t` for composite.

## Configuration
#### post_effect/transparency.json
- uniform `Range` light approximate range in blocks. Default 128.0.
- uniform `FOV` approximate FOV. Affects light position precision. Default 70.0.
- uniform `Intensity` light strength on solid objects. Default 1.0.
- uniform `IntensityT` light strength on translucent objects. Default 0.5.
#### shaders/include/utils.glsl
- `NEAR` near clipping plane in blocks. Do not change. Default 0.05.
- `FAR` approximate far clipping plane in blocks. Affects light position precision. Default 1024.0.
- `LIGHTR` distance in blocks where a pixel is considered out of a light's range. Default 8.0.
- `SPREAD` how much a light spreads. `BOOST` may need to increase if this increases. Default 3.0.
- `BOOST` how much to boost lights. Similar to `Intensity` but applies before composite and HDR mapping. Default 10.0.
- `CUTOFF` at what level where light is considered 0.0. Default 0.02.
- `LIGHTALPHA` marker texture alpha. Use an uncommon alpha, best if less than 0.1 and greater than `ALPHACUTOFF`. Default 24.0/255.0.
- `LIGHTDEPTH` depth buffer reserved for lights. Increase this to improve light position precision at the cost of minimum item depth. Default 0.025.

## Credits
- example screenshots are from the map "Cyberpunk Project" by Elysium Fire
- [Jatzylap](https://github.com/Jatzylap) for providing custom light colors using item tint
