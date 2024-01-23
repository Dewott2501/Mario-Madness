
-- local xx = 220;
-- local yy = -380;
-- local yyh = 350;

-- local xx2 = 950;
-- local yy2 = 550;

-- local xx3 = 670;
-- local yy3 = 450;

-- local ofs = 45;
-- local ofs2 = 120;
-- local duet = false;
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
--             if getProperty('dad.animation.curAnim.name') == 'atras' then
--                 triggerEvent('Camera Follow Pos',xx,yy)
--             end
--             if getProperty('dad.animation.curAnim.name') == 'jumpscare' then
--                 triggerEvent('Camera Follow Pos',xx-ofs,yyh)
--             end
--             if getProperty('dad.animation.curAnim.name') == 'boton' then
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

--         if duet == true then
--             if getProperty('boyfriend.animation.curAnim.name') == 'singLEFT' then
--                 triggerEvent('Camera Follow Pos',xx3-ofs,yy3)
--             end
--             if getProperty('boyfriend.animation.curAnim.name') == 'singRIGHT' then
--                 triggerEvent('Camera Follow Pos',xx3+ofs,yy3)
--             end
--             if getProperty('boyfriend.animation.curAnim.name') == 'singUP' then
--                 triggerEvent('Camera Follow Pos',xx3,yy3-ofs)
--             end
--             if getProperty('boyfriend.animation.curAnim.name') == 'singDOWN' then
--                 triggerEvent('Camera Follow Pos',xx3,yy3+ofs)
--             end
--         if getProperty('boyfriend.animation.curAnim.name') == 'idle' then
--                 triggerEvent('Camera Follow Pos',xx3,yy3)
--             end
--         end
        
--     end
    
-- end

-- function onBeatHit()

--     if curBeat == 4 then
--         followchars = false
--         yy = 430
--         xx = 220
--     end

--     if curBeat == 32 then
--         followchars = true
--     end

--     if curBeat >= 64 and curBeat <= 128 then
--         triggerEvent('Add Camera Zoom','0.005','')
--     end

--     if curBeat == 128 then
--         followchars = false
--         duet = true
--     end

--     if curBeat == 144 then
--         followchars = true
--         duet = false
--     end

--     if curBeat >= 176 and curBeat <= 240 then
--         triggerEvent('Add Camera Zoom','0.02','')
--     end

--     if curBeat >= 225 and curBeat <= 240 then
--         setProperty("defaultCamZoom", getProperty("defaultCamZoom") + 0.03)
--     end

--     if curBeat == 224 then
--         followchars = false
--         duet = true
--     end

--     if curBeat == 244 then
--         followchars = true
--         duet = false
--     end

--     if curBeat >= 272 and curBeat <= 304 then
--          triggerEvent('Add Camera Zoom','0.04','')
--     end

--     if curBeat == 308 then
--         followchars = false
--     end
-- end

-- function onStepHit()
--     if curBeat >= 900 and curBeat <= 960 then
--         setProperty("defaultCamZoom", getProperty("defaultCamZoom") + 0.0075)
--     end
-- end