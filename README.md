# Light Painter

### Overview
Screen space point lights using MC's exposed transparency shaders. 

**What it does:**
- dynamic placable lights of any hue
- low performance hit
- datapack includes custom spawners for placing and deleting lights
- functions correctly with transparency

**What it does not do:**
- render out of frame lights
- render occluded lights
- does not factor in diffuse lighting equation (cos theta)
- shadows / occlusion checking

This shader is composed of multiple passes in three main stages: finding light centers, constructing search tree, and computing final lighting per pixel. Performance is achieved through the idea of using shading passes to store point light information in a designated strip on the screen. This allows for minimal accesses during the final rendering pass, letting performance scale linarly with number of lights. In most cases, the performance hit induced by armor stands will outweigh the performance hit of the lights.
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

### Usage
This utility is a resourcepack + datapack combo. Installation of the datapack is not strictly required, but it is useful for ease of use.
To get lights (datapack):
```
/function lights:give/....
```
To access lights to move or modify them (datapack):
```
/execute as @e[tag=light,sort=nearest,limit=1] ....
```
