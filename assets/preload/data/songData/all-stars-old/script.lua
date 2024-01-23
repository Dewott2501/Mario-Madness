-- local xx = -420
-- local yy = 150
-- local yyh = 350;

-- local xx2 = 220;
-- local yy2 = 450;

-- local xx3 = 370;
-- local yy3 = 450;

-- local xx4 = 770;
-- local yy4 = 350;

-- local zoombf = 0.6;
-- local zoomdad = 0.35;

-- local ofs = 30;
-- local ofs2 = 120;
-- local followchars = true;
-- local gfsing = false;
-- local wario = false;
-- local yoshi = false;
-- local allbuds = false;
-- local zoomchars = true;

-- function onUpdate()
--     if followchars == true then
--         if mustHitSection == false then
--             if wario == false and yoshi == false then
--                 if getProperty('dad.animation.curAnim.name') == 'singLEFT' then
--                     triggerEvent('Camera Follow Pos',xx-ofs,yy)
--                 end
--                 if getProperty('dad.animation.curAnim.name') == 'singRIGHT' then
--                     triggerEvent('Camera Follow Pos',xx+ofs,yy)
--                 end
--                 if getProperty('dad.animation.curAnim.name') == 'singUP' then
--                     triggerEvent('Camera Follow Pos',xx,yy-ofs)
--                 end
--                 if getProperty('dad.animation.curAnim.name') == 'singDOWN' then
--                     triggerEvent('Camera Follow Pos',xx,yy+ofs)
--                 end
--                 if getProperty('dad.animation.curAnim.name') == 'Hey' then
--                     triggerEvent('Camera Follow Pos',xx-ofs,yyh)
--                 end
--                 if getProperty('dad.animation.curAnim.name') == 'singRIGHT-alt' then
--                     triggerEvent('Camera Follow Pos',xx+ofs,yy)
--                 end
--                 if getProperty('dad.animation.curAnim.name') == 'singUP-alt' then
--                     triggerEvent('Camera Follow Pos',xx,yy-ofs)
--                 end
--                 if getProperty('dad.animation.curAnim.name') == 'singDOWN-alt' then
--                     triggerEvent('Camera Follow Pos',xx,yy+ofs)
--                 end
--                 if getProperty('dad.animation.curAnim.name') == 'idle-alt' then
--                     triggerEvent('Camera Follow Pos',xx,yy)
--                 end
--                 if getProperty('dad.animation.curAnim.name') == 'idle' then
--                     triggerEvent('Camera Follow Pos',xx,yy)
--                 end

--                 --WARIO
--             else

--                 if allbuds == false then
--                     if getProperty('gf.animation.curAnim.name') == 'singLEFT' then
--                         triggerEvent('Camera Follow Pos',xx3-ofs,yy3)
--                     end
--                     if getProperty('gf.animation.curAnim.name') == 'singRIGHT' then
--                         triggerEvent('Camera Follow Pos',xx3+ofs,yy3)
--                     end
--                     if getProperty('gf.animation.curAnim.name') == 'singUP' then
--                         triggerEvent('Camera Follow Pos',xx3,yy3-ofs)
--                     end
--                     if getProperty('gf.animation.curAnim.name') == 'singDOWN' then
--                         triggerEvent('Camera Follow Pos',xx3,yy3+ofs)
--                     end
--                 end

--                 --YOSHI

--                 if getProperty('funnylayer0.animation.curAnim.name') == 'singLEFT' then
--                     triggerEvent('Camera Follow Pos',xx4-ofs,yy4)
--                 end
--                 if getProperty('funnylayer0.animation.curAnim.name') == 'singRIGHT' then
--                     triggerEvent('Camera Follow Pos',xx4+ofs,yy4)
--                 end
--                 if getProperty('funnylayer0.animation.curAnim.name') == 'singUP' then
--                     triggerEvent('Camera Follow Pos',xx4,yy4-ofs)
--                 end
--                 if getProperty('funnylayer0.animation.curAnim.name') == 'singDOWN' then
--                     triggerEvent('Camera Follow Pos',xx4,yy4+ofs)
--                 end
--             end
--         else
--             if gfsing == true then
--                 if getProperty('gf.animation.curAnim.name') == 'singLEFT' then
--                     triggerEvent('Camera Follow Pos',xx3-ofs,yy3)
--                 end
--                 if getProperty('gf.animation.curAnim.name') == 'singRIGHT' then
--                     triggerEvent('Camera Follow Pos',xx3+ofs,yy3)
--                 end
--                 if getProperty('gf.animation.curAnim.name') == 'singUP' then
--                     triggerEvent('Camera Follow Pos',xx3,yy3-ofs)
--                 end
--                 if getProperty('gf.animation.curAnim.name') == 'singDOWN' then
--                     triggerEvent('Camera Follow Pos',xx3,yy3+ofs)
--                 end
--                 if getProperty('gf.animation.curAnim.name') == 'idle' then
--                     triggerEvent('Camera Follow Pos',xx3,yy3)
--                 end
--             else
            
