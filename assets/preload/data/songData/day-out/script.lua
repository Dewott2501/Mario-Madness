-- local xx = 620;
-- local yy = 450;
-- local yyh = 350;

-- local xx2 = 320;
-- local yy2 = 450;

-- local yR = 0;
-- local xR = 0;

-- local xx3 = 920;
-- local yy3 = 450;

-- local xxC = 0;
-- local yyC = 0;

-- local ofs = 30;
-- local ofs2 = 5;
-- local followchars = true;
-- local lsing = false;
-- local cutscene = false;
-- local zoomcam = false;
-- local extrazoom = false;
-- local del = 0;
-- local del2 = 0;
-- local syncqliao = 0;

-- function onSongStart()
--     noteTweenX("NoteMove1", 4, 92, 0.6, cubeInOut)
--     noteTweenX("NoteMove2", 5, 204, 0.6, cubeInOut)
--     noteTweenX("NoteMove3", 6, 316, 0.6, cubeInOut)
--     noteTweenX("NoteMove4", 7, 428, 0.6, cubeInOut)

--     noteTweenX("NoteMove5", 0, 732, 0.6, cubeInOut)
--     noteTweenX("NoteMove6", 1, 844, 0.6, cubeInOut)
--     noteTweenX("NoteMove7", 2, 956, 0.6, cubeInOut)
--     noteTweenX("NoteMove8", 3, 1068, 0.6, cubeInOut)

--     setProperty('gfspeak.x', -390)
--     setProperty('gfspeak.y', 640)

--     setProperty('gfwalk.x', -390)
--     setProperty('gfwalk.y', 280)
-- end

-- function onUpdate()
--     --setProperty("defaultCamZoom", "0.4")
-- 	if del > 0 then
-- 		del = del - 1
-- 	end
-- 	if del2 > 0 then
-- 		del2 = del2 - 1
-- 	end
--     if followchars == true and lsing == false then
--         if mustHitSection == false then
--             if getProperty('dad.animation.curAnim.name') == 'singLEFT' then
--                 triggerEvent('Camera Follow Pos',xx-ofs,yy)
--                 lsing = false
--             end
--             if getProperty('dad.animation.curAnim.name') == 'singRIGHT' then
--                 triggerEvent('Camera Follow Pos',xx+ofs,yy)
--                 lsing = false
--             end
--             if getProperty('dad.animation.curAnim.name') == 'singUP' then
--                 triggerEvent('Camera Follow Pos',xx,yy-ofs)
--                 lsing = false
--             end
--             if getProperty('dad.animation.curAnim.name') == 'singDOWN' then
--                 triggerEvent('Camera Follow Pos',xx,yy+ofs)
--                 lsing = false
--             end
--             if getProperty('dad.animation.curAnim.name') == 'Hey' then
--                 triggerEvent('Camera Follow Pos',xx-ofs,yyh)
--             end
--             if getProperty('dad.animation.curAnim.name') == 'singRIGHT-alt' then
--                 triggerEvent('Camera Follow Pos',xx+ofs,yy)
--             end
--             if getProperty('dad.animation.curAnim.name') == 'singUP-alt' then
--                 triggerEvent('Camera Follow Pos',xx,yy-ofs)
--             end
--             if getProperty('dad.animation.curAnim.name') == 'singDOWN-alt' then
--                 triggerEvent('Camera Follow Pos',xx,yy+ofs)
--             end
--             if getProperty('dad.animation.curAnim.name') == 'idle-alt' then
--                 triggerEvent('Camera Follow Pos',xx,yy)
--             end
--             if getProperty('dad.animation.curAnim.name') == 'idle' then
--                 triggerEvent('Camera Follow Pos',xx,yy)
--             end
--         else

--             if getProperty('boyfriend.animation.curAnim.name') == 'singLEFT' then
--                 triggerEvent('Camera Follow Pos',xx2-ofs,yy2)
--             end
--             if getProperty('boyfriend.animation.curAnim.name') == 'singRIGHT' then
--                 triggerEvent('Camera Follow Pos',xx2+ofs,yy2)
--             end
--             if getProperty('boyfriend.animation.curAnim.name') == 'singUP' then
--                 triggerEvent('Camera Follow Pos',xx2,yy2-ofs)
--             end
--             if getProperty('boyfriend.animation.curAnim.name') == 'singDOWN' then
--                 triggerEvent('Camera Follow Pos',xx2,yy2+ofs)
--             end
-- 	    if getProperty('boyfriend.animation.curAnim.name') == 'idle' then
--                 triggerEvent('Camera Follow Pos',xx2,yy2)
--             end
--         end
--     end

--     if lsing == true then
--         if getProperty('gf.animation.curAnim.name') == 'singLEFT' then
--             triggerEvent('Camera Follow Pos',xx3-ofs,yy3)
--         end
--         if getProperty('gf.animation.curAnim.name') == 'singRIGHT' then
--             triggerEvent('Camera Follow Pos',xx3+ofs,yy3)
--         end
--         if getProperty('gf.animation.curAnim.name') == 'singUP' then
--             triggerEvent('Camera Follow Pos',xx3,yy3-ofs)
--         end
--         if getProperty('gf.animation.curAnim.name') == 'singDOWN' then
--             triggerEvent('Camera Follow Pos',xx3,yy3+ofs)
--         end
--         if getProperty('gf.animation.curAnim.name') == 'idle' then
--             triggerEvent('Camera Follow Pos',xx3,yy3)
--         end
--     end

--     if cutscene == true then
--         triggerEvent('Camera Follow Pos',xxC + xR ,yyC + yR)
--     end
-- end

-- function onBeatHit()

--     if curBeat == 172 or curBeat == 188 then
--         lsing = false
--     end

--     if curBeat == 13 then
--         followchars = false
--         cutscene = true
--         xxC = 1050
--         yyC = 450
--         triggerEvent('Camera Follow Pos','1050','450')
--         triggerEvent('Cambiar Zoom Default','1.0')
--     end
    
--     if curBeat == 26 then
--         cutscene = false
--     end

--     if curBeat == 32 then
--         followchars = true
--         triggerEvent('Camera Follow Pos','','')
--         setProperty("defaultCamZoom", "0.75")
--     end

--     if curBeat == 188 then
--         followchars = false
--         triggerEvent('Camera Follow Pos','320','450')
--     end
--     if curBeat == 196 then
--         followchars = true
--         triggerEvent('Camera Follow Pos','','')
--     end

--     if curBeat == 329 then
--         cutscene = true
--         xxC = 320
--         yyC = 450
--         setProperty("defaultCamZoom", "0.75")
--     end

--     if curBeat == 339 then
--         cutscene = false
--         followchars = false
--         lsing = false
--     end
-- end

-- function onStepHit()

--     if curStep %2 == 0 then
--     if cutscene == true then
--         xR = math.random(-5,5)
--         yR = math.random(-5,5)
--     end
--     end

--     if curStep % 2 == 0 and curStep % 4 ~= 0 and zoomcam == true then
--         triggerEvent('Add Camera Zoom','0.015','')
--         syncqliao = syncqliao + 1

--         if syncqliao % 3 == 0 and syncqliao > 1 then
--             extrazoom = true
--             syncqliao = -1
--         end
--     end

--     if extrazoom == true and curStep % 2 ~= 0 then
--     extrazoom = false
--     triggerEvent('Add Camera Zoom','0.015','')
--     end


--     if curStep >= 144 and curStep <= 400 then
--         zoomcam = true
--     elseif curStep >= 528 and curStep <= 656 then
--         zoomcam = true
--     elseif curStep >= 784 and curStep <= 1040 then
--         zoomcam = true
--     else
--         zoomcam = false
--     end
-- end

-- function goodNoteHit(id, noteData, noteType, isSustainNote)


-- 	if noteType == 'GF Sing' then
--        lsing = true
--        noteTweenX("NoteMove1", 4, 732, 0.6, cubeInOut)
--        noteTweenX("NoteMove2", 5, 844, 0.6, cubeInOut)
--        noteTweenX("NoteMove3", 6, 956, 0.6, cubeInOut)
--        noteTweenX("NoteMove4", 7, 1068, 0.6, cubeInOut)
--        noteTweenAlpha("NoteMove5", 0, 0, 0.2, cubeInOut)
--        noteTweenAlpha("NoteMove6", 1, 0, 0.2, cubeInOut)
--        noteTweenAlpha("NoteMove7", 2, 0, 0.2, cubeInOut)
--        noteTweenAlpha("NoteMove8", 3, 0, 0.2, cubeInOut)
--        setPropertyFromClass('GameOverSubstate', 'characterName', 'luigi-ldoDEATH')
--     else
--        lsing = false
--        noteTweenX("NoteMove1", 4, 92, 0.6, cubeInOut)
--        noteTweenX("NoteMove2", 5, 204, 0.6, cubeInOut)
--        noteTweenX("NoteMove3", 6, 316, 0.6, cubeInOut)
--        noteTweenX("NoteMove4", 7, 428, 0.6, cubeInOut)
--        setPropertyFromClass('GameOverSubstate', 'characterName', 'bf-ldo')
-- 	end

-- end