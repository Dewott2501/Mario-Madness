function onBeatHit()

    if curBeat >= 48 and curBeat <= 112 then
        triggerEvent('Add Camera Zoom','0.005','')
    end

    if curBeat >= 112 and curBeat <= 141 then
        if curBeat % 2 == 0 then
            triggerEvent('Add Camera Zoom','0.015','')
        end
    end

    if curBeat == 142 then
        setProperty("defaultCamZoom", "0.9")
    end

    if curBeat >= 144 and curBeat <= 176 then
        if curBeat % 2 == 0 then
            triggerEvent('Add Camera Zoom','0.015','')
        end
    end

    if curBeat >= 112 and curBeat <= 175 then
        if curBeat % 8 == 0 then
            triggerEvent('Screen Shake','0.35, 0.002','0.35, 0.002')
        end
    end

    if curBeat == 245 then
        setProperty("defaultCamZoom", "0.6")
        triggerEvent('Camera Follow Pos', '1470','60')
    end

    if curBeat >= 258 and curBeat <= 324 then
        triggerEvent('Add Camera Zoom','0.00625','')
    end

    if curBeat >= 372 and curBeat <= 434 then
        triggerEvent('Add Camera Zoom','0.005','')
    end

    if curBeat >= 436 and curBeat <= 500 then
        triggerEvent('Add Camera Zoom','0.005','')
    end
end