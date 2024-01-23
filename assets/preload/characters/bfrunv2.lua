function onUpdatePost()
    if getProperty('boyfriend.animation.curAnim.name') == 'idle' then
        setProperty('boyfriend.animation.frameIndex', getProperty('bftors.animation.frameIndex'))
        -- debugPrint(getProperty('bftors.animation.frameIndex') + 14, ' ', getProperty('boyfriend.animation.curAnim.name'))
        -- debugPrint(getProperty('bftors.animation.frameIndex') + 8)
    end
end