# Light Painter [1.21]
<img src="/images/2.png" alt="Image3"/>

## Overview
**NOT COMPATIBLE WITH PREVIOUS VERSION!!! DO NOT LOAD OLD LIGHTS WITH THE NEW LIGHT PAINTER!!!**
Screen space point lights using MC's exposed transparency shaders. Requires "Fabulous" graphics setting.

### What it does:
- dynamic placable lights of any hue and any brightness
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
      Lite
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
      Standard
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
      Extended
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
  <tr>
    <td width="16%">
      Baseline
    </td>
    <td width="16%">
      N/A
    </td>
    <td width="16%">
      N/A
    </td>
    <td width="16%">
      N/A
    </td>
    <td width="16%">
      N/A
    </td>
  </tr>
</table>

## Design and Performance
This shader is composed of multiple passes in three main stages: finding light centers, constructing search tree, and computing final lighting per pixel. Performance is achieved through use of shading passes to store point light information in a designated strip on the screen. This allows for vastly reduced texture accesses during the final rendering pass, resulting in performance that scales linarly with number of lights. This is by no means scientific, but the performance hit is around 50% with 50 lights. Real world performance scaling, however, is not linear. Expect best performance with **Lite** and worst with **Extended**.

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
- Transform custom model to billboard. Find approximate center pixel of marker and discard rest.
#### filter
- Filter `itemEntity` target for light markers.
#### blur_custom
- Blur using pseudo random samples for better perf at same blur level.
#### centers
- Find centers of each light marker by discarding adjacent pixels.
#### aggregate_1, aggregate_2, aggregate_3, aggregate_4, aggregate_5
- Compute layers in search tree.
#### aggregate_6
- Traverses search tree to store light screen coordinates into bottom two pixel rows.
#### light, light_t
- Computes lighting color at each screen pixel. This pass is run on diffuse and transparency targets respectively.
#### light_apply, light_apply_t
- Apply lighting to designated target.
#### transparency
- Custom `transparency` pass that hides light markers and uses blend results of `light_apply` and `light_apply_t` for composite.


## Credits
- example screenshots are from the map "Cyberpunk Project" by Elysium Fire
