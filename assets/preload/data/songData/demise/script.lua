
-- local xx = 1220;
-- local yy = 0;
-- local yyh = 350;
-- local xx2 = 380;
-- local yy2 = 350;
-- local ofs = 60;
-- local ofs2 = 120;
-- local followchars = true;
-- local del = 0;
-- local del2 = 0;
-- local lol = 0;
-- local dadzoom = 0.4;
-- local bfzoom = 0.6;

-- function onBeatHit()

--     if curBeat >= 64 and curBeat <= 76 then
-- 		triggerEvent('Add Camera Zoom','','')
-- 	end

--     if curBeat >= 80 and curBeat <= 91 then
-- 		triggerEvent('Add Camera Zoom','','')
-- 	end

--     if curBeat % 4 == 0 then
--     if curBeat >= 96 and curBeat <= 111 then
-- 		triggerEvent('Add Camera Zoom','0.04','0.06')
--         triggerEvent('Screen Shake','0.27, 0.003','0.27, 0.0015')
-- 	end

--     end

--     if curBeat >= 132 and curBeat <= 191 then
-- 		triggerEvent('Add Camera Zoom','0.03','0.05')
-- 	end

--     if curBeat >= 132 and curBeat <= 130 then
-- 		triggerEvent('Add Camera Zoom','0.03','0.05')
-- 	end

--     if curBeat >= 256 and curBeat <= 320 then
-- 		triggerEvent('Add Camera Zoom','','')
-- 	end

--     if curBeat >= 288 and curBeat <= 320 and curBeat ~= 302 and curBeat ~= 303 then
--         triggerEvent('Screen Shake','0.20, 0.002','0.20, 0.001')
-- 	end

--     if curBeat == 302 then
--         triggerEvent('Screen Shake','0.50, 0.01','0.50, 0.008')
--     end

--     if curBeat % 2 == 0 then
--         if curBeat >= 192 and curBeat <= 223 then
--             triggerEvent('Add Camera Zoom','','')
--         end

--         if curBeat >= 224 and curBeat <= 255 then
--             triggerEvent('Add Camera Zoom','0.02','0.03')
--             triggerEvent('Screen Shake','0.20, 0.003','0.20, 0.0015')
--         end
    
--         end

--     if curBeat == 206 then
--         dadzoom = 0.5
--         xx = 1400
--         yy = -100
--         doTweenAlpha('camalp', 'camHUD', 0.4, 0.2)
--     end

--     if curBeat == 208 then
--         dadzoom = 0.4
--         xx = 1220
--         yy = 0
--         doTweenAlpha('camalp', 'camHUD', 1, 0.2)
--     end

--     if curBeat == 449 then
--         dadzoom = 0.2
--     end
--     if curBeat == 452 then
--         doTweenZoom('zoom', 'camGame', 0.4, 20.21)
--     end

--     if curBeat == 501 then
--         dadzoom = 0.4
--     end

--     if curBeat == 552 then
--         bfzoom = 1
--         xx2 = 280;
--         yy2 = 450;
--         doTweenAlpha('camalp', 'camHUD', 0.1, 0.5)
--     end

--     if curBeat == 561 then
--         followchars = false
--         setProperty('defaultCamZoom', 1.5)
--         doTweenZoom('camZ1', 'camGame', 1.5, 0.2, 'expoOut')
--         doTweenX('camX1', 'camFollowPos', 200, 0.2)
--         doTweenY('camY1', 'camFollowPos', 550, 0.2)
--         triggerEvent('Camera Follow Pos',200,550)
--     end

--     if curBeat == 562 then
--         bfzoom = 0.6
--         xx2 = 380;
--         yy2 = 350;
--         doTweenZoom('camZ1', 'camGame', 0.8, 5)
--         setProperty('defaultCamZoom', 0.8)
--         doTweenX('camX2', 'camFollowPos', 1200, 6, 'quadInOut')
--         doTweenY('camY2', 'camFollowPos', -100, 6, 'quadInOut')
--         triggerEvent('Camera Follow Pos',1200,-100)
--     end

--     if curBeat == 590 then
--         followchars = true
--         doTweenAlpha('camalp', 'camHUD', 1, 0.5)
--     end

--     if curBeat >= 590 and curBeat <= 595 then
--         triggerEvent('Screen Shake','0.25, 0.002','0.25, 0.001')
--     end

--     if curBeat == 596 then
--         triggerEvent('Screen Shake','0.3, 0.05', '0.3, 0.004')
--     end
    

--     if curBeat == 660 then
--        setProperty('camGame.alpha', 0)
--     end
-- end