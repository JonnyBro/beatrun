AddCSLuaFile()

--[[ IN BOTH CASES: NAME SHOULD BE THE ACTUAL SEQUENCE NAME
You don't have to put every value, but some like model are obviously needed

Hands
"model" - path to model
"lerp_peak" - time when the hand should transition back to the weapon
"lerp_speed_in" - speed at which the hand transitions into the anim
"lerp_speed_out" - speed at which the hand transitions out of the anim
"lerp_curve" - power of the curve
"speed" - playback speed
"startcycle" - time to start the anim at
"cam_ang" - angle offset for the camera
"cam_angint" - intensity multiplier of the camera
"sounds" - table of sounds, keys represent the path and their value the time it plays at. do not use past holdtime lmao
"loop" - loop the anim instead of stopping
"segmented" - when anim is over, freezes it and waits for SegmentPlay(sequence,lastanim). Repeat if lastanim is false
^Note: lerp peak and related values are used for the "last segment" instead.

"holdtime" - the time when the anim should be paused
"preventquit" - ONLY accept QuitHolding request if the argument is our anim. Use very cautiously
"assurepos" - for important anims, makes sure the position isn't offset by sweps. Use locktoply it's better
"locktoply" - for when assurepos isn't enough.


Legs
"model" - path to model
"speed" - playback speed 
"forwardboost" - forward offset
"upboost" - vertical offset (in actual hammer units)

]]

VManip:RegisterAnim("use",
{
["model"]="c_vmanipinteract.mdl",
["lerp_peak"]=0.4,
["lerp_speed_in"]=1,
["lerp_speed_out"]=0.8,
["lerp_curve"]=2.5,
["speed"]=1,
["startcycle"]=0.1,
["sounds"]={},
["loop"]=false
}
)


VManip:RegisterAnim("vault",
{
["model"]="c_vmanipvault.mdl",
["lerp_peak"]=0.4,
["lerp_speed_in"]=1,
["lerp_speed_out"]=0.5,
["lerp_curve"]=1,
["speed"]=1
}
)

VManip:RegisterAnim("handslide",
{
["model"]="c_vmanipvault.mdl",
["lerp_peak"]=0.2,
["lerp_speed_in"]=1,
["lerp_speed_out"]=0.8,
["lerp_curve"]=2,
["speed"]=1.5,
["holdtime"]=0.25,
}
)

VManip:RegisterAnim("adrenalinestim",
{
["model"]="old/c_vmanip.mdl",
["lerp_peak"]=1.1,
["lerp_speed_in"]=1,
["speed"]=0.7,
["sounds"]={},
["loop"]=false
}
)

VManip:RegisterAnim("thrownade",
{
["model"]="c_vmanipgrenade.mdl",
["lerp_peak"]=0.85,
["lerp_speed_in"]=1.2,
["lerp_speed_out"]=1.2,
["lerp_curve"]=1,
["speed"]=1,
["holdtime"]=0.4,
}
)

--###################################

VMLegs:RegisterAnim("test", --lmao, im not recompiling to change THAT shit
{
["model"]="c_vmaniplegs.mdl",
["speed"]=1.5,
["forwardboost"]=4,
["upwardboost"]=0
})