package modchart;

import flixel.math.FlxAngle;
import modchart.*;
import modchart.events.CallbackEvent;

class Modcharts {
    static function numericForInterval(start, end, interval, func){
        var index = start;
        while(index < end){
            func(index);
            index += interval;
        }
    }

    static var songs = ["fresh"];
	public static function isModcharted(songName:String){
		if (songs.contains(songName.toLowerCase()))
            return true;

        // add other conditionals if needed
        
        //return true; // turns modchart system on for all songs, only use for like.. debugging
        return false;
    }
    
    public static function loadModchart(modManager:ModManager, songName:String){
        PlayState.songIsModcharted = true;
        switch (songName.toLowerCase()){
            case 'all-stars':
                modManager.queueSet(4544, "transformX", -320, 0);
                modManager.queueSet(4544, "transformX", 1500, 1);

                modManager.queueSet(4800, "transformX", 0, 0);
                modManager.queueSet(4800, "transformX", 0, 1);

            case 'nourishing blood':
                var counter:Int = 0;
                numericForInterval(656, 912, 2, function(step){
                    
                    if(counter == 0){
                    for(i in 0...4){
                    modManager.queueSet(step, "mini"+ i + "X", -0.5);
                    modManager.queueSet(step, "mini"+ i + "Y",  0.5);
                    modManager.queueSet(step, "transform"+ i + "Y",  30);
                    modManager.queueEase(step, step + 2, "transform" + i + "Y", -30, 'quadOut');
                    modManager.queueEase(step, step+2, "mini"+ i + "X", 0, 'circOut');
                    modManager.queueEase(step, step+2, "mini"+ i + "Y", 0, 'circOut');
                    }
                    counter = 1;
                    }else{
                    for(i in 0...4){
                    modManager.queueEase(step, step + 2, "transform" + i + "Y", 0, 'quadIn');
                    modManager.queueEase(step, step+2, "mini"+ i + "X", 0.3, 'circIn');
                    modManager.queueEase(step, step+2, "mini"+ i + "Y", -0.3, 'circIn');
                    }
                    counter = 0;
                    }
                });
                var counter2:Int = 0;
                numericForInterval(784, 912, 4, function(step){
                    for(i in 0...4){
                    modManager.queueEase(step, step + 4, "confusion" + i, modManager.randomFloat(-60, 60));
                    }

                    if(counter2 == 0){
                        modManager.queueEase(step, step + 4, "opponentSwap", 0.05);
                        counter2 = 1;
                    }else{
                        modManager.queueEase(step, step + 4, "opponentSwap", -0.05);
                        counter2 = 0;
                    }
                });
                for(i in 0...4){
                modManager.queueSet(912, "mini"+ i + "X", 0);
                modManager.queueSet(912, "mini"+ i + "Y", 0);
                modManager.queueSet(912, "transform" + i + "Y", 0);
                modManager.queueEase(912, 916, "confusion" + i, 0, 'backOut');
                modManager.queueEase(912, 916, "opponentSwap", 0, 'backOut');
                }
                var number:Int = 0;
                numericForInterval(944, 1168, 32, function(step){
                    for(i in 0...8){
                        if(number > 40){
                            number = 40;
                        }
                        if(i < 4){
                            modManager.queueEase(step + (i * 4), (step + (i * 4)) + 2, "transform" + i + "Y", number * -1, 'expoOut', 1);
                            modManager.queueEase((step + (i * 4)) + 2, (step + (i * 4)) + 4, "transform" + i + "Y", 0, 'expoIn', 1);
                        }else{
                            modManager.queueEase(step + (i * 4), (step + (i * 4)) + 2, "transform" + (i - 4) + "Y", number * -1, 'expoOut', 0);
                            modManager.queueEase((step + (i * 4)) + 2, (step + (i * 4)) + 4, "transform" + (i - 4) + "Y", 0, 'expoIn', 0);
                        }
                        number += 10;
                    }
                });
            case 'starman slaughter':
                if(ClientPrefs.middleScroll){
                    modManager.setValue("opponentSwap", 0.5);
                    modManager.setValue("alpha", 1, 1);
                }else{
                    modManager.queueEase(2048, 2052, "alpha", 1, 1);
                }
            case 'oh god no':
                modManager.setValue("alpha", 1, 1);
                modManager.setValue("opponentSwap", 1);
                modManager.setValue("transformX", 320, 0);
                modManager.setValue("transformY", 120, 1);
                modManager.queueEase(92, 104, "opponentSwap", 1, 'expoOut');

                if(!ClientPrefs.middleScroll){
                    modManager.queueEase(92, 104, "transformY", 0, 'elasticOut', 1);
                    modManager.queueEase(92, 104, "transformX", 0, 'expoOut', 0);
                    modManager.queueEase(92, 104, "alpha", 0, 'elasticOut', 1);
                    modManager.queueEase(800, 808, "alpha", 0, 'linear', 1);
                    modManager.queueEase(672, 680, "alpha", 0.3, 'linear', 1);
                }

                modManager.queueEase(672, 680, "alpha", 0.3, 'linear', 0);


                modManager.queueEase(800, 808, "alpha", 0, 'linear', 0);

            case 'the end':
                modManager.queueSet(296 * 4, "opponentSwap", 0.5);
                modManager.queueSet(296 * 4, "alpha", 1, 1);
                modManager.queueSet(296 * 4, "flip", -0.25);
            case 'bad day':
                if(!ClientPrefs.downScroll){
                    for(i in 0...4){
                        modManager.setValue("transform" + i + "Y", 0, 0);
                        modManager.queueEase(560 + ((i) * 4), 560 + (((i) * 4) + 2), "transform" + (3 - i) + "Y", 70, 'cubeOut', 0);
                    }
                }
                else{
                    for(i in 0...4){
                        modManager.setValue("transform" + i + "Y", 0, 0);
                        modManager.queueEase(560 + (((i) * 4) + 2), 560 + (((i) * 4) + 4), "transform" + (3 - i) + "Y", -70, 'cubeOut', 0);
                    }
                }

            case 'mario sing and game rythm 9':
                modManager.setValue("transformX", -24, 0);
                modManager.setValue("transformX", 76, 1);
                if(ClientPrefs.downScroll) modManager.setValue("transformY", 40);
                else modManager.setValue("transformY", -10);

                if(ClientPrefs.middleScroll){
                    modManager.setValue("opponentSwap", 0.45);
                    modManager.setValue("alpha", 1, 1);
                }

                PlayState.songIsModcharted = false;
            case 'no party' | 'no party old':
                var thex = -983;
                modManager.setValue("alpha", 1, 1);
                modManager.setValue("transform0X", thex        , 0);
                modManager.setValue("transform1X", thex + 169.6 / 3.5, 0);
                modManager.setValue("transform2X", thex + 339.3 / 3.5, 0);
                modManager.setValue("transform3X", thex + 509   / 3.5, 0);
                if(ClientPrefs.downScroll){
                    modManager.setValue("transformY", -136, 0);
                }else{
                    modManager.setValue("transformY", -100, 0);
                }

            case 'alone':
                modManager.setValue("alpha", 1, 0);
                modManager.setValue("alpha", 0.3, 1);
                modManager.setValue("drunk", 0.5, 0);
                modManager.queueEase(192, 208, "alpha", 0.2, 0);
                modManager.queueEase(160, 184, "alpha", 0, 1);
                modManager.queueEase(1660, 1704, "alpha", 1, 0);
            case 'promotion':
                modManager.setValue("opponentSwap", 1);

                modManager.queueEase(655, 668, "alpha", 1, 'quadInOut');
                var step = 655;
                var counter = 0;
                var counter2 = 4;
                for(i in 0...4){
                    modManager.queueEase(step + counter, 672, "transform" + i + "Y", 300 + (50 * counter2), 'quadIn');
                    modManager.queueEase(step + counter, 672, "confusion" + i, -22.5 * counter2, 'quadInOut');
            
                    counter += 2;
                    counter2 -= 1;
                }
            
                for(i in 0...4){
                    if(!ClientPrefs.downScroll) modManager.queueSet(688, "transform" + i + "Y", 600);
                    else modManager.queueSet(688, "transform" + i + "Y", -600);
                    modManager.queueSet(688, 'confusion' + i, 360);
                    modManager.queueSet(688, 'opponentSwap', 0.5);
                }
            
                for (i in 0...4){
                    modManager.queueEase(704 - i, 720, "transform" + i + "Y", 0, 'expoIn');
                    modManager.queueEase(704 - i, 720, "alpha", 0, 'expoIn', 0);
                    modManager.queueEase(704 - i, 720, "confusion" + i, 0, 'expoIn');
                }
            
                var counter:Int = -1;
                numericForInterval(721, 848, 16, function(step){
                    modManager.queueSet(step, "flip", -0.25 / 2, 0);
                    modManager.queueEase(step, step+8, "flip", 0, 'quadOut', 0);
                    modManager.queueSet(step+8, "flip", -0.25 / 2, 0);
                    modManager.queueEase(step+8, step+16, "flip", 0, 'quadOut', 0);
            
                    counter *= -1;
                    modManager.queueSet(step, "mini0X", -0.75, 0);
                    modManager.queueSet(step, "mini0Y", -0.75, 0);
                    modManager.queueSet(step, "confusion0", -45 * counter, 0);
                    modManager.queueSet(step, "mini2X", -0.75, 0);
                    modManager.queueSet(step, "mini2Y", -0.75, 0);
                    modManager.queueSet(step, "confusion2", -45 * counter, 0);
                    modManager.queueEase(step, step+8, "mini0X", 0, 'circOut', 0);
                    modManager.queueEase(step, step+8, "mini0Y", 0, 'circOut', 0);
                    modManager.queueEase(step, step+8, "confusion0", 0, 'circOut', 0);
                    modManager.queueEase(step, step+8, "mini2Y", 0, 'circOut', 0);
                    modManager.queueEase(step, step+8, "mini2X", 0, 'circOut', 0);
                    modManager.queueEase(step, step+8, "confusion2", 0, 'circOut', 0);
            
                    modManager.queueSet(step+8, "mini1X", -0.75, 0);
                    modManager.queueSet(step+8, "mini1Y", -0.75, 0);
                    modManager.queueSet(step+8, "confusion1", -45 * counter, 0);
                    modManager.queueSet(step+8, "mini3X", -0.75, 0);
                    modManager.queueSet(step+8, "mini3Y", -0.75, 0);
                    modManager.queueSet(step+8, "confusion3", -45 * counter, 0);
                    modManager.queueEase(step+8, step+16, "mini1X", 0, 'circOut', 0);
                    modManager.queueEase(step+8, step+16, "mini1Y", 0, 'circOut', 0);
                    modManager.queueEase(step+8, step+16, "confusion1", 0, 'circOut', 0);
                    modManager.queueEase(step+8, step+16, "mini3X", 0, 'circOut', 0);
                    modManager.queueEase(step+8, step+16, "mini3Y", 0, 'circOut', 0);
                    modManager.queueEase(step+8, step+16, "confusion3", 0, 'circOut', 0);
                });
            
                var counter:Int = -1;
                numericForInterval(865, 976, 16, function(step){
                    modManager.queueSet(step, "flip", -0.25 / 2, 0);
                    modManager.queueEase(step, step+8, "flip", 0, 'quadOut', 0);
                    modManager.queueSet(step+8, "flip", -0.25 / 2, 0);
                    modManager.queueEase(step+8, step+16, "flip", 0, 'quadOut', 0);
            
                    counter *= -1;
                    modManager.queueSet(step, "mini0X", -0.75, 0);
                    modManager.queueSet(step, "mini0Y", -0.75, 0);
                    modManager.queueSet(step, "confusion0", -45 * counter, 0);
                    modManager.queueSet(step, "mini2X", -0.75, 0);
                    modManager.queueSet(step, "mini2Y", -0.75, 0);
                    modManager.queueSet(step, "confusion2", -45 * counter, 0);
                    modManager.queueEase(step, step+8, "mini0X", 0, 'circOut', 0);
                    modManager.queueEase(step, step+8, "mini0Y", 0, 'circOut', 0);
                    modManager.queueEase(step, step+8, "confusion0", 0, 'circOut', 0);
                    modManager.queueEase(step, step+8, "mini2Y", 0, 'circOut', 0);
                    modManager.queueEase(step, step+8, "mini2X", 0, 'circOut', 0);
                    modManager.queueEase(step, step+8, "confusion2", 0, 'circOut', 0);
            
                    modManager.queueSet(step+8, "mini1X", -0.75, 0);
                    modManager.queueSet(step+8, "mini1Y", -0.75, 0);
                    modManager.queueSet(step+8, "confusion1", -45 * counter, 0);
                    modManager.queueSet(step+8, "mini3X", -0.75, 0);
                    modManager.queueSet(step+8, "mini3Y", -0.75, 0);
                    modManager.queueSet(step+8, "confusion3", -45 * counter, 0);
                    modManager.queueEase(step+8, step+16, "mini1X", 0, 'circOut', 0);
                    modManager.queueEase(step+8, step+16, "mini1Y", 0, 'circOut', 0);
                    modManager.queueEase(step+8, step+16, "confusion1", 0, 'circOut', 0);
                    modManager.queueEase(step+8, step+16, "mini3X", 0, 'circOut', 0);
                    modManager.queueEase(step+8, step+16, "mini3Y", 0, 'circOut', 0);
                    modManager.queueEase(step+8, step+16, "confusion3", 0, 'circOut', 0);
                });
            
                var fuckMath = [-40, 40, -40, 40];
                var fuckmath2 = [-45, -45, 45, 45];
                var counter:Int = -1;
                numericForInterval(977, 1216, 16, function(step){
                    counter *= -1;
                    for (i in 0...4){
                        modManager.queueSet(step, "confusion" + i, fuckmath2[i], 0);
                        modManager.queueEase(step, step+8, "confusion" + i, 0, 'circOut', 0);
            
                        modManager.queueSet(step+8, "transform" + i + "Y", fuckMath[i] * counter, 0);
                        modManager.queueEase(step+8, step+16, "transform" + i + "Y", 0, 'quartOut', 0);
                    }
                    
                });
            
                var counter:Int = -1;
                numericForInterval(977, 1360, 16, function(step){
                    counter = counter +1;
                    if(counter > 1)counter = 0;
            
                    if(counter == 0){
                        modManager.queueEase(step, step+16, "opponentSwap", 0.75, 'quadInOut');
                    }else{
                        modManager.queueEase(step, step+16, "opponentSwap", 0.25, 'quadInOut');
                    }
                });
                
                modManager.queueEase(1216, 1232, "opponentSwap", 0.5, 'quadInOut');
                modManager.queueEase(1232, 1236, 'stealth', 0.25, 'quadInOut', 1);
                modManager.queueEase(1232, 1236, 'alpha', 0.5, 'quadInOut', 1);
                modManager.queueEase(1232, 1236, 'reverse', 1, 'quadInOut', 1);
                modManager.queueSet(1376, "opponentSwap", 0.5);

                modManager.queueEase(1360, 1364, 'alpha0', 1, 'expoOut');
                modManager.queueEase(1360, 1364, 'alpha1', 1, 'expoOut');
                modManager.queueEase(1360, 1364, 'alpha3', 1, 'expoOut');
                modManager.queueEase(1364, 1372, 'alpha2', 1, 'expoIn');

                modManager.queueEase(1360, 1364, 'alpha', 1, 'expoOut', 1);

                modManager.queueSet(1376, "alpha0", 0, 0);
                modManager.queueSet(1376, "alpha1", 0, 0);
                modManager.queueSet(1376, "alpha2", 0, 0);
                modManager.queueSet(1376, "alpha3", 0, 0);

                for(i in 0...4){
                modManager.queueEase(1375, 1376, 'confusion' + i, 0, 'linear');
                modManager.queueEase(1504, 1512, 'confusion' + i, 360, 'backOut');
                }
            
                numericForInterval(1297, 1360, 8, function(step){
                    modManager.queueSet(step, "flip", -0.25);
                    modManager.queueEase(step, step+8, "flip", 0, 'quadOut');
                });

                var counter0 = 0;
                var arrows0 = 0;
                var tryed = 1;
                numericForInterval(1376, 1632, 2, function(step){
                    
                    if(arrows0 == 0){
                        if(counter0 == 0){
                            modManager.queueEase(step, step + 2, "transform1Y", 50 * tryed,  'circOut');
                            modManager.queueEase(step, step + 2, "transform2Y", -50 * tryed, 'circOut');
                            counter0 = 1;
                            return;
                        }
                        if(counter0 == 1){
                            modManager.queueEase(step, step + 2, "transform1Y", 0, 'circIn');
                            modManager.queueEase(step, step + 2, "transform2Y", 0, 'circIn');
                            counter0 = 0;
                            arrows0 = 1;
                            return;
                        }
                    }else{
                        if(counter0 == 0){
                            modManager.queueEase(step, step + 2, "transform0X", -50, 'circOut');
                            modManager.queueEase(step, step + 2, "transform3X", 50,  'circOut');
                            counter0 = 1;
                            return;
                        }
                        if(counter0 == 1){
                            modManager.queueEase(step, step + 2, "transform0X", 0, 'circIn');
                            modManager.queueEase(step, step + 2, "transform3X", 0, 'circIn');
                            counter0 = 0;
                            arrows0 = 0;
                            
                            if(tryed == 1){
                                tryed = -1;
                            }else{
                                tryed = 1;
                            }
                            return;
                        }
                    }

                    
                });
                var counter:Int = -1;
                numericForInterval(1504, 1632, 16, function(step){
                    counter = counter +1;
                    if(counter > 1)counter = 0;
            
                    if(counter == 0){
                        modManager.queueEase(step, step+16, "opponentSwap", 0.75, 'quadInOut');
                    }else{
                        modManager.queueEase(step, step+16, "opponentSwap", 0.25, 'quadInOut');
                    }
                });

                modManager.queueEase(1632, 1648, "opponentSwap", 0.5, 'expoOut');
                for(i in 0...4){
                    modManager.queueEase(1632, 1648, 'confusion' + i, 0, 'expoOut');
                }


                numericForInterval(1648, 1762, 2, function(step){
                var osteps = [1648, 1664, 1696, 1712, 1728];
                var xdddd = [-20, -10, 10, 20];
                for(i in 0...osteps.length){
                    
                if(step == osteps[i]){
                    modManager.queueEase(osteps[i], osteps[i] + 4,  "flip", -0.12, 'circOut');
                    modManager.queueEase(osteps[i] + 4, osteps[i] + 8, "flip", 0, 'quadIn');
                for(o in 0...4){
                    modManager.queueEase(osteps[i], osteps[i] + 4, 'confusion' + o, 0 + xdddd[o], 'circOut');
                    modManager.queueEase(osteps[i] + 4, osteps[i] + 8, 'confusion' + o, 0, 'expoIn');
                }
                }
                }
                var endsteps = [1754, 1756, 1758, 1760];
                var order = [1, 0, 3, 2];
                for(index in 0...endsteps.length){
                if(step == endsteps[index]){
                modManager.queueEase(endsteps[index], endsteps[index] + 2, "transform" + order[index] + "Y", -50, 'expoOut');
                modManager.queueEase(endsteps[index] + 2, endsteps[index] + 12, "transform" + order[index] + "Y", 150, 'expoIn');
                modManager.queueEase(endsteps[index], endsteps[index] + 16, 'confusion'  + order[index], 360, 'expoOut');
                }
                }
                });

                modManager.queueEase(1754, 1754 + 8, 'alpha0', 1, 'expoIn');
                modManager.queueEase(1756, 1756 + 8, 'alpha1', 1, 'expoIn');
                modManager.queueEase(1758, 1758 + 8, 'alpha3', 1, 'expoIn');
                modManager.queueEase(1760, 1760 + 8, 'alpha2', 1, 'expoIn');

                
            case 'day out':
                modManager.setValue("opponentSwap", 1);
                
                modManager.queueEase(460, 467, "opponentSwap", 0, 'backInOut', 0);
                modManager.queueEase(462, 467, "alpha", 1, 'backInOutOut', 1);

                modManager.queueEase(518, 520, "alpha", 1, 'quadInOut', 0);
                modManager.queueSet(521, "opponentSwap", 1);
                modManager.queueEase(524, 528, "alpha", 0, 'quadInOut', 0);

                modManager.queueEase(668, 675, "opponentSwap", 0, 'backInOut', 0);
                modManager.queueEase(700, 706, "opponentSwap", 1, 'backInOut', 0);

                modManager.queueEase(732, 738, "opponentSwap", 0, 'backInOut', 0);

                modManager.queueEase(752, 756, "alpha", 1, 'quadInOut', 0);
                modManager.queueSet(780, "opponentSwap", 0);
                modManager.queueEase(784, 788, "alpha", 0, 'quadInOut', 0);

                modManager.queueEase(908, 914, "opponentSwap", 1, 'backInOut', 0);
                modManager.queueEase(1228, 1234, "opponentSwap", 0, 'backInOut', 0);

                modManager.queueEase(1312, 1316, "alpha", 1, 'quadInOut', 0);
            case 'unbeatable':
                //hardstyle
                modManager.queueEase(1344, 1352, "alpha", 1, 'quadInOut', 1);
                modManager.queueEase(1360, 1376, "opponentSwap", 0.5, 'cubeInOut', 0);
                modManager.queueSet(1696, "opponentSwap", 0);
                modManager.queueSet(1696, "alpha", 0);

                //duck hunt cool shit
                modManager.queueSet(2896, "opponentSwap", 0.5);
                modManager.queueSet(2896, "alpha", 1, 1);

                modManager.queueSet(3152, "opponentSwap", 0);
                modManager.queueSet(3152, "alpha", 0);

                //bowser cool shit
                modManager.queueEase(3968, 3984, "alpha", 1, 'quadInOut', 1);
                modManager.queueEase(3976, 3992, "opponentSwap", 0.5, 'cubeInOut', 0);

                modManager.queueSet(4736, "opponentSwap", 0);
                modManager.queueSet(4736, "alpha", 0);

                modManager.queueSet(4815, "opponentSwap", 0.5);
                modManager.queueSet(4815, "alpha", 1, 1);

                var bumpSteps = [5776, 5792, 5808, 5816, 5824, 5832, 5834, 5836, 5838];
                modManager.queueEase(5582, 5586, "opponentSwap", 0.5, 'bounceOut');
                modManager.queueEase(5582, 5586, "alpha", 1, 'bounceOut', 1);
                // modManager.queueSet(5586, "transformY", 400, 1);
                for(step in bumpSteps){
                    modManager.queueSet(step, "transformZ", 0.125);
                    modManager.queueEase(step, step+8, "transformZ", 0, 'quadOut');
                }
            
                modManager.queueEase(5712, 5840, "tipsy", 1, 'quadInOut');
                modManager.queueEase(5712, 5840, "flip", -1, 'quadInOut', 1);
                // modManager.queueEase(5712, 5840, "transformY", 0, 'quadInOut', 1);
                modManager.queueEase(5712, 5840, "transform1X", (-342) + 112, 'quadInOut', 1);
                modManager.queueEase(5712, 5840, "transform2X", 342 - 112, 'quadInOut', 1);
                modManager.queueEase(5712, 5840, "alpha", 0.5, 'quadInOut', 1);
                modManager.queueEase(5712, 5840, "sudden", 2, 'quadInOut', 1);
                modManager.queueEase(5712, 5840, "stealth", 0.5, 'quadInOut', 1);
            
                modManager.queueEase(5840, 5844, "tipsy", 0.25, 'quadInOut');
                modManager.queueEase(5840, 5844, "beat", 0.5, 'quadInOut');
                var strum = 0;
                numericForInterval(5840, 6096, 4, function(step){
                    if(step >= 5961) strum = 1;
                   modManager.queueSet(step, "flip", -0.125, strum);
                     modManager.queueEase(step, step+4, "flip", 0, 'quartOut', strum);
                });
            
                modManager.queueEase(5964, 5968, "transform1X", 0, 'bounceOut', 1);
                modManager.queueEase(5964, 5968, "transform2X", 0, 'bounceOut', 1);
                modManager.queueEase(5964, 5968, "transform1X", (-342) + 112, 'bounceOut', 0);
                modManager.queueEase(5964, 5968, "transform2X", 342 - 112, 'bounceOut', 0);
                modManager.queueEase(5964, 5968, "flip", -1, 'bounceOut', 0);
                modManager.queueEase(5964, 5968, "flip", 0, 'bounceOut', 1);
            
                modManager.queueEase(6096, 6104, "alpha", 1, 'quadOut', 0);
                modManager.queueEase(6096, 6104, "alpha", 0, 'quadOut', 1);
                modManager.queueEase(6096, 6104, "stealth", 0, 'quadOut', 1);
                modManager.queueEase(6096, 6104, "sudden", 0, 'quadOut', 1);
                modManager.queueEase(6096, 6104, "beat", 0, 'quadOut');
            
                modManager.queueEase(6224, 6228, "alpha", 1, 'quadOut', 1);
            
                modManager.queueSet(6228, "mini", -.625, 0);
                modManager.queueSet(6228, "tipsy", 0);
                modManager.queueSet(6228, "alpha", 0, 0);
                for(i in 0...4){
                    modManager.queueSet(6228, "alpha" + i, 1, 0);
                }
                modManager.queueSet(6228, "transform1X", 0, 0);
                modManager.queueSet(6228, "transform2X", 0, 0);
                modManager.queueSet(6228, "flip", 0, 0);
                modManager.queueSet(6228, "centered", 1, 0);
                modManager.queueSet(6228, "split", 1, 0);
                modManager.queueEase(6248, 6254, "alpha0", 0, 'quadOut');
                modManager.queueEase(6248, 6254, "alpha2", 0, 'quadOut');
            
                modManager.queueEase(6272, 6280, "alpha0", 1, 'quadOut');
                modManager.queueEase(6272, 6280, "alpha2", 1, 'quadOut');
            default:
                if(ClientPrefs.middleScroll){
                    modManager.setValue("opponentSwap", 0.5);
                    modManager.setValue("alpha", 1, 1);
                }
                PlayState.songIsModcharted = false;
                
        }
        trace('${songName} modchart loaded!');
    }
}