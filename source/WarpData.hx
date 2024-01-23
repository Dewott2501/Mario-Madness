package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import lime.utils.Assets;

using StringTools;

class WarpData
{
	public static final script:Array<Dynamic> =[ ["Well done", 0.2], ["Very well done", 2.2], ["I must say, I am impressed", 4.6], ["Youre a long way from home", 9], ["Arent you?", 10.7], ["Tell me, why do you persist?", 12.2],
	["", 15.2], ["No matter", 15.8], ["All good things", 17.2], ["Must come to an end", 18],
	["You broke our little deal", 19.8], ["And I can't let that slide", 22.3], ["", 24.2], ["And", 25],
	["You fell right", 25.7], ["Into my hands", 26.7], ["Thinking your path was clear", 28], ["The goalpost in sight", 29.9], ["But no", 31.6], ["", 32.8],

	["Tell me", 33.7], ["Do you know what", 34.7], ["All of the creatures", 35.3], ["Down there have in common?", 36.1],
	["They're all in my game", 38.5], ["They all", 41.1], ["Belong", 42.3], ["To me", 43.5],

	["YOU CANNOT UNDO", 45.7], ["WHAT HAS BEEN STARTED", 47.6], ["YOUR FATE WAS SET", 50], ["IN MOTION THE MOMENT", 51.6], ["YOU LAID EYES", 53], ["ON THAT LITTLE CARTRIDGE", 53.9],
	["THE BOTH OF YOU", 56.5], ["ARE MY PLAYTHINGS NOW", 57.4], ["AND WE'RE GOING TO HAVE", 59.5], ["SO MUCH FUN!!!", 61], ["", 63.6],

	["Come and face me", 65], ["Little rat", 67], ["Your time has come", 68.5], ["", 71.4], ["", 72.4]
	];
	public function new()
		{
			//MUCHO NUMEROOOOOOOOOOOOOOOOOO
		}
									//direccion a la que va //mundo
	public static function getCoords(nextPos:Int, curWorld:Float):Array<Float>
	{
		var x:Float = 0;
		var y:Float = 0;
		var theY:Array<Float> = [0];
		var theX:Array<Float> = [0];

		switch(curWorld){
			case 0:
				theY = [251, 251, 251, 251, 251, 251];
				theX = [400, 496, 592, 688, 784, 880];

			case 1:
				theX = [493, 493, 676, 676];
				theY = [218, 359, 359, 232];
			case 2:
				theX = [316, 412, 556, 556, 556, 673, 760, 760];
				theY = [294, 294, 201, 114, 394, 471, 324, 176];

			case 3:
				theX = [595, 448, 754, 835, 598, 361];
				theY = [285, 465, 465, 231, 114, 231];

			case 4:
				theX = [593, 593, 593, 377, 281, 905, 593, 593]; 
				theY = [456, 390, 270, 171, -18, -46, 126,-117];

			case 5:
				theX = [598, 598, 598, 598];
				theY = [600, 399, 188, -21];
		}

		var thecoords:Array<Float> = [theX[nextPos], theY[nextPos]];

		return thecoords;
	}
	public static function animStart(nextDir:Int, lastDir:Float, curWorld:Float, pibe:FlxSprite, iswalk:Bool):Void
		{
			var coords:Array<Float> = getCoords(nextDir, curWorld);
			var x:Float = coords[0];
			var y:Float = coords[1];
			var anim:Int = 0;

			var theTweenX:FlxTween;
			var theTweenY:FlxTween;

			switch(curWorld){

				case 0: //!WORLD 0
					theTweenX = FlxTween.tween(pibe, {x: x}, 0.8);
				
				case 1: //!WORLD 1
				switch(nextDir){
					case 0:
						WarpState.time = 1.4;
						theTweenX = FlxTween.tween(pibe, {x: x}, WarpState.time);
						theTweenY = FlxTween.tween(pibe, {y: y}, WarpState.time);
					case 1:
						WarpState.time = 1.4;
						if(lastDir == 2) WarpState.time = 1.6;
						theTweenX = FlxTween.tween(pibe, {x: x}, WarpState.time);
						theTweenY = FlxTween.tween(pibe, {y: y}, WarpState.time);
					case 2:
						WarpState.time = 1.6;
						if(lastDir == 3) WarpState.time = 1.2;
						theTweenX = FlxTween.tween(pibe, {x: x}, WarpState.time);
						theTweenY = FlxTween.tween(pibe, {y: y}, WarpState.time);
					case 3:
						WarpState.time = 1.2;
						theTweenX = FlxTween.tween(pibe, {x: x}, WarpState.time);
						theTweenY = FlxTween.tween(pibe, {y: y}, WarpState.time);
				}

				case 2: //!WORLD 2
					switch(nextDir){
						case 0:
							WarpState.time = 1;
							theTweenX = FlxTween.tween(pibe, {x: 316}, 1);
							theTweenY = FlxTween.tween(pibe, {y: 294}, 1);

						case 1:
							switch(lastDir){
								case 0:
									WarpState.time = 1;
									theTweenX = FlxTween.tween(pibe, {x: x}, 1);
									theTweenY = FlxTween.tween(pibe, {y: y}, 1);
								case 2:
									WarpState.time = 2.2;
									theTweenX = FlxTween.tween(pibe, {x: x}, 1.4, {onComplete: function(twn:FlxTween){pibe.animation.play('down');}});
									theTweenY = FlxTween.tween(pibe, {y: y}, 1.2, {startDelay: 1});

								case 4:
									WarpState.time = 2.2;
									theTweenX = FlxTween.tween(pibe, {x: x}, 1.4, {onComplete: function(twn:FlxTween){pibe.animation.play('up');}});
									theTweenY = FlxTween.tween(pibe, {y: y}, 1.2, {startDelay: 1});
							}

						case 2:

							switch(lastDir){
								case 1:
									WarpState.time = 2.2;
									theTweenX = FlxTween.tween(pibe, {x: x}, 1.4, {startDelay: 0.8});
									theTweenY = FlxTween.tween(pibe, {y: y}, 1.2, {onComplete: function(twn:FlxTween){pibe.animation.play('right');}});

								case 3:
									WarpState.time = 1;
									theTweenX = FlxTween.tween(pibe, {x: x}, 1);
									theTweenY = FlxTween.tween(pibe, {y: y}, 1);
									
								case 4:
									WarpState.time = 1.7;
									theTweenX = FlxTween.tween(pibe, {x: x}, 1);
									theTweenY = FlxTween.tween(pibe, {y: y}, 1.7);
							}

						case 3:
							WarpState.time = 1;
							theTweenX = FlxTween.tween(pibe, {x: x}, 1);
							theTweenY = FlxTween.tween(pibe, {y: y}, 1);

						case 4:
							switch(lastDir){
								case 1:
									WarpState.time = 2.2;
									theTweenX = FlxTween.tween(pibe, {x: x}, 1.4, {startDelay: 0.8});
									theTweenY = FlxTween.tween(pibe, {y: y}, 1.2, {onComplete: function(twn:FlxTween){pibe.animation.play('right');}});

								case 2:
									WarpState.time = 1.7;
									theTweenX = FlxTween.tween(pibe, {x: x}, 1);
									theTweenY = FlxTween.tween(pibe, {y: y}, 1.7);

								case 5:
									WarpState.time = 1.75;
									theTweenX = FlxTween.tween(pibe, {x: x}, 1, {onComplete: function(twn:FlxTween){pibe.animation.play('up');}});
									theTweenY = FlxTween.tween(pibe, {y: y}, 0.8, {startDelay: 0.95});
							}

						case 5:

							switch(lastDir){
								case 4:
								WarpState.time = 1.75;

								theTweenX = FlxTween.tween(pibe, {x: x}, 1, {startDelay: 0.75});
								theTweenY = FlxTween.tween(pibe, {y: y}, 0.8, {onComplete: function(twn:FlxTween){pibe.animation.play('right');}});
								case 6:
									WarpState.time = 2.2;

									theTweenX = FlxTween.tween(pibe, {x: x}, 1, {startDelay: 1.2});
									theTweenY = FlxTween.tween(pibe, {y: y}, 1.7, {onComplete: function(twn:FlxTween){pibe.animation.play('left');}});
							}

						case 6:

							switch(lastDir){
								case 7:
								WarpState.time = 1.4;
								theTweenY = FlxTween.tween(pibe, {y: y}, 1.4);

								case 5:
								WarpState.time = 2.2;
								theTweenX = FlxTween.tween(pibe, {x: x}, 1, {onComplete: function(twn:FlxTween){pibe.animation.play('up');}});
								theTweenY = FlxTween.tween(pibe, {y: y}, 1.7, {startDelay: 0.5});
							}

						case 7:
							WarpState.time = 1.4;
							theTweenX = FlxTween.tween(pibe, {x: x}, 1);
							theTweenY = FlxTween.tween(pibe, {y: y}, 1.4);
					}

				case 3: //!WORLD 3
					switch(nextDir){
						case 0:
							WarpState.time = 2.8;
							pibe.animation.play('left');
							theTweenX = FlxTween.tween(pibe, {x: 403}, 0.3, {onComplete: function(twn:FlxTween)
								{
									pibe.animation.play('up');
									FlxTween.tween(pibe, {x: 469}, 1.3, {onComplete: function(twn:FlxTween)
										{
											FlxTween.tween(pibe, {x: x}, 1.2);
										}});
								}});
							theTweenY = FlxTween.tween(pibe, {y: 447}, 0.3, {onComplete: function(twn:FlxTween)
								{
									FlxTween.tween(pibe, {y: 306}, 1.3, {onComplete: function(twn:FlxTween)
										{
											pibe.animation.play('right');
											FlxTween.tween(pibe, {y: y}, 1.2);
										}});
								}});
						case 1:
							switch(lastDir){
								case 0:
									WarpState.time = 3.1;
									theTweenX = FlxTween.tween(pibe, {x: 469}, 1.2, {onComplete: function(twn:FlxTween)
										{
											pibe.animation.play('down');
											FlxTween.tween(pibe, {x: 403}, 1.1, {onComplete: function(twn:FlxTween)
												{
													FlxTween.tween(pibe, {x: x}, 0.6, {startDelay: 0.2});
												}});
										}});
									theTweenY = FlxTween.tween(pibe, {y: 306}, 1.2, {onComplete: function(twn:FlxTween)
										{
											FlxTween.tween(pibe, {y: 447}, 1.3, {onComplete: function(twn:FlxTween)
												{
													pibe.animation.play('right');
													FlxTween.tween(pibe, {y: y}, 0.6);
												}});
										}});
								case 2:
									WarpState.time = 2.4;
									theTweenX = FlxTween.tween(pibe, {x: x}, 2.4);
									theTweenY = FlxTween.tween(pibe, {y: 492}, 0.3, {startDelay: 0.2, onComplete: function(twn:FlxTween)
										{
											FlxTween.tween(pibe, {y: y}, 0.3, {startDelay: 1.4});
										}});
							}
						case 2:
							switch(lastDir){
								case 1:
									WarpState.time = 2.4;
									theTweenX = FlxTween.tween(pibe, {x: x}, 2.4);
									theTweenY = FlxTween.tween(pibe, {y: 492}, 0.3, {startDelay: 0.2, onComplete: function(twn:FlxTween)
										{
											FlxTween.tween(pibe, {y: y}, 0.3, {startDelay: 1.4});
										}});

								case 3:
									WarpState.time = 1.8;
									pibe.animation.play('left');
									theTweenY = FlxTween.tween(pibe, {y: pibe.y}, 0.2, {onComplete: function(twn:FlxTween){
										FlxTween.tween(pibe, {y: y}, 1.6);
										pibe.animation.play('down');
									}});

									theTweenX = FlxTween.tween(pibe, {x: 739}, 1.6, {onComplete: function(twn:FlxTween)
										{
											FlxTween.tween(pibe, {x: x}, 0.2);
											pibe.animation.play('right');
										}});
							}
						case 3:
							switch(lastDir){
								case 2:
									WarpState.time = 2.8;
									pibe.animation.play('left');
									theTweenY = FlxTween.tween(pibe, {y: y}, 2, {startDelay: 0.2, onComplete: function(twn:FlxTween){pibe.animation.play('right');}});
									theTweenX = FlxTween.tween(pibe, {x: 739}, 0.2, {onComplete: function(twn:FlxTween)
										{
											pibe.animation.play('up');
											FlxTween.tween(pibe, {x: x}, 2.4, {startDelay: 0.2});
										}});

								case 4: // 790, 213   703, 138    622, 138
								WarpState.time = 2.2;
								theTweenX = FlxTween.tween(pibe, {x: 625}, 0.2, {onComplete: function(twn:FlxTween)
									{
										FlxTween.tween(pibe, {x: x}, 2);
									}});
								theTweenY = FlxTween.tween(pibe, {y: 132}, 0.2, {onComplete: function(twn:FlxTween)
									{
										pibe.animation.play('right');
										FlxTween.tween(pibe, {y: y}, 0.8, {startDelay: 0.8});
									}});
							}
						case 4:
							switch(lastDir){
								case 3:
								WarpState.time = 2.7;
								theTweenX = FlxTween.tween(pibe, {x: 790}, 0.3, {onComplete: function(twn:FlxTween)
									{
										pibe.animation.play('up');
										FlxTween.tween(pibe, {x: 622}, 2, {onComplete: function(twn:FlxTween)
											{
														pibe.animation.play('up');
														FlxTween.tween(pibe, {x: x}, 0.4);
											}});
									}});
								theTweenY = FlxTween.tween(pibe, {y: 213}, 0.3, {onComplete: function(twn:FlxTween)
									{
										FlxTween.tween(pibe, {y: 138}, 0.8, {onComplete: function(twn:FlxTween)
											{

												pibe.animation.play('left');
												FlxTween.tween(pibe, {y: y}, 0.4, {startDelay: 1.2});
											}});
									}});

								case 5:
									WarpState.time = 2.7;
									theTweenX = FlxTween.tween(pibe, {x: 409}, 0.3, {onComplete: function(twn:FlxTween)
										{
											FlxTween.tween(pibe, {x: 571}, 2, {onComplete: function(twn:FlxTween)
												{
													FlxTween.tween(pibe, {x: x}, 0.4);
												}});
										}});
										
									theTweenY = FlxTween.tween(pibe, {y: 213}, 0.3, {onComplete: function(twn:FlxTween)
										{
											pibe.animation.play('up');
											FlxTween.tween(pibe, {y: 135}, 0.8, {onComplete: function(twn:FlxTween)
												{
													pibe.animation.play('right');
													FlxTween.tween(pibe, {y: y}, 0.4, {startDelay: 1.2});
												}});
										}});
							}
						case 5:

							switch(lastDir){
								case 4:
								WarpState.time = 2.25;
								theTweenX = FlxTween.tween(pibe, {x: 556}, 0.3, {onComplete: function(twn:FlxTween)
									{
										pibe.animation.play('left');
										FlxTween.tween(pibe, {x: 403}, 1.4, {onComplete: function(twn:FlxTween)
											{
												FlxTween.tween(pibe, {x: x}, 0.4);
											}});
									}});

								theTweenY = FlxTween.tween(pibe, {y: 138}, 0.3, {onComplete: function(twn:FlxTween)
									{
										FlxTween.tween(pibe, {y: 216}, 0.8, {startDelay: 0.65, onComplete: function(twn:FlxTween)
											{

												FlxTween.tween(pibe, {y: y}, 0.4, {startDelay: 0.1});
											}});
									}});
							}
				
					}
				
				case 4: //!WORLD 4
					switch(nextDir){
						case 0:
							switch(lastDir){
								case 1:
									WarpState.time = 0.6;

								case 2:
									WarpState.time = 1.6;
							}
						theTweenY = FlxTween.tween(pibe, {y: y}, WarpState.time);
						case 1:
							switch(lastDir){
								case 0:
									WarpState.time = 0.6;
								case 2:
									WarpState.time = 1.1;
							}
						theTweenY = FlxTween.tween(pibe, {y: y}, WarpState.time);
						case 2:
							switch(lastDir){
								case 1:
									WarpState.time = 1.1;
									theTweenY = FlxTween.tween(pibe, {y: y}, WarpState.time);
								case 0:
									WarpState.time = 1.6;
									theTweenY = FlxTween.tween(pibe, {y: y}, WarpState.time);
								case 3:
									WarpState.time = 2.7;
									theTweenX = FlxTween.tween(pibe, {x: x}, 2, {startDelay: 0.7});
									theTweenY = FlxTween.tween(pibe, {y: y}, 1, {onComplete: function(twn:FlxTween)
										{
											pibe.animation.play('right');
										}});
								case 5:
									WarpState.time = 5;
									theTweenX = FlxTween.tween(pibe, {x: 905}, 0.4, {onComplete: function(twn:FlxTween)
										{
											pibe.animation.play('climb');
											theTweenX = FlxTween.tween(pibe, {x: 905}, 1.4, {onComplete: function(twn:FlxTween)
												{
													theTweenX = FlxTween.tween(pibe, {x: x}, 2.5, {startDelay: 0.7});
													pibe.animation.play('down');
												}});
										}});
									theTweenY = FlxTween.tween(pibe, {y: y}, 2.5, {onComplete: function(twn:FlxTween)
										{
											pibe.animation.play('left');
										}});
								case 6:
									WarpState.time = 1.4;
									theTweenY = FlxTween.tween(pibe, {y: y}, WarpState.time);
							}
						case 3:
							switch(lastDir){
								case 2:
									WarpState.time = 2.8;
									theTweenX = FlxTween.tween(pibe, {x: x}, 2.2, {onComplete: function(twn:FlxTween)
										{
											pibe.animation.play('up');
										}});
									theTweenY = FlxTween.tween(pibe, {y: y}, 1, {startDelay: 1.8});
								case 4:
									WarpState.time = 2.2;
									theTweenX = FlxTween.tween(pibe, {x: pibe.x}, 0.4, {onComplete: function(twn:FlxTween)
										{
											pibe.animation.play('climb');
											
											theTweenX = FlxTween.tween(pibe, {x: pibe.x}, 0.7, {onComplete: function(twn:FlxTween)
											{
												pibe.animation.play('down');
												theTweenX = FlxTween.tween(pibe, {x: x}, 1, {startDelay: 0.1});
											}});
										}});
									theTweenY = FlxTween.tween(pibe, {y: y}, 1.5, {onComplete: function(twn:FlxTween)
										{
											pibe.animation.play('right');
										}});
							}
						
						case 4:
							WarpState.time = 2.2;
							theTweenX = FlxTween.tween(pibe, {x: x}, 1, {onComplete: function(twn:FlxTween)
								{
									pibe.animation.play('up');
									
									theTweenX = FlxTween.tween(pibe, {x: x}, 0.1, {onComplete: function(twn:FlxTween)
									{
										pibe.animation.play('climb');
										theTweenX = FlxTween.tween(pibe, {x: x}, 0.8, {onComplete: function(twn:FlxTween)
											{
												pibe.animation.play('up');		
											}});
									}});
								}});
							theTweenY = FlxTween.tween(pibe, {y: y}, 1.5, {startDelay: 0.7}); 

						case 5:
							WarpState.time = 5;
							theTweenX = FlxTween.tween(pibe, {x: x}, 2.5, {onComplete: function(twn:FlxTween)
								{
									pibe.animation.play('up');
									theTweenX = FlxTween.tween(pibe, {x: x}, 0.7, {onComplete: function(twn:FlxTween)
										{
											pibe.animation.play('climb');
											theTweenX = FlxTween.tween(pibe, {x: x}, 1.4, {onComplete: function(twn:FlxTween)
												{
													pibe.animation.play('up');
												}});
										}});
									
								}});
							theTweenY = FlxTween.tween(pibe, {y: y}, 2.5, {startDelay: 2.5});

						case 7:
							WarpState.time = 2.2;
							theTweenX = FlxTween.tween(pibe, {x: x}, 0.15, {onComplete: function(twn:FlxTween)
								{
									pibe.animation.play('climb');
									theTweenX = FlxTween.tween(pibe, {x: x}, 1.7, {onComplete: function(twn:FlxTween)
										{
											pibe.animation.play('up');
										}});
								}});
							theTweenY = FlxTween.tween(pibe, {y: y}, WarpState.time);

						case 6:
							WarpState.time = 1.4;
							switch(lastDir){
								case 7:
									WarpState.time = 2.2;
									theTweenX = FlxTween.tween(pibe, {x: x}, 0.35, {onComplete: function(twn:FlxTween)
										{
											pibe.animation.play('climb');
											theTweenX = FlxTween.tween(pibe, {x: x}, 1.7, {onComplete: function(twn:FlxTween)
												{
													pibe.animation.play('down');
												}});
										}});
									theTweenY = FlxTween.tween(pibe, {y: y}, WarpState.time);
								case 2:
									WarpState.time = 1.4;
									theTweenY = FlxTween.tween(pibe, {y: y}, WarpState.time);
									theTweenX = FlxTween.tween(pibe, {x: x}, WarpState.time);
							}
							
						default:
							WarpState.time = 1.4;
							theTweenY = FlxTween.tween(pibe, {y: y}, WarpState.time);
							theTweenX = FlxTween.tween(pibe, {x: x}, WarpState.time);
					}
				
				case 5: //!WORLD 5
					switch(nextDir){
						case 2:
							WarpState.time = 1.8;
							if(lastDir == 3) WarpState.time = 1.5;
						case 3:
							WarpState.time = 1.5;
						default:
							WarpState.time = 1.8;
					}
					theTweenY = FlxTween.tween(pibe, {y: y}, WarpState.time);
				}
		}

		public static function getWorld(bonnie:Float):Array<Dynamic>{

			var elcausa:Array<Dynamic> = ['pekratos'];

						// Name, 			UP, DOWN, LEFT, RIGHT, Unlock Number
			switch(bonnie){
				case 1:
					elcausa = [		
						['Start', 							'X', '1', 'X', 'x', 0],
						['So Cool',							'0', 'X', 'X', '2', 0],
						['Nourishing Blood', 				'3', 'X', '1', 'X', 1],
						['MARIO SING AND GAME RYTHM 9', 	'X', '2', 'X', 'X', 2]
						];

				case 2:
					elcausa = [
						['Start', 			'X', 'X', 'X', '1', 0],
						['Alone', 			'2', '4', '0', 'X', 0],
						['Oh God No', 		'3', '4', '1', 'X', 1],
						['I Hate You', 		'X', '2', 'X', 'X', 2],
						['Thalassophobia', 	'2', '5', '1', 'X', 1],
						['Apparition', 		'X', 'X', '4', '6', 4],
						['Last Course', 	'7', '5', 'X', 'X', 5],
						['Dark Forest', 	'X', '6', 'X', 'X', 6]
						];

				case 3:
					elcausa = [
						['Start', 			'X', 'X', '1', 'X', 0],
						['Bad Day', 		'0', 'X', 'X', '2', 0],
						['Day Out', 		'3', 'X', '1', 'X', 1],
						['Dictator', 		'X', '2', '4', 'X', 2],
						['RaceTraitors', 	'X', 'X', '5', '3', 3],
						['No Hope', 		'X', 'X', 'X', '4', 4]
						];

				case 4:
					elcausa = [		
						['Start', 			'2', 'X', 'X', 'X', 0],
						['Unbeatable',	 	'2', '0', 'X', 'X', 0],
						['Golden Land', 	'6', '0', '3', '5', 1],
						['Paranoia',	 	'X', '2', '4', 'X', 2],
						['Overdue', 		'X', '3', 'X', 'X', 3],
						['No Party', 		'X', '2', 'X', 'X', 2],
						['Powerdown', 		'7', '2', 'X', 'X', 4],
						['Demise',	 		'X', '6', 'X', 'X', 5]
						];
					if(ClientPrefs.storySave[7]){ //cambia este valor con el guardado q indique que terminaste all stars
						elcausa[0][1] = '1';
						elcausa[2][2] = '1';
					}else if(ClientPrefs.worlds[3] == 0){
						elcausa[0][1] = '1';
					}

				case 5:
					elcausa = [		
						['Start', 			'1', 'X', 'X', 'X', 0],
						['Promotion', 		'2', '0', 'X', 'X', 0],
						['Abandoned', 		'3', '1', 'X', 'X', 1],
						['The End', 		'X', '2', 'X', 'X', 2]
						];
					
			}

			return elcausa;
		}

		public static function getPos(foxy:Float):Array<Dynamic>{

			var elboludo:Array<Dynamic> = ['pekratos'];

			switch(foxy){
				case 1:
					elboludo = [	
						['star', 	525, 280],
						['dot', 	531, 428],
						['none', 	0, 0],
						['ring', 	697, 237]
						];

				case 2:
					elboludo = [
						['star', 	345, 356],
						['dot', 	450, 363],
						['none', 	  0,   0],
						['castle', 	588, 158],
						['dot', 	593, 463],
						['dot', 	711, 540],
						['dot', 	798, 393],
						['big', 	794, 241]
						];

				case 3:
					elboludo = [
						['star', 	627, 344],
						['dot', 	486, 534],
						['dot', 	792, 534],
						['dot', 	873, 300],
						['dot', 	636, 183],
						['dot', 	399, 300]
						];

				case 4:
					elboludo = [		
						['star', 	625,	512],
						['dot', 	631, 	462],
						['dotgb', 	627, 	335],
						['dot', 	415, 	243],
						['dot', 	319, 	51],
						['big', 	939, 	22],
						['castle', 	624, 	194],
						['pipe', 	625, 	-52]
						];

				case 5:
					elboludo = [		
						['star', 	630, 656],
						['dot', 	636, 471],
						['dot', 	636, 260],
						['big', 	632, 46]
						];
					
			}

			return elboludo;
		}

		public static function pathPos(chica:Int, goldennextDir:String):Float{

			var farfadox:Float = 0;
			var nextX:Array<Dynamic> = [[0, 0], [605, 323], [496, 281], [512, 225], [465, 100], [618, 223]];
			
			if(goldennextDir == 'X') return nextX[chica][0];
			return nextX[chica][1];
		}
										//world,		number unlocked,	ALT number unlocked
		public static function callSmoke(springtrap:Float, mangle:Float, puppet:String = 'X'):Array<Dynamic>{
			var elpana:Array<Dynamic> = ['pekratos'];
				//basicamente le das los datos de cual camino desbloqueaste y luego te da la cantidad de sprites y su posicion // EL NUMERO GRACIOSO: 48

				//0:Arriba 1:Abajo 2:Izquierda 3:Derecha // 4:ArribaIzq 5:ArribaDer 6:AbajoIzq 7:AbajoDer
				switch(springtrap){
					case 1:
						switch(mangle){
							case 1:
								elpana = [567, 421, 3, 3, 3];
							case 2:
								elpana = [708, 368, 0, 4, 1, 5, 7, 0];
						}
					case 2:
						switch(mangle){
							case 1:
								elpana = [537, 260, 3, 1, 1, 1, 1, 2];
							case 2:
								elpana = [588, 161, 1];
							case 4:
								elpana = [588, 488, 1, 3, 3, 3];
							case 5:
								elpana = [792, 386, 1, 1, 6];
							case 6:
								elpana = [792, 239, 1, 1];
						}

					case 3:
						switch(mangle){
							case 1:
								elpana = [546, 545, 3, 3, 3, 3, 3];
							case 2:
								elpana = [774, 485, 0, 5, 0, 5];
							case 3:
								elpana = [816, 269, 4, 4, 1, 4, 2];
							case 4:
								elpana = [570, 197, 2, 2, 1, 6, 2];
						}

					case 4:
						switch(mangle){
							case 2:
								elpana = [937, -12, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 0, 0];
							case 3:
								elpana = [313, 44, 1, 1, 1, 1, 3];
							case 4:
								elpana = [601, 188, 1, 1, 1, 3, 0, 0, 0];
							case 5:
								elpana = [598, 155, 0, 0, 0, 0, 3, 1, 1, 1, 1];
						}

					case 5:
						switch(mangle){
							case 1:
								elpana = [630, 422, 0, 0, 0, 0];
							case 2:
								elpana = [648, 215, 0, 0, 0, 0, 2, 1, 1, 1, 1];
						}
				}


			return elpana;
		}
}