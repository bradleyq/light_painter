# Light Painter
<img src="/images/2.png" alt="Image3"/>

## Overview
Screen space point lights using MC's exposed transparency shaders. 

### What it does:
- dynamic placable lights of any hue (all hues will be max brightness)
- low performance hit
- datapack includes custom spawners for placing and deleting lights
- correctly blends with transparency
- range up to **48 blocks**. check out the `extended_range` branch for a longer range variant (less reliable up close)

### What it does not do:
- render out of frame lights
- render occluded lights
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

## Design and Performance
This shader is composed of multiple passes in three main stages: finding light centers, constructing search tree, and computing final lighting per pixel. Performance is achieved through use of shading passes to store point light information in a designated strip on the screen. This allows for vastly reduced texture accesses during the final rendering pass, resulting in performance that scales linarly with number of lights. In most cases, the performance hit induced by armor stands will outweigh the performance hit of the lighting calculations.

## Usage
See License.md for license info. This version is limited to a **48 block** range! Check out the `extended_range` branch for longer range but more prone to occlusion. This utility is a resourcepack + datapack combo. Installation of the datapack is not strictly required, but it is useful for ease of use.
To get lights (datapack):
```
/function lights:give/....
```
To access lights to move or modify them (datapack):
```
/execute as @e[tag=light,sort=nearest,limit=1] ....
```

## Shading Passes and Descriptions
#### filter
- Filter `itemEntity` target for light markers.
#### centers
- Finds approximate centers of each light marker by searching outward from current pixel. Accounts for FOV distortion.
#### centers_med
- Attempts to find exact center of approximate center cluster.
#### centers_fine
- Account for fp inaccuracy and gurantees single pixel center per light.
#### aggregate_1, aggregate_2, aggregate_3, aggregate_4, aggregate_5
- Compute layers in search tree.
#### aggregate_6
- Traverses search tree to store light screen coordinates into bottom two pixel rows.
#### light
- Computes lighting color at each screen pixel. This pass is run on both diffuse and transparency targets.
#### light_apply, light_apply_t
- Apply lighting to designated target.
#### transparency
- Custom `transparency` pass that hides light markers and uses blend results of `light_apply` and `light_apply_t` for composite.


## Credits
- example screenshots are from the map "Cyberpunk Project" by Elysium Fire
