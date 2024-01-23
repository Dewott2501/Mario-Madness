function onBeatHit()
    if curBeat % 8 == 0 then

        if curBeat >= 136 and curBeat <= 199 then
            triggerEvent('Triggers Dark Forest','4','')
        end
    end

    if curBeat >= 300 then
        triggerEvent('Triggers Dark Forest','6','')
    end
end

function onStepHit()
    if curStep == 1052 then
        doTweenZoom('zomss', 'camGame', 1, 0.5, 'cubeOut')
        doTweenAlpha('cameasdad', 'camHUD', 0.5, 0.10, 'linear')
    end
    if curStep == 1056 then
        doTweenAlpha('cameasdadss', 'camHUD', 1, 0.10, 'linear')
    end
    if curStep == 1068 then
        doTweenZoom('zom', 'camGame', 1, 0.4, 'cubeOut')
        doTweenAlpha('cameasdadssssss', 'camHUD', 0, 0.10, 'linear')
    end
    if curStep == 1072 then
        doTweenAlpha('cameasdadddsds', 'camHUD', 1, 0.10, 'linear')
    end
    if curStep > 160 and curStep < 1190 then
            triggerEvent('Triggers Dark Forest','7','')
    end
    if curStep > 1200 then
        triggerEvent('Triggers Dark Forest','7','1')
    end
end