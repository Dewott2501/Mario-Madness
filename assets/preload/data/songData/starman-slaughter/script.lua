
-- local xx = 550;
-- local yy = 250;
-- local yyh = 350;
-- local xx2 = 1550;
-- local yy2 = 500;
-- local ofs = 30;
-- local ofs2 = 120;
-- local followchars = true;
-- local zoomchars = false;
-- local del = 0;
-- local del2 = 0;
-- local bfzoom =  0.5;
-- local dadzoom = 0.5;
-- local whosdad = 'dad'

function onCreatePost()
    setObjectOrder('gfGroup', 7)
--     setProperty('gfGroup.visible', true)
--     setProperty('gfGroup.x', 1000)
--     setProperty('gfGroup.y', 1500)

--     setProperty('peachCuts.x', -2000)
--     setProperty('peachCuts.y', -1500)
--     setProperty('peachCuts.visible', false);
--     setProperty('blackBarThingie.visible', false);
end

-- function onBeatHit()
--     if curBeat >= 36 and curBeat <= 96 then
--         triggerEvent('Add Camera Zoom','0.02','0.02')
--     end
--     if curBeat == 96 then
--         xx2 = 1050
--     end
--     if curBeat == 100 then
--         xx2 = 1550
--     end

--     if curBeat >= 100 and curBeat <= 132 then
--         triggerEvent('Add Camera Zoom','0.02','0.02')
--     end

--     if curBeat >= 196 and curBeat <= 260 then
--         if curBeat %2 == 0 then
--         triggerEvent('Add Camera Zoom','0.02','0.02')
--         end
--     end
--     if curBeat == 132 then
--         zoomchars = true
--         xx = 850
--         dadzoom = 0.7
--         whosdad = 'gf'
--     end

--     if curBeat == 196 then
--         xx = 550
--         dadzoom = 0.5
--         whosdad = 'dad'
--     end

--     if curBeat == 262 then
--         bfzoom = 0.7
--         dadzoom = 0.7
--         yy = 800
--         setProperty('defaultCamZoom', 0.7)
--         doTweenZoom('tag', 'camGame', 0.7, 1, 'expoOut')
--     end
--     if curBeat == 269 then
--         followchars = false
--         doTweenX('tag1', 'camFollowPos', 1550, 1.38, 'expoIn')
--         doTweenY('tag2', 'camFollowPos', 800, 1.38, 'expoIn')
--         bfzoom = 0.7

--     end

--     if curBeat == 272 then
--         followchars = true
--         dadzoom = 0.6
--         yy = 250
--     end

--     if curBeat == 336 then
--         dadzoom = 0.5
--         bfzoom = 0.5
--         setProperty('defaultCamZoom', 0.5)
--     end

--     if curBeat == 396 then
--         dadzoom = 0.6
--         bfzoom = 0.6
--         xx2 = 1200
--         setProperty('defaultCamZoom', 0.6)
--         triggerEvent('Play Animation', 'death', 'gf');
--     end

--     if curBeat == 404 then
--         bfzoom = 0.8
--         xx2 = 1550
--         setProperty('defaultCamZoom', 0.8)
--     end

--     if curBeat == 406 then
--         bfzoom = 0.9
--         xx2 = 1650
--         setProperty('defaultCamZoom', 0.9)
--     end

--     if curBeat == 408 then
--         bfzoom = 0.7
--         xx2 = 1550
--         setProperty('defaultCamZoom', 0.6)
--     end

--     if curBeat == 444 then
--         bfzoom = 0.5
--         dadzoom = 0.5
--         setProperty('defaultCamZoom', 0.5)
--     end

--     if curBeat == 512 then
--         doTweenX('tag1', 'camFollowPos', 550, 1, 'expoOut')
--         doTweenY('tag2', 'camFollowPos', 250, 1, 'expoOut')
--     end

--     if curBeat == 514 then
--         setProperty('defaultCamZoom', 0.7)
--         doTweenZoom('tagend', 'camGame', 0.7, 3, 'linear')
--     end
-- end