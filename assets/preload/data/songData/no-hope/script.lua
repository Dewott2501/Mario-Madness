function onBeatHit()

    -- if curBeat == 124 or curBeat == 405  then
    --     triggerEvent('Power Attack','','')
    -- end

    if curBeat % 2 == 0 then

        if curBeat >= 128 and curBeat <= 208 then
            triggerEvent('Add Camera Zoom','0.02','')
        end

        if curBeat >= 144 and curBeat <= 208 then
            triggerEvent('Add Camera Zoom','0.02','')
            triggerEvent('Screen Shake','0.27, 0.003','0.27, 0.0015')
        end

        if curBeat >= 400 and curBeat <= 455 then
            triggerEvent('Add Camera Zoom','0.02','')
        end

    end

    if curBeat % 4 == 0 then

        if curBeat >= 216 and curBeat <= 276 then
            triggerEvent('Add Camera Zoom','0.04','0.01')
        end

        if curBeat >= 456 and curBeat <= 552 then
            triggerEvent('Add Camera Zoom','0.04','0.01')
        end

    end

    if curBeat >= 280 and curBeat <= 344 then
        triggerEvent('Add Camera Zoom','0.02','')
        triggerEvent('Screen Shake','0.27, 0.004','0.27, 0.002')
    end

end