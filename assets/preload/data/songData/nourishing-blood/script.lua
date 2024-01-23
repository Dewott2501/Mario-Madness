
local xx = 120;
local yy = 650;
local yyh = 350;
local xx2 = 1120;
local yy2 = 750;
local ofs = 30;
local ofs2 = 270;
local followchars = true;
local del = 0;
local del2 = 0;
local hide = false;


function onUpdate()
    if followchars == false then
        triggerEvent('Camera Follow Pos','800','-1000')
    end
end


function onBeatHit()     
    if curBeat >= 4 and curBeat <= 228 then
        triggerEvent('Add Camera Zoom','0.01','')
    end

    if curBeat >= 244 and curBeat <= 359 then
        triggerEvent('Add Camera Zoom','0.01','')
    end

    if curBeat >= 392 and curBeat <= 404 then
        ofs2 = 170
        triggerEvent('Add Camera Zoom','0.01','')
    end
end