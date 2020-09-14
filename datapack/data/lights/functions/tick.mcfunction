execute as @e[type=minecraft:armor_stand,tag=light,nbt={Fire:1s}] run data modify entity @s Fire set value 32767s
execute as @e[type=minecraft:armor_stand,tag=light,nbt={Fire:0s}] run data modify entity @s Fire set value 32767s
execute as @e[type=minecraft:armor_stand,tag=light,nbt={Fire:-1s}] run data modify entity @s Fire set value 32767s
execute as @e[type=minecraft:armor_stand,tag=deleter] at @s run kill @e[type=minecraft:armor_stand,tag=light,limit=1,distance=..2,sort=nearest]
execute as @e[type=minecraft:armor_stand,tag=deleter] at @s run kill @s