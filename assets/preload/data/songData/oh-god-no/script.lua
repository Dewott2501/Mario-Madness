function onBeatHit()

    if curBeat == 23 then
        doTweenZoom("test4", "camEst", 1, 3, 'cubeInOut')
        doTweenY("test5", "camEst.scroll", 0, 3, 'cubeInOut')
    end
end

function onStepHit()
    if curStep == 6 then -- YOU
        setProperty("introLText.visible", true) 
        objectPlayAnimation("introLText", '0', true)
        doTweenZoom("test0", "camEst", 1.2, 2, 'cubeOut')
        doTweenY("test1", "camEst.scroll", 40, 2, 'cubeOut')
    end

    if curStep == 10 then -- THOUGHT
        objectPlayAnimation("introLText", '1', true)
    end

    if curStep == 15 then -- KOOPA
        objectPlayAnimation("introLText", '2', true)
        objectPlayAnimation("introL", 'worked', true)
        objectPlayAnimation("introM", 'shock', true)
    end

    if curStep == 21 then -- WORKED
        objectPlayAnimation("introLText", '3', true)
        objectPlayAnimation("introL", 'alone', true)
        objectPlayAnimation("introM", 'scared', true)
    end

    if curStep == 24 then -- music
        objectPlayAnimation("introM", 'idle', true)
        objectPlayAnimation("introL", 'transition', true)

        doTweenAlpha("tag0", "introM", 0, 0.5, 'linear')
        doTweenAlpha("tag1", "introL", 0, 0.5, 'linear')
        doTweenAlpha("tag2", "introLText", 0, 0.5, 'linear')
        doTweenAlpha("tag3", "introbg", 0, 0.5, 'linear')
        doTweenAlpha("tag4", "bbar1", 0, 0.5, 'linear')
        doTweenAlpha("tag5", "bbar2", 0, 0.5, 'linear')
    end

    if curStep == 25 then -- ALONE
        objectPlayAnimation("introLText", '4', true)
        doTweenZoom("test2", "camEst", 1.4, 1, 'cubeIn')
        doTweenY("test3", "camEst.scroll", 80, 1, 'cubeIn')
    end

end