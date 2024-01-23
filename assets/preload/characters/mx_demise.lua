local whoismx = '';
local isON = true;
-- check which character is mx which will allow mx to work as bf for some fucking reason
function onCreate()
    if getProperty('dad.curCharacter') == 'mx_demise' then
        -- debugPrint(whoismx .. ' is mx');
        whoismx = 'dad';
    else
        -- debugPrint('bf is mx, why tf is bf mx whats wrong with u lol');
        whoismx = 'boyfriend';
    end
end

-- fuck you
function onCreatePost()
    --make legs
    makeAnimatedLuaSprite('mxlegs','characters/MX_Demise_Assets', 0, 0);
    addAnimationByPrefix('mxlegs', 'exist', 'MX Running Legs', 35, true);
    --legs behind mx, gf behind legs
	-- setObjectOrder(whoismx .. 'Group', getObjectOrder(whoismx .. 'Group') + 13);
    -- setObjectOrder('mxlegs', getObjectOrder(whoismx .. 'Group') - 1);
    
	setProperty('mxlegs.x', getProperty(whoismx .. '.x'));
    setProperty('mxlegs.y', getProperty(whoismx .. '.y'));
	setProperty('mxlegs.offset.x', -3);
    setProperty('mxlegs.offset.y', -461);

	makeAnimatedLuaSprite('mxrightarm', 'characters/MX_Demise_Assets', 0, 0);
    addAnimationByPrefix('mxrightarm', 'exist2', 'MX Running Right Arm', 35, true);
    -- setObjectOrder('mxrightarm', getObjectOrder('mxlegs') - 1);
    addLuaSprite('mxrightarm', false);
    addLuaSprite('mxlegs', false);

	setProperty('mxrightarm.x', getProperty(whoismx .. '.x'));
    setProperty('mxrightarm.y', getProperty(whoismx .. '.y'));
	setProperty('mxrightarm.offset.x', 57);
    setProperty('mxrightarm.offset.y', -321);
	
	setProperty(whoismx .. '.origin.x', 833);
	setProperty(whoismx .. '.origin.y', 1003);

end

function onUpdatePost()

	-- live animation shit
    -- body is moved and rotated based on what animation frame the legs are on
    -- this happens every frame
    -- i used black magic to get these numbers
    -- no trial and error here.

    if getProperty('dad.alpha') == 0 or isON == false then
        setProperty('mxrightarm.alpha', 0)
        setProperty('mxlegs.visible', false)
    else
        setProperty('mxrightarm.alpha', 1)
        setProperty('mxlegs.visible',     true)
    end

    if isON == true then

    setProperty('mxlegs.x', getProperty(whoismx .. '.x'));
    setProperty('mxlegs.y', getProperty(whoismx .. '.y'));

    setProperty('mxrightarm.x', getProperty(whoismx .. '.x'));
    setProperty('mxrightarm.y', getProperty(whoismx .. '.y'));

	if getProperty(whoismx .. '.animation.curAnim.name') ~= 'idle' then
		setProperty('mxrightarm.visible', false);
        if getProperty('mxlegs.animation.frameIndex') == 0 then
            setProperty(whoismx .. '.angle', 0);
            setProperty(whoismx .. '.x', defaultOpponentX - 930);
            setProperty(whoismx .. '.y', defaultOpponentY - 870);
        end
        if getProperty('mxlegs.animation.frameIndex') == 2 then
            setProperty(whoismx .. '.angle', -2.7);
            setProperty(whoismx .. '.x', defaultOpponentX - 930 - 13.4);
            setProperty(whoismx .. '.y', defaultOpponentY - 870 - 72.75);
        end
        if getProperty('mxlegs.animation.frameIndex') == 4 then
            setProperty(whoismx .. '.angle', -3.7);
            setProperty(whoismx .. '.x', defaultOpponentX - 930 - 18.05);
            setProperty(whoismx .. '.y', defaultOpponentY - 870 - 94.8);
        end
        if getProperty('mxlegs.animation.frameIndex') == 6 then
            setProperty(whoismx .. '.angle', -2.2);
            setProperty(whoismx .. '.x', defaultOpponentX - 930 - 10.8);
            setProperty(whoismx .. '.y', defaultOpponentY - 870 - 26.5);
        end
        if getProperty('mxlegs.animation.frameIndex') == 8 then
            setProperty(whoismx .. '.angle', 0);
            setProperty(whoismx .. '.x', defaultOpponentX - 930);
            setProperty(whoismx .. '.y', defaultOpponentY - 870);
        end
        if getProperty('mxlegs.animation.frameIndex') == 10 then
            setProperty(whoismx .. '.angle', -2.7);
            setProperty(whoismx .. '.x', defaultOpponentX - 930 - 13.4);
            setProperty(whoismx .. '.y', defaultOpponentY - 870 - 72.75);
        end
        if getProperty('mxlegs.animation.frameIndex') == 12 then
            setProperty(whoismx .. '.angle', -3.7);
            setProperty(whoismx .. '.x', defaultOpponentX - 930 - 18.05);
            setProperty(whoismx .. '.y', defaultOpponentY - 870 - 94.8);
        end
        if getProperty('mxlegs.animation.frameIndex') == 14 then
            setProperty(whoismx .. '.angle', -2.2);
            setProperty(whoismx .. '.x', defaultOpponentX - 930 - 10.8);
            setProperty(whoismx .. '.y', defaultOpponentY - 870 - 26.5);
        end
	else
        setProperty(whoismx .. '.animation.frameIndex', getProperty('mxlegs.animation.frameIndex') + 32)
		setProperty('mxrightarm.visible', true);
        setProperty(whoismx .. '.angle', 0);
        setProperty(whoismx .. '.x', defaultOpponentX - 930);
        setProperty(whoismx .. '.y', defaultOpponentY - 870);
	end

    end
end

function onEvent(name, value1, value2)

    if name == 'Change Character' then
        if value1 == '1' then

        if value2 == 'mx_demiseUG' then
            isON = false;
            setProperty('mxrightarm.visible', false)
            setProperty('mxlegs.visible', false)
        else
            isON = true;
            setProperty('mxrightarm.visible', true)
            setProperty('mxlegs.visible', true)
        end

        end
	end

end