--                 if getProperty('boyfriend.animation.curAnim.name') == 'singLEFT' then
--                     triggerEvent('Camera Follow Pos',xx2-ofs,yy2)
--                 end
--                 if getProperty('boyfriend.animation.curAnim.name') == 'singRIGHT' then
--                     triggerEvent('Camera Follow Pos',xx2+ofs,yy2)
--                 end
--                 if getProperty('boyfriend.animation.curAnim.name') == 'singUP' then
--                     triggerEvent('Camera Follow Pos',xx2,yy2-ofs)
--                 end
--                 if getProperty('boyfriend.animation.curAnim.name') == 'singDOWN' then
--                     triggerEvent('Camera Follow Pos',xx2,yy2+ofs)
--                 end
--                 if getProperty('boyfriend.animation.curAnim.name') == 'idle' then
--                     triggerEvent('Camera Follow Pos',xx2,yy2)
--                 end
--             end
--         end
--     else
--         triggerEvent('Camera Follow Pos','','')
--     end

--     if zoomchars == true then
--         if mustHitSection == false then
--             setProperty("defaultCamZoom", zoomdad)
--         else
--             setProperty("defaultCamZoom", zoombf)
--         end
--     end   
-- end

-- function onBeatHit()

--     --if curBeat == 1 then
--     --    zoomchars = true
--     --    followchars = true
--     --    gfsing = false
--     --    zoombf = 0.8
--     --    zoomdad = 0.6
--     --    xx = 520;
--     --    yy = 250;
--     --    xx2 = 520;
--     --end

--     if curBeat == 264 then
--         zoomchars = false
--         gfsing = false
--         zoombf = 0.8
--         zoomdad = 0.6
--         xx2 = 520;
--         xx = 480;
--         yy = -120;
--     end

--     if curBeat == 268 then
--         xx = 520;
--         yy = 250;
--         zoomchars = true
--         followchars = true
--     end

--     if curBeat == 588 then
--         xx = -400;
--         yy = 300;
--         xx2 = 350;
--         yy2 = 475;
--         zoombf = 0.7
--         zoomdad = 0.6
--         zoomchars = true
--     end

--     if curBeat >= 300 and curBeat <= 331 then
--         triggerEvent('Add Camera Zoom','','')
--     end

--     if curBeat >= 364 and curBeat <= 395 then
--         triggerEvent('Add Camera Zoom','0.016','')
--     end

--     if curBeat >= 426 and curBeat <= 472 then
--         triggerEvent('Add Camera Zoom','0.016','')
--     end

--     if curBeat >= 476 and curBeat <= 491 then
--         triggerEvent('Add Camera Zoom','0.016','')
--     end

--     if curBeat >= 508 and curBeat <= 523 then
--         triggerEvent('Add Camera Zoom','0.016','')
--     end

--     if curBeat >= 540 and curBeat <= 556 then
--         triggerEvent('Add Camera Zoom','0.016','')
--     end

--     if curBeat % 4 == 0 then
--         if curBeat >= 396 and curBeat <= 424 then
--             triggerEvent('Add Camera Zoom','0.032','')
--         end

--         if curBeat >= 460 and curBeat <= 472 then
--             triggerEvent('Add Camera Zoom','0.032','')
--         end

--         if curBeat >= 492 and curBeat <= 507 then
--             triggerEvent('Add Camera Zoom','0.032','')
--         end

--         if curBeat >= 524 and curBeat <= 539 then
--             triggerEvent('Add Camera Zoom','0.052','0.06')
--         end
--     end

--     if curBeat % 2 == 0 then

--         if curBeat >= 268 and curBeat <= 299 then
--             triggerEvent('Add Camera Zoom','0.024','')
--         end

--         if curBeat >= 396 and curBeat <= 327 then
--             triggerEvent('Add Camera Zoom','0.024','')
--         end
--     end
-- end

-- function goodNoteHit(id, noteData, noteType, isSustainNote)
-- 	if noteType == 'GF Sing' then
--        gfsing = true
--     else
--        gfsing = false
-- 	end
-- end

-- function opponentNoteHit(id, noteData, noteType, isSustainNote)
-- 	if noteType == 'GF Sing' then
--        wario = true
--     else
--        wario = false
-- 	end

