local whoispico = '';

local fuckoff = false;

function onCreate()
    if getProperty('boyfriend.curCharacter') == 'pico_run' then
        -- debugPrint('pico is pico');
        whoispico = 'boyfriend';
    else
        -- debugPrint('dad is pico whats wrong with u');
        whoispico = 'dad';
    end
end

-- fuck you
function onEvent(tag)
    if tag == 'fuckoff' then
        -- debugPrint('fuckoff')
        fuckoff = true
        
        makeAnimatedLuaSprite('picoarm', 'characters/Too_Late_Pico_FINALSEQUENCE_assets', 0, 0);
        addAnimationByPrefix('picoarm', 'singLEFT', 'TopLeftBack', 24, false);
        addAnimationByPrefix('picoarm', 'singUP', 'TopUpBack', 24, false);
        addAnimationByPrefix('picoarm', 'singRIGHT', 'TopRightBack', 24, false);
        -- setObjectOrder('picoarm', getObjectOrder('picolegs') - 1);
        addLuaSprite('picoarm', false);

        setProperty('picoarm.x', getProperty('boyfriend.x'));
        setProperty('picoarm.y', getProperty('boyfriend.y'));

        --make legs
        makeAnimatedLuaSprite('picolegs','characters/Too_Late_Pico_FINALSEQUENCE_assets', 0, 0);
        addAnimationByPrefix('picolegs', 'exist', 'Legs', 32, true);

        --legs behind pico
        -- setObjectOrder('boyfriendGroup', getObjectOrder('boyfriendGroup') + 7);
        -- setObjectOrder('picolegs', getObjectOrder('boyfriendGroup') - 1);
        addLuaSprite('picolegs', false);

        setProperty('picolegs.x', getProperty('boyfriend.x'));
        setProperty('picolegs.y', getProperty('boyfriend.y'));
        setProperty('picolegs.offset.x', 35);
        setProperty('picolegs.offset.y', -275);

        setProperty('boyfriend.origin.x', 235);
        setProperty('boyfriend.origin.y', 315);
        setProperty('picoarm.origin.x', 170);
        setProperty('picoarm.origin.y', 160);
    end
end

function goodNoteHit()
    if getProperty('boyfriend.animation.curAnim.name') ~= 'singDOWN' then
        objectPlayAnimation('picoarm', getProperty('boyfriend.animation.curAnim.name'), true)
    end
end

function onUpdatePost()

	-- live animation shit
    -- body is moved and rotated based on what animation frame the legs are on
    -- this happens every frame
    -- i used black magic to get these numbers
    -- no trial and error here.
    if fuckoff then
        if getProperty('boyfriend.animation.curAnim.name') ~= 'idle' and getProperty('boyfriend.animation.curAnim.name') ~= 'dialog1' then
            if getProperty('boyfriend.animation.curAnim.name') ~= 'singDOWN' then
                setProperty('picoarm.visible', true);
                if getProperty('picoarm.animation.curAnim.name') == 'singUP' then
                    setProperty('picoarm.offset.x', -273);
                    setProperty('picoarm.offset.y', -180);
                end
                if getProperty('picoarm.animation.curAnim.name') == 'singRIGHT' then
                    setProperty('picoarm.offset.x', -50);
                    setProperty('picoarm.offset.y', -200);
                end
                if getProperty('picoarm.animation.curAnim.name') == 'singLEFT' then
                    setProperty('picoarm.offset.x', -222);
                    setProperty('picoarm.offset.y', -207);
                end
            else
                setProperty('picoarm.visible', false);
            end

            if getProperty('picolegs.animation.frameIndex') == 0 then
                setProperty('boyfriend.y', defaultBoyfriendY + 500);
                setProperty('boyfriend.angle', -0.4)
                setProperty('picoarm.y', getProperty('boyfriend.y'));
                setProperty('picoarm.angle', -0.4)
            end
            if getProperty('picolegs.animation.frameIndex') == 2 then
                setProperty('boyfriend.y', defaultBoyfriendY + 500 + -3.75);
                setProperty('boyfriend.angle', 0.8)
                setProperty('picoarm.y', getProperty('boyfriend.y') + -3.75);
                setProperty('picoarm.angle', 0.8)
            end
            if getProperty('picolegs.animation.frameIndex') == 4 then
                setProperty('boyfriend.y', defaultBoyfriendY + 500 + 2.4);
                setProperty('boyfriend.angle', 1.8)
                setProperty('picoarm.y', getProperty('boyfriend.y') + 2.4);
                setProperty('picoarm.angle', 1.8)
            end
            if getProperty('picolegs.animation.frameIndex') == 6 then
                setProperty('boyfriend.y', defaultBoyfriendY + 500 + 6);
                setProperty('boyfriend.angle', 0.3)
                setProperty('picoarm.y', getProperty('boyfriend.y') + 6);
                setProperty('picoarm.angle', 0.3)
            end
            if getProperty('picolegs.animation.frameIndex') == 8 then
                setProperty('boyfriend.y', defaultBoyfriendY + 500 + 1.1);
                setProperty('boyfriend.angle', -0.7)
                setProperty('picoarm.y', getProperty('boyfriend.y') + 1.1);
                setProperty('picoarm.angle', -0.7)
            end
            if getProperty('picolegs.animation.frameIndex') == 10 then
                setProperty('boyfriend.y', defaultBoyfriendY + 500 + -6.4);
                setProperty('boyfriend.angle', 1.2)
                setProperty('picoarm.y', getProperty('boyfriend.y') + -6.4);
                setProperty('picoarm.angle', 1.2)
            end
            if getProperty('picolegs.animation.frameIndex') == 12 then
                setProperty('boyfriend.y', defaultBoyfriendY + 500 + -4.4);
                setProperty('boyfriend.angle', 2.2)
                setProperty('picoarm.y', getProperty('boyfriend.y') + -4.4);
                setProperty('picoarm.angle', 2.2)
            end
            if getProperty('picolegs.animation.frameIndex') == 14 then
                setProperty('boyfriend.y', defaultBoyfriendY + 500 + 2.15);
                setProperty('boyfriend.angle', 1.5)
                setProperty('picoarm.y', getProperty('boyfriend.y') + 2.15);
                setProperty('picoarm.angle', 1.5)
            end
        else
            if getProperty('boyfriend.animation.curAnim.name') ~= 'dialog1' then
                setProperty('boyfriend.animation.frameIndex', getProperty('picolegs.animation.frameIndex') + 89)
            end
            setProperty('picoarm.visible', false);
            setProperty('boyfriend.angle', 0);
            setProperty('boyfriend.y', defaultBoyfriendY + 500);
            
        end
        setProperty('picolegs.x', getProperty('boyfriend.x'));
        setProperty('picolegs.y', getProperty('boyfriend.y'));
        setProperty('picoarm.x', getProperty('boyfriend.x'));
        setProperty('picoarm.y', getProperty('boyfriend.y'));
    end
    -- 362.85 fla y values of torso
    -- 359.1 
    -- 365.25
    -- 368.85
    -- 363.95
    -- 356.45
    -- 358.45
    -- 365

    -- 0 after subtracting 362.85 from all values
    -- -3.75 
    -- 2.4
    -- 6
    -- 1.1
    -- -6.4
    -- -4.4
    -- 2.15

    -- rotation values
    -- -0.4
    -- 0.8
    -- 1.8
    -- 0.3
    -- -0.7
    -- 1.2
    -- 2.2
    -- 1.5
end