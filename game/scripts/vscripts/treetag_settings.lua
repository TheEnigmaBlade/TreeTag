START_GOLD_GOOD		= 100
START_GOLD_BAD		= 100

START_LVLS_GOOD		= 0
START_LVLS_BAD		= 1

GOOD_GUY_ITEMS		= {"item_build_gold_gen", "item_build_scout_tower", "item_build_wall", "item_build_basic_tower", "item_build_barracks", "item_empty"}

MESSAGE_HEADSTART_GOOD	= "QUICKLY! RUN AND HIDE!"
MESSAGE_HEADSTART_BAD	= " "
MESSAGE_START_GOOD		= "Watch out, here they come!"
MESSAGE_START_BAD		= "Those pesky trees have run off. Go catch them!"

MESSAGE_GOOD_DEATH_GOOD	= "Oh no! A tree has been captured!"
MESSAGE_GOOD_DEATH_BAD	= "Good job! A tree has been captured!"
MESSAGE_BAD_DEATH_GOOD	= "A forester has been killed! Keep it up!"
MESSAGE_BAD_DEATH_BAD	= "A forester has been killed! You can do better than that!"

NUM_UPDATES				= 5
UPDATE_PERIOD			= 5*60
UPDATE_EXP_BASE			= 100
UPDATE_MOVESPEED		= 25
UPDATE_MESSAGES_BAD		= {
		{"I guess the start is a bit rough. Here's some help.", "You can start better than that."},
		{"I hope you've caught at least one by now.", "Don't worry, you still have 20 minutes left."},
		{"Half way until the end!", "15 minute mark. You've still got time.", "WHY HAVEN'T YOU GOTTEN THEM ALL YET?"},
		{"You're starting to run out of time!", "10 minutes to go. You're getting close to the end!"},
		{"There are only 5 minutes left. Hurry it up!", "You haven't found them all yet?! Only 5 minutes remain!", "You're cutting it close. Only 5 minutes left!"}
	}
UPDATE_MESSAGES_GOOD	= {
		{"Not caught yet? Good.", "So far, so good. Keep wasting time.", "If you've been caught already, you deserve to stay in the center.", "The foresters are getting stronger. Stay alert."},
		{"What's that? The foresters have grown stronger?", "Careful, the foresters' strength is growing.", "You're 10 minutes in. Keep it up."},
		{"You're half way there. Keep it up!", "By the way, the foresters have gotten stronger.", "15 minutes left and the foresters have grown again."},
		{"Getting closer, but the foresters have grown.", "Almost there, only 10 minutes left!"},
		{"The foresters have gotten stronger! 5 minutes remain.", "The foresters became stronger. Stay hidden for 5 more minutes!", "5 minutes left. NEVER GIVE UP!"}
	}

GAME_LENGTH			= 30*60

-- Technical
HERO_DUMMY				= "npc_dota_hero_wisp"
HERO_GOOD				= "npc_dota_hero_treant"
HERO_BAD				= "npc_dota_hero_shredder"
AUTO_LEVEL_UNITS		= {"npc_scout_vision_dummy_unit", "npc_building_invisible_wall"}
