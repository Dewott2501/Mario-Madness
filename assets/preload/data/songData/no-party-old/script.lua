local change = true
local newx = 700
local newBx = -150
local holaPIBE = 0
local holaPIBE2 = 0
local mequieromatar = 0
local newY = 0

function onUpdate()

    if(change) then
    noteTweenX('lol1', 0, newx, 0.001)
    noteTweenX('lol2', 1, newx + 112, 0.001)
    noteTweenX('lol3', 2, newx + 224, 0.001)
    noteTweenX('lol4', 3, newx + 336, 0.001)

    noteTweenX('lolB1', 4, newBx, 0.001)
    noteTweenX('lolB2', 5, newBx + 112, 0.001)
    noteTweenX('lolB3', 6, newBx + 224, 0.001)
    noteTweenX('lolB4', 7, newBx + 336, 0.001)
    change = false

    end
end