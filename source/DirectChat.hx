package;

import flixel.FlxG;
import haxe.Json;
import lime.utils.Assets;

using StringTools;

#if sys
import sys.FileSystem;
import sys.io.File;
#end

class DirectChat
{
	public static var chatText:String = '';
	public static var chatLong:String = '';
	public static var chatArray:Array<String> = ['', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''];
	public static var chosenUsername:String = '';
	public static var chosenMessage:String = '';
	public static var finalchat:String = '';
	public static var cantidad:Int = 0;
	public static var tooLong:Bool = false;

	public function new()
	{
		//no me preguntan ni una verga de este codigo porq ni yo se como lo hice funcionar en un hx aparte
	}

	public static function reset()
	{
		chatArray = ['', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''];
	}

	public static function addMessage()
	{
		if (!tooLong){
			var messages:Array<String> = [
				'what about gd',
				'mid',
				'will you play fnaf later?',
				'yooo mario',
				'alr',
				'ITS MARIO OMG',
				'lmao',
				'LMAOOOO',
				'what',
				'l',
				'w',
				'no way',
				'can you play oddysey?',
				'what happened to miyamoto',
				'is that mario',
				'is the guy from marvel',
				'is the guy from marvel?',
				'is the guy from marvel!',
				'are you the guy from fnf?',
				'salami',
				'this is great',
				'oh',
				'woo banger',
				'this shit straight fire',
				'BROOO????',
				'hi boyfriend',
				'its a me',
				'love this man',
				'thats cool',
				'he looks like markiplier',
				'so cool',
				'how',
				'Yeaaaa',
				'hi',
				'WTF Chris Pratt?',
				'what about charles',
				'this movie is gonna suck',
				'ew illumination',
				'what the fuck',
				'WHAAAAAAAAAT',
				'no fucking way',
				'what is nintendo thinking',
				'i wonder who luigi is?',
				'bruh',
				'hi',
				'i was here',
				'ratio',
				'you fell off',
				'hi youtube',
				'is that your gf in the bg?',
				'bro ur gf is hot',
				'bro ur gf is ugly',
				'fuck you leaker',
				'sonic.exe is better',
				'will you rap battle me plz',
				'someone gift me a sub plz',
				'someone give me money plz',
				'fight me bro',
				'i lov pstasa nigh',
				'oh look a free ipad',
				'ca n I be in the chat....',
				'the g',
				'ola causa',
				'there should be an fnf mod of this',
				'me when fnf',
				'cry about it',
				'y es todo un tema viste',
				'ojo',
				'I love Balloon Boy',
				'XD',
				'couch potato',
				'have you ever wanted movies free',
				'this is the story of a girl',
				'brown bricks',
				'let me tell you a sad story',
				'6 piece chicken nuggets',
				'McFlurry',
				'Sus ojos le sangraban...',
				'bring on tha thunda',
				'hop on among us cuz',
				'sussy facecam',
				'los dioses de mi causa me han abandonado',
				'hippopotomonstrosesquippedaliophobia',
				'deez nuts',
				"bro thinks he's mario",
				'[message deleted by moderator]',
				'[message deleted by moderator]',
				'[message deleted by moderator]',
				'this shit STIIIIINKS',
				'Fue mi pene',
				'last message',
				'shithead',
				'hey BF how do you say flan',
				'He looks like Theodore the Chipmunk',
				'This is like a wario take on remember the alamo',
				'PISS FAT???',
				'this is so gangster holy shit',
				'so no smash?',
				'Can you play GD?',
				'This sucks, next song',
				'Dude, I know this is unrelated, but I need your help right now.',
				'Wanna become famous? Buy followers, at bigfollows.com!',
				'Gushers',
				'unfortunately, ratio',
				'Galápagos Tortoise',
				'gracias a dios que es viernes',
				'Hes so cool...',
				'This is going to be a disaster',
				'are we getting a Chris Pratt amiibo?',
				'Can you play fortnite?',
				'They should add chris pratt to fortnite',
				'PILGRIM SPONGEBOB???',
				'whens twinsanity',
				'is chris pratt a duende?',
				'this has to be a joke',
				'reggie would be rolling in his grave rn',
				'wtf',
				'aint no way',
				'oh goodness gracious',
				'mid march?',
				'shouldve been adam sandler tbh',
				'Its a BAD day for mario',
				'yeah this is fucked',
				'can you play desert bus next?',
				'get a load of this guy',
				'MY MARIO?!? THEY TOOK HIM!!!!',
				'is that christian bale from star wars?',
				'vaya mierda',
				'want robux? visit FREEROBUX.COM and become a MILLIONARE !',
				'yeah man',
				'midlicious',
				'Lol, lmao even',
				'oh, thats chris pratt',
				'I love these beans',
				'MOM GET THE PS5',
				'me rio?'
			];
			
			var usernames:Array<String> = [
				'Bleakim',
				'BootMunde',
				'CatAlone',
				'Cooledia',
				'DanceRocker',
				'Ellacens',
				'EnergyHan',
				'Giglobus',
				'GlimmerAut',
				'Guantonk',
				'Hacksale',
				'Jinom',
				'Kavenix',
				'LastingBorg',
				'NotesGlory',
				'Teal',
				'Sun',
				'Poolis',
				'Raptw',
				'Sexylo',
				'Sistergy',
				'Sowf',
				'Specism',
				'Sticomyl',
				'StoopFamous',
				'Tallyda',
				'Terreve',
				'Thebesten',
				'Vitexce',
				'VodForum',
				'WakeboardBox',
				'Zippoix',
				'zxppy',
				'candel',
				'fnaffreddy',
				'GP',
				'Red',
				'lemonaid2',
				'Magik',
				'StrawDeutch',
				'NateTDOM',
				'theWAHbox',
				'PepeMago',
				'Chad',
				'fishlips77',
				'justbruh',
				'BestEnd',
				'sharlet',
				'Gerardo',
				'mikhobb',
				'CaptCake',
				'Colacapn',
				'lillypad',
				'Zendraynix',
				'wyvernGoddess',
				'paradiseEvan',
				'manmakestick',
				'blueknight250',
				'fivein_',
				'CoreCombatant',
				'shapperoni',
				'maxinoise',
				'A_vacuum',
				'ewademar',
				'buttnugget',
				'nugass',
				'lordbossmaster',
				'artugamerpro99',
				'byelion',
				'friedfrick',
				'friedrick',
				'fredrick',
				'MXgaming',
				'kingf0x',
				'MundMashup',
				'Gadget',
				'MikeMatei',
				'sponge',
				'Super Johnsons',
				'Smellvin',
				'Beefrunkle',
				'Faro',
				'doug',
				'C0mix_Z0ne',
				'StingaFlinn',
				'OpillaBowd',
				'AwesomeHuggyWuggy',
				'Reki',
				'PaulFart',
				'Zeroh',
				'GamesCage',
				'Soup',
				'MetalFingers',
				'MetalFace',
				'Zeurel',
				'Lythero',
				'IheartJustice',
				'JCJack',
				'Ironik',
				'Sturm',
				'ChurgneyGurgney',
				'Jerma985',
				'DougDoug',
				'Chris Snack',
				'Duende',
				'CasualCaden',
				'BadArseJones',
				'marmot',
				'BeegYoshi',
				'Sandi',
				'johnsonVMUleaker',
				'weedeet',
				'HaroldGlover902',
				'Griog',
				'The_Beast',
				'Zebo',
				'BelowNatural',
				'FreddyFreaker',
				'Marquitoswin',
				'DastardlyDeacon',
				'VibingLeaf',
				'RedTv53',
				'VanScotch',
				'haywireghost',
				'Persona_Random',
				'tia_Marie',
				//ones below here have special messages for their names
				
				'Joe_Biden',
				'Ney',
				'turmoil',
				'care',
				'mx',
				'saster',
				'evil mario',
				'wega',
				'winniethepooh',
				'moldy mario',
				'mr.l',
				'useraqua',
				'EllisBros',
				'Dave',
				'JackBlack',
				'Vania',
				'scrumbo_',
				'Linkara',
				'mark',
				'Fernanfloo',
				'Vargskelethor',
				'MrDink',
				'FatAlbert',
				'Hermanoquebasto',
				'Clue_Buddy',
				'anderson043',
				'Robotnik',
				'ElRubisOMG',
				'Walter_White',
				'Ganon',
				'Joker',
				'Super Wario Man',
				'WhiteyDvl',
				'misterSYS'
			];


			var usercolor:Int = FlxG.random.int(1, 5);
			var tagcolor:String = '';

			switch(usercolor){
				case 1:
					tagcolor = '$';
				case 2:
					tagcolor = '#';
				case 3:
					tagcolor = '%';
				case 4:
					tagcolor = '&';
				case 5:
					tagcolor = ';';
			}

			chosenMessage = messages[FlxG.random.int(0, messages.length - 1)];
			chosenUsername = usernames[FlxG.random.int(0, usernames.length - 1)];
			
			switch (chosenUsername){
				case 'saster':
					chosenMessage = "hi guys, i'm saster";

				case 'turmoil':
					if (FlxG.random.bool(50))
						chosenMessage = "i'm hungry";

				case 'mx':
					if (FlxG.random.bool(50))
						chosenMessage = "innocence doesn't get you far";
					else
						chosenMessage = "lucas...";

				case 'evil mario':
					chosenMessage = "Mario hates you very much";

				case 'moldy mario':
					if (FlxG.random.bool(50))
						chosenMessage = "i am trapped in your sewer";
					else
						chosenMessage = "help me charlie";

				case 'wega':
					chosenMessage = "BAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHHHHH";
					
				case 'winniethepooh':
					if (FlxG.random.bool(50))
						chosenMessage = "oh b(r)other";
					else
						chosenMessage = "i'm winnie the pooh";
					
				case 'mr.l':
					if (FlxG.random.bool(50))
						chosenMessage = "it's too late";
					else
						chosenMessage = "L-ater";

				case 'JackBlack':
					if (FlxG.random.bool(50))
						chosenMessage = "FUCK YOU! YOU FUCKIN' DICK";
					else
						chosenMessage = "octagon is an amazing shape that has 8 fantastic sides and 8 awesome angles";

				case 'Vania':
					chosenMessage = "sure, why not?";

				case 'scrumbo_':
					chosenMessage = "We're Straight Up Evil, FeelMasters";

				case 'useraqua':
					if (FlxG.random.bool(50))
						chosenMessage = "holy sweet mother of pibby";
					else
						chosenMessage = "salvage solos this trash";

				case 'EllisBros':
					chosenMessage = "You thought Miyamoto worked alone?";
				
				case 'Dave':
					chosenMessage = "Good fuckin' stream, old sport!";

				case 'Ney':
					if (FlxG.random.bool(50))
						chosenMessage = "This isn't the video to get free V-Bucks";
					else
						chosenMessage = "NO WAY! It's Piss Chratt!";

				case 'Linkara':
					if (FlxG.random.bool(50))
						chosenMessage = "If its you or the worms I pick the worms every time";
					else
						chosenMessage = "I am the light bringer!";

				case 'Fernanfloo':
					chosenMessage = "Chorizo";

				case 'Vargskelethor':
					chosenMessage = "the jurassic park guy???";

				case 'MrDink':
					chosenMessage = "YOU BROKE MY GRILL?!?";

				case 'FatAlbert':
					chosenMessage = "Oh no I'm late to work hurhurhur";
				
				case 'mark':
					switch (FlxG.random.int(1,3)){
						case 1:
							chosenMessage = "Do you want to touch my shiny bald head?";
						case 2:
							chosenMessage = "Come on, Mark with me!";
						case 3:
							chosenMessage = "mark you next time";
					}
				
				case 'Hermanoquebasto':
					chosenMessage = "Pensabas que estaba muerto no? pues no, no lo estaba!";
				
				case 'Clue_Buddy':
					chosenMessage = "Get a clue, buddy!";

				case 'anderson043':
					chosenMessage = "no ve er nota este";

				case 'Robotnik':
					chosenMessage = "SNOOPINGas usual I see!";

				case 'ElRubisOMG':
					chosenMessage = "pero esto que es chaval tio que cojones";

				case 'Walter_White':
					if (FlxG.random.bool(50))
						chosenMessage = "We need to COOK";
					else
						chosenMessage = "I AM the one who knocks";

				case 'Ganon':
					chosenMessage = "You dare bring light to my lair!? YOU MUST DIE!";

				case 'Joker':
					chosenMessage = "Just one good jelq sesh... Can change a man...";

				case 'Super Wario Man':
					if (FlxG.random.bool(50))
						chosenMessage = "Esta bonito";
					else
						chosenMessage = "Esta Bien Culero";

				//nate is so fucking DUMB and forgot SEMICOLONS!!!

				case 'WhiteyDvl':
					if (FlxG.random.bool(50))
						chosenMessage = "THAT'S a technical fouuul...";
					else
						chosenMessage = "Here comes the seuizure nyeuuughghghjuhgh";

				case 'EleanorDvl':
					if (FlxG.random.bool(50))
						chosenMessage = "Has anyone seen my wig";
					else
						chosenMessage = "It's horrible!";

				case 'Joe_Biden':
					switch (FlxG.random.int(1,4)){
						case 1:
							chosenMessage = "I have a sister who's the love of my life...";
						case 2:
							chosenMessage = "SODA!!!!!!";
						case 3:
							chosenMessage = "I got hairy legs.";
						case 4:
							chosenMessage = "chocolate chocolate chip";
					}
				
				case 'misterSYS':
					if (FlxG.random.bool(50))
						chosenMessage = "this song is truly unbeatable";
			}

			chatText = tagcolor + chosenUsername + ': ' + tagcolor + chosenMessage;

			if (chatText.length > 35){
				//trace(chosenUsername + "'s message was too long");
				chatLong =  '-' + chatText.substr(35).ltrim();
				chatText = chatText.substr(0, 35).rtrim() + '-';
				tooLong = true;
			}
		}
		else{
			tooLong = false;
			chatText = chatLong;
			if (chatText.length > 35){
				//trace(chosenUsername + "'s message was too long again");
				chatLong =  '-' + chatText.substr(35).ltrim();
				chatText = chatText.substr(0, 35).rtrim() + '-';
				tooLong = true;
			}
		}

		if(cantidad >= 16){
			//top 5 codigos mas conchesumadre
			chatArray[0] = chatArray[1];
			chatArray[1] = chatArray[2];
			chatArray[2] = chatArray[3];
			chatArray[3] = chatArray[4];
			chatArray[4] = chatArray[5];
			chatArray[5] = chatArray[6];
			chatArray[6] = chatArray[7];
			chatArray[7] = chatArray[8];
			chatArray[8] = chatArray[9];
			chatArray[9] = chatArray[10];
			chatArray[10] = chatArray[11];
			chatArray[11] = chatArray[12];
			chatArray[12] = chatArray[13];
			chatArray[13] = chatArray[14];
			chatArray[14] = chatArray[15];
			chatArray[15] = chatText;
		}
		else{
		chatArray[cantidad] = chatText;
		cantidad += 1;
		}

		finalchat = chatArray[0] + '\n' + chatArray[1] + '\n' + chatArray[2] + '\n' + chatArray[3] + '\n' + chatArray[4] + '\n' + chatArray[5] + '\n' + chatArray[6] + '\n' + chatArray[7] + '\n' + chatArray[8] + '\n' + chatArray[9] + '\n' + chatArray[10] + '\n' + chatArray[11] + '\n' + chatArray[12] + '\n' + chatArray[13] + '\n' + chatArray[14] + '\n' + chatArray[15];
		if(tooLong)
			addMessage();
	}
}