--     if noteType == 'Yoshi Note' then
--        yoshi = true
--     else
--        yoshi = false
--     end

--     if noteType == 'AS Bud Note' then
--        allbuds = true
--     else
--        allbuds = false
--     end
-- end

-- xx/yy is always for player characters
--xx2/yy2 is always for opponent
--instead of having a if then festival we're just gonna have the values get set whenever certain notes are hit
local act = 1

local xx = 220
local yy = 450

local xx2 = -420
local yy2 = 150

local ofs = 30
local ofs2 = 60

local zoom1 = 0.6
local zoom2 = 0.35

local followchars = true
local zoomchars = true

local singer1 = 'boyfriend'
local singer2 = 'dad'

function onUpdate()
    if followchars == true then
        if mustHitSection == true then
            if getProperty(singer1 .. '.animation.curAnim.name') == 'idle' or getProperty(singer1 .. '.animation.curAnim.name') == 'idle-alt' then
                triggerEvent('Camera Follow Pos',xx,yy)
            end
            if getProperty(singer1 .. '.animation.curAnim.name') == 'singLEFT' or getProperty(singer1 .. '.animation.curAnim.name') == 'singLEFT-alt' then
                triggerEvent('Camera Follow Pos',xx - ofs,yy)
            end
            if getProperty(singer1 .. '.animation.curAnim.name') == 'singRIGHT' or getProperty(singer1 .. '.animation.curAnim.name') == 'singRIGHT-alt' then
                triggerEvent('Camera Follow Pos',xx + ofs,yy)
            end
            if getProperty(singer1 .. '.animation.curAnim.name') == 'singUP' or getProperty(singer1 .. '.animation.curAnim.name') == 'singUP-alt' then
                triggerEvent('Camera Follow Pos',xx,yy - ofs)
            end
            if getProperty(singer1 .. '.animation.curAnim.name') == 'singDOWN' or getProperty(singer1 .. '.animation.curAnim.name') == 'singDOWN-alt' then
                triggerEvent('Camera Follow Pos',xx,yy + ofs)
            end
            
            if zoomchars == true then
                setProperty('defaultCamZoom', zoom1)
            end
        else
            if getProperty(singer2 .. '.animation.curAnim.name') == 'idle' or getProperty(singer2 .. '.animation.curAnim.name') == 'idle-alt' then
                triggerEvent('Camera Follow Pos',xx2,yy2)
            end
            if getProperty(singer2 .. '.animation.curAnim.name') == 'singLEFT' or getProperty(singer2 .. '.animation.curAnim.name') == 'singLEFT-alt' then
                triggerEvent('Camera Follow Pos',xx2 - ofs2,yy2)
            end
            if getProperty(singer2 .. '.animation.curAnim.name') == 'singRIGHT' or getProperty(singer2 .. '.animation.curAnim.name') == 'singRIGHT-alt' then
                triggerEvent('Camera Follow Pos',xx2 + ofs2,yy2)
            end
            if getProperty(singer2 .. '.animation.curAnim.name') == 'singUP' or getProperty(singer2 .. '.animation.curAnim.name') == 'singUP-alt' then
                triggerEvent('Camera Follow Pos',xx2,yy2 - ofs2)
            end
            if getProperty(singer2 .. '.animation.curAnim.name') == 'singDOWN' or getProperty(singer2 .. '.animation.curAnim.name') == 'singDOWN-alt' then
                triggerEvent('Camera Follow Pos',xx2,yy2 + ofs2)
            end

            if getProperty(singer2 .. '.animation.curAnim.name') == 'exit1' or getProperty(singer2 .. '.animation.curAnim.name') == 'exit2 ' then
                triggerEvent('Camera Follow Pos',xx2,yy2 - (ofs2 * 2))
            end
            
            if zoomchars == true then
                setProperty('defaultCamZoom', zoom2)
            end
        end
    else
        --triggerEvent('Camera Follow Pos','','')
    end
end

function onBeatHit()
    if curBeat == 268 then
        act = 2
    end
    if curBeat == 396 then
        act = 2.5
    end
    if curBeat == 264 then
        zoom2 = 2
        xx2 = 480
        yy2 = -180
    end

    if curBeat == 328 then
        followchars = false
        zoomchars = false
        doTweenAlpha('tag0', 'camHUD', 0.7, 0.5, 'quadInOut')
        doTweenX('tag1', 'camFollowPos', xx2, 1.6, 'quadIn')
        doTweenY('tag2', 'camFollowPos', yy2 - 300, 1.6, 'quadIn')
        doTweenX('tag3', 'camFollow', xx2, 1.6, 'quadIn')
        doTweenY('tag4', 'camFollow', yy2 - 300, 1.6, 'quadIn')
    end

    if curBeat == 332 then
        followchars = true
        zoomchars =   true
        doTweenAlpha('tag5', 'camHUD', 1, 0.5, 'quadOut')
    end

    if curBeat == 580 then
        act = 3
        xx2 = -800
        yy2 = 300
        zoom2 = 0.7
        ofs2 = 20
        ofs = 20
    end

    if curBeat == 586 then
        followchars = false
        zoomchars = false
        doTweenX('tag1', 'camFollowPos', xx2, 5, 'quadInOut')
        doTweenY('tag2', 'camFollowPos', yy2, 5, 'quadInOut')
        doTweenX('tag3', 'camFollow', xx2, 5, 'quadInOut')
        doTweenY('tag4', 'camFollow', yy2, 5, 'quadInOut')
        doTweenZoom('tag5', 'camGame', zoom2, 5, 'quadInOut')
    end

    if curBeat == 604 then
        followchars = true
        zoomchars = true
        xx2 = -400
        yy2 = 300
        zoom2 = 0.6
    end

    if curBeat == 668 then
        ofs2 = 80
        ofs = 60
    end

    if curBeat == 844 then
        act = 3.5
        zoomchars = false
    end

    if curBeat >= 300 and curBeat <= 331 then
         triggerEvent('Add Camera Zoom','','')
     end
     if curBeat >= 364 and curBeat <= 395 then
         triggerEvent('Add Camera Zoom','0.016','')
     end
     if curBeat >= 426 and curBeat <= 472 then
         triggerEvent('Add Camera Zoom','0.016','')
     end
     if curBeat >= 476 and curBeat <= 491 then
         triggerEvent('Add Camera Zoom','0.016','')
     end
     if curBeat >= 508 and curBeat <= 523 then
         triggerEvent('Add Camera Zoom','0.016','')
     end
     if curBeat >= 540 and curBeat <= 556 then
         triggerEvent('Add Camera Zoom','0.016','')
     end
     if curBeat % 4 == 0 then
         if curBeat >= 396 and curBeat <= 424 then
             triggerEvent('Add Camera Zoom','0.032','')
         end
         if curBeat >= 460 and curBeat <= 472 then
             triggerEvent('Add Camera Zoom','0.032','')
         end
         if curBeat >= 492 and curBeat <= 507 then
             triggerEvent('Add Camera Zoom','0.032','')
         end
         if curBeat >= 524 and curBeat <= 539 then
             triggerEvent('Add Camera Zoom','0.052','0.06')
         end
     end
     if curBeat % 2 == 0 then
         if curBeat >= 268 and curBeat <= 299 then
             triggerEvent('Add Camera Zoom','0.024','')
         end
         if curBeat >= 396 and curBeat <= 327 then
             triggerEvent('Add Camera Zoom','0.024','')
         end
     end
end

function goodNoteHit(id, noteData, noteType, isSustainNote)
    if noteType == '' or noteType == 'Alt Animation' or noteType == 'GF Duet' then
        singer1 = 'boyfriend'
        xx = 220
        yy = 450
        if act == 2 or act == 2.5 then
            xx = 520
            yy = 450
            zoom1 = 0.8
        end
        if act == 3 then
            xx = 350
            yy = 475
            zoom1 = 0.7
        end
        if act == 3.5 then
            xx = -150
            yy = 400
        end
    end
    if noteType == 'GF Sing' then
        singer1 = 'gf'
        xx = 370
        yy = 450
    end
end

function opponentNoteHit(id, noteData, noteType, isSustainNote)
    if noteType == '' then
        singer2 = 'dad'
        xx2 = -420
        yy2 = 150
        zoom2 = 0.35 
        if act == 2 then
            xx2 = 520
            yy2 = 250
            zoom2 = 0.6
            ofs2 = 80
        end
        if act == 2.5 then
            xx2 = 260
            yy2 = 450
            zoom2 = 0.7
            ofs2 = 60
        end
        if act == 3 then
            xx2 = -400
            yy2 = 300
            zoom2 = 0.6
        end
        if act == 3.5 then
            xx2 = -150
            yy2 = 400
            ofs2 = 30
        end
    end
    if noteType == 'GF Sing' then
        singer2 = 'gf'
        xx2 = 520
        yy2 = 350
        zoom2 = 0.7
    end
    if noteType == 'Yoshi Note' then
        singer2 = 'funnylayer0'
        xx2 = 780
        yy2 = 450
        zoom2 = 0.7
    end
    if noteType == 'AS Bud Note' then
        singer2 = 'dad'
        xx2 = 520
        yy2 = 350
        zoom2 = 0.6
    end
end