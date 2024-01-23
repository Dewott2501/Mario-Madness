
-- local xx = 360;
-- local yy = 450;
-- local yyh = 350;
-- local xx2 = 1120;
-- local yy2 = 550;

-- local xx3 = 770;
-- local yy3 = 350;

-- local ofs = 30;
-- local ofs2 = 120;
-- local duet = false;
-- local waittt = true;
-- local followchars = true;
-- local del = 0;
-- local del2 = 0;


-- function onUpdate()
-- 	if del > 0 then
-- 		del = del - 1
-- 	end
-- 	if del2 > 0 then
-- 		del2 = del2 - 1
-- 	end
--     if followchars == true then
--         if mustHitSection == false then
--             if getProperty('dad.animation.curAnim.name') == 'singLEFT' then
--                 triggerEvent('Camera Follow Pos',xx-ofs,yy)
--             end
--             if getProperty('dad.animation.curAnim.name') == 'singRIGHT' then
--                 triggerEvent('Camera Follow Pos',xx+ofs,yy)
--             end
--             if getProperty('dad.animation.curAnim.name') == 'singUP' then
--                 triggerEvent('Camera Follow Pos',xx,yy-ofs)
--             end
--             if getProperty('dad.animation.curAnim.name') == 'singDOWN' then
--                 triggerEvent('Camera Follow Pos',xx,yy+ofs)
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
--     else
--         triggerEvent('Camera Follow Pos','','')
--     end

--     if duet == true then
--         if getProperty('boyfriend.animation.curAnim.name') == 'singLEFT-miss' then
--             triggerEvent('Camera Follow Pos',xx3-ofs,yy3)
--         end
--         if getProperty('boyfriend.animation.curAnim.name') == 'singRIGHT-miss' then
--             triggerEvent('Camera Follow Pos',xx3+ofs,yy3)
--         end
--         if getProperty('boyfriend.animation.curAnim.name') == 'singUP-miss' then
--             triggerEvent('Camera Follow Pos',xx3,yy3-ofs)
--         end
--         if getProperty('boyfriend.animation.curAnim.name') == 'singDOWN-miss' then
--             triggerEvent('Camera Follow Pos',xx3,yy3+ofs)
--         end

--         if getProperty('boyfriend.animation.curAnim.name') == 'singLEFT' then
--             triggerEvent('Camera Follow Pos',xx3-ofs,yy3)
--         end
--         if getProperty('boyfriend.animation.curAnim.name') == 'singRIGHT' then
--             triggerEvent('Camera Follow Pos',xx3+ofs,yy3)
--         end
--         if getProperty('boyfriend.animation.curAnim.name') == 'singUP' then
--             triggerEvent('Camera Follow Pos',xx3,yy3-ofs)
--         end
--         if getProperty('boyfriend.animation.curAnim.name') == 'singDOWN' then
--             triggerEvent('Camera Follow Pos',xx3,yy3+ofs)
--         end
--         if getProperty('boyfriend.animation.curAnim.name') == 'idle' then
--             triggerEvent('Camera Follow Pos',xx3,yy3)
--         end
--     end

--     if duet == false and waittt == false then
--     if mustHitSection == false then
--         setProperty("defaultCamZoom", "0.3")
--         else
--         setProperty("defaultCamZoom", "0.5")
--     end
--     end
    
-- end

-- function onBeatHit()

--     if curBeat == 64 then
--         duet = true
--         followchars = false
--     end

--     if curBeat >= 64 and curBeat <= 128 then
--         triggerEvent('Add Camera Zoom','0.01','')
--     end

--     if curBeat >= 168 and curBeat <= 196 then
--         triggerEvent('Add Camera Zoom','0.01','')
--     end

--     if curBeat >= 200 and curBeat <= 231 then
--         triggerEvent('Add Camera Zoom','0.01','')
--     end

--     if curBeat >= 264 and curBeat <= 295 then
--         triggerEvent('Add Camera Zoom','0.01','')
--     end

--     if curBeat >= 360 and curBeat <= 424 then
--         triggerEvent('Add Camera Zoom','0.01','')
--     end

--     if curBeat >= 492 and curBeat == 495 then
--         triggerEvent('Add Camera Zoom','0.02','')
--     end

--     if curBeat >= 508 and curBeat <= 568 then
--         triggerEvent('Screen Shake','0.345, 0.005','0.345, 0.002')
--     end

--     if curBeat >= 509 and curBeat <= 560 then
--         triggerEvent('Add Camera Zoom','0.02','')
--     end

--     if curBeat == 120 then
--         duet = false
--         followchars = true
--     end

--     if curBeat == 132 then
--         waittt = false
--         followchars = true
--         xx = 80;
--         yy = -150;
--     end

--     if curBeat == 524 then
--         waittt = true
--         doTweenZoom('omgqueepicopapus', 'camGame', 0.7, 1.34, 'quadIn')
--     end

--     if curBeat == 528 then
--         xx3 = 470;
--         yy3 = 50;
--         duet = true
--         followchars = false
        
--     end

--     if curBeat % 2 == 0 then
--     if curBeat >= 136 and curBeat <= 167 then
--         triggerEvent('Add Camera Zoom','0.04','')
--         triggerEvent('Screen Shake','0.345, 0.005','0.345, 0.002')
--     end

--     if curBeat >= 232 and curBeat <= 263 then
--         triggerEvent('Add Camera Zoom','0.02','')
--         triggerEvent('Screen Shake','0.345, 0.005','0.345, 0.002')
--     end

--     if curBeat >= 296 and curBeat <= 328 then
--         triggerEvent('Add Camera Zoom','0.02','')
--         triggerEvent('Screen Shake','0.345, 0.005','0.345, 0.002')
--     end

--     if curBeat == 488 or curBeat == 489 then
--         triggerEvent('Add Camera Zoom','0.02','')
--         triggerEvent('Screen Shake','0.345, 0.005','0.345, 0.002')
--     end
    
--     end

--     if curBeat % 4 == 0 then
--         if curBeat >= 496 and curBeat <= 508 then
--             triggerEvent('Add Camera Zoom','0.03','')
--         end
--     end
-- end