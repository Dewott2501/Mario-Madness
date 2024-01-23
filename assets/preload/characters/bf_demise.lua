local whoisbf = '';
local isON = true;
-- check which character is mx which will allow mx to work as bf for some fucking reason
function onCreate()
    if getProperty('boyfriend.curCharacter') == 'bf_demise' then
        -- debugPrint('bf is bf');
        whoisbf = 'boyfriend';
    else
        -- debugPrint('dad is bf wtf why');
        whoisbf = 'dad';
    end
end

-- fuck you
function onCreatePost()
    --make legs
    makeAnimatedLuaSprite('bflegs','characters/Demise_BF_Assets', 0, 0);
    addAnimationByPrefix('bflegs', 'exist', 'Bottom', 40, true);
    --legs behind bf
	-- setObjectOrder(whoisbf .. 'Group', getObjectOrder(whoisbf .. 'Group') + 10);
    -- setObjectOrder('bflegs', getObjectOrder(whoisbf .. 'Group') - 1);
    -- setObjectOrder('gfGroup', getObjectOrder('bflegs') - 1);
    

	setProperty('bflegs.x', getProperty(whoisbf .. '.x'));
    setProperty('bflegs.y', getProperty(whoisbf .. '.y'));
	setProperty('bflegs.offset.x', 33);
    setProperty('bflegs.offset.y', -230);

	makeAnimatedLuaSprite('bfrightarm', 'characters/Demise_BF_Assets', 0, 0);
    addAnimationByPrefix('bfrightarm', 'exist2', 'BF Right Arm', 40, true);
    -- arm behind bf and legs
    -- setObjectOrder('bfrightarm', getObjectOrder('bflegs') - 1);
    addLuaSprite('bfrightarm', false);
    addLuaSprite('bflegs', false);

	setProperty('bfrightarm.x', getProperty(whoisbf .. '.x'));
    setProperty('bfrightarm.y', getProperty(whoisbf .. '.y'));
	setProperty('bfrightarm.offset.x', -13);
    setProperty('bfrightarm.offset.y', -155);
	
	-- setProperty(whoisbf .. '.origin.x', 833);
	-- setProperty(whoisbf .. '.origin.y', 1003);

end

function onUpdatePost()

    if getProperty('boyfriend.alpha') == 0 or isON == false then
        setProperty('bfrightarm.alpha', 0)
        setProperty('bflegs.visible', false)
    else
        setProperty('bfrightarm.alpha', 1)
        setProperty('bflegs.visible',     true)
    end

	-- live animation shit
    -- body is moved and rotated based on what animation frame the legs are on
    -- this happens every frame
    -- i used black magic to get these numbers
    -- no trial and error here.

    if isON == true then

    setProperty('bflegs.x', getProperty(whoisbf .. '.x'));
    setProperty('bflegs.y', getProperty(whoisbf .. '.y'));

    setProperty('bfrightarm.x', getProperty(whoisbf .. '.x'));
    setProperty('bfrightarm.y', getProperty(whoisbf .. '.y'));

	if getProperty(whoisbf .. '.animation.curAnim.name') ~= 'idle' then
		setProperty('bfrightarm.visible', false);
        if getProperty('bflegs.animation.frameIndex') == 31 then
            setProperty(whoisbf .. '.y', defaultBoyfriendY + 270);
        end
        if getProperty('bflegs.animation.frameIndex') == 33 then
            setProperty(whoisbf .. '.y', defaultBoyfriendY + 270 + (7.35 / 2));
        end
        if getProperty('bflegs.animation.frameIndex') == 35 then
            setProperty(whoisbf .. '.y', defaultBoyfriendY + 270 + (14.7 / 2));
        end
        if getProperty('bflegs.animation.frameIndex') == 37 then
            setProperty(whoisbf .. '.y', defaultBoyfriendY + 270 + (2.25 / 2));
        end
        if getProperty('bflegs.animation.frameIndex') == 39 then
            setProperty(whoisbf .. '.y', defaultBoyfriendY + 270 + (5.05 / 2));
        end
        if getProperty('bflegs.animation.frameIndex') == 41 then
            setProperty(whoisbf .. '.y', defaultBoyfriendY + 270 + (9.2 / 2));
        end
        if getProperty('bflegs.animation.frameIndex') == 43 then
            setProperty(whoisbf .. '.y', defaultBoyfriendY + 270 + (12.6 / 2));
        end
        if getProperty('bflegs.animation.frameIndex') == 45 then
            setProperty(whoisbf .. '.y', defaultBoyfriendY + 270 + (3.15 / 2));
        end
	else
        setProperty(whoisbf .. '.animation.frameIndex', getProperty('bflegs.animation.frameIndex') - 16)
		setProperty('bfrightarm.visible', true);
        setProperty(whoisbf .. '.angle', 0);
        setProperty(whoisbf .. '.y', defaultBoyfriendY + 230);
	end
    end

    -- 210.95 fla y values of torso
    -- 218.3 
    -- 225.65
    -- 213.2
    -- 216
    -- 220.15
    -- 223.55
    -- 214.1

    -- 0 after subtracting 210.95 from all values
    -- 7.35 
    -- 14.7
    -- 2.25
    -- 5.05
    -- 9.2
    -- 12.6
    -- 3.15
end

function onEvent(name, value1, value2)

    if name == 'Change Character' then

        if value1 == '0' then

        if value2 == 'bf_demiseUG' then
            isON = false;
            setProperty('bfrightarm.visible', false)
            setProperty('bflegs.visible', false)
        else
            isON = true;
            setProperty('bfrightarm.visible', true)
            setProperty('bflegs.visible', true)
        end
        
        end
	end

end