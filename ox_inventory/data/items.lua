return {
	['testburger'] = {
		label = 'Test Burger',
		weight = 220,
		degrade = 60,
		client = {
			image = 'burger_chicken.png',
			status = { hunger = 200000 },
			anim = 'eating',
			prop = 'burger',
			usetime = 2500,
			export = 'ox_inventory_examples.testburger'
		},
		server = {
			export = 'ox_inventory_examples.testburger',
			test = 'what an amazingly delicious burger, amirite?'
		},
		buttons = {
			{
				label = 'Lick it',
				action = function(slot)
					print('You licked the burger')
				end
			},
			{
				label = 'Squeeze it',
				action = function(slot)
					print('You squeezed the burger :(')
				end
			},
			{
				label = 'What do you call a vegan burger?',
				group = 'Hamburger Puns',
				action = function(slot)
					print('A misteak.')
				end
			},
			{
				label = 'What do frogs like to eat with their hamburgers?',
				group = 'Hamburger Puns',
				action = function(slot)
					print('French flies.')
				end
			},
			{
				label = 'Why were the burger and fries running?',
				group = 'Hamburger Puns',
				action = function(slot)
					print('Because they\'re fast food.')
				end
			}
		},
		consume = 0.3
	},

	['bandage'] = {
		label = 'Bandage',
		weight = 115,
		client = {
			anim = { dict = 'missheistdockssetup1clipboard@idle_a', clip = 'idle_a', flag = 49 },
			prop = { model = `prop_rolled_sock_02`, pos = vec3(-0.14, -0.14, -0.08), rot = vec3(-50.0, -50.0, 0.0) },
			disable = { move = true, car = true, combat = true },
			usetime = 2500,
		}
	},

	['black_money'] = {
		label = 'Dirty Money',
	},

	['burger'] = {
		label = 'Burger',
		weight = 220,
		client = {
			status = { hunger = 200000 },
			anim = 'eating',
			prop = 'burger',
			usetime = 2500,
			notification = 'You ate a delicious burger'
		},
	},

	['sprunk'] = {
		label = 'Sprunk',
		weight = 350,
		client = {
			status = { thirst = 200000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `prop_ld_can_01`, pos = vec3(0.01, 0.01, 0.06), rot = vec3(5.0, 5.0, -180.5) },
			usetime = 2500,
			notification = 'You quenched your thirst with a sprunk'
		}
	},

	['parachute'] = {
		label = 'Parachute',
		weight = 8000,
		stack = false,
		client = {
			anim = { dict = 'clothingshirt', clip = 'try_shirt_positive_d' },
			usetime = 1500
		}
	},

	['garbage'] = {
		label = 'Garbage',
	},

	['paperbag'] = {
		label = 'Paper Bag',
		weight = 1,
		stack = false,
		close = false,
		consume = 0
	},

	['identification'] = {
		label = 'Identification',
		client = {
			image = 'card_id.png'
		}
	},

	['panties'] = {
		label = 'Knickers',
		weight = 10,
		consume = 0,
		client = {
			status = { thirst = -100000, stress = -25000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `prop_cs_panties_02`, pos = vec3(0.03, 0.0, 0.02), rot = vec3(0.0, -13.5, -1.5) },
			usetime = 2500,
		}
	},

	['lockpick'] = {
		label = 'Lockpick',
		weight = 160,
	},

	['phone'] = {
		label = 'Phone',
		weight = 190,
		stack = false,
		consume = 0,
		client = {
			add = function(total)
				if total > 0 then
					pcall(function() return exports.npwd:setPhoneDisabled(false) end)
				end
			end,

			remove = function(total)
				if total < 1 then
					pcall(function() return exports.npwd:setPhoneDisabled(true) end)
				end
			end
		}
	},

	['money'] = {
		label = 'Money',
	},

	['mustard'] = {
		label = 'Mustard',
		weight = 500,
		client = {
			status = { hunger = 25000, thirst = 25000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `prop_food_mustard`, pos = vec3(0.01, 0.0, -0.07), rot = vec3(1.0, 1.0, -1.5) },
			usetime = 2500,
			notification = 'You.. drank mustard'
		}
	},

	['water'] = {
		label = 'Water',
		weight = 500,
		client = {
			status = { thirst = 200000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `prop_ld_flow_bottle`, pos = vec3(0.03, 0.03, 0.02), rot = vec3(0.0, 0.0, -1.5) },
			usetime = 2500,
			cancel = true,
			notification = 'You drank some refreshing water'
		}
	},

	['radio'] = {
		label = 'Radio',
		weight = 1000,
		stack = false,
		allowArmed = true
	},

	['armour'] = {
		label = 'Bulletproof Vest',
		weight = 3000,
		stack = false,
		client = {
			anim = { dict = 'clothingshirt', clip = 'try_shirt_positive_d' },
			usetime = 3500
		}
	},

	['clothing'] = {
		label = 'Clothing',
		consume = 0,
	},

	['mastercard'] = {
		label = 'Fleeca Card',
		stack = false,
		weight = 10,
		client = {
			image = 'card_bank.png'
		}
	},

	['scrapmetal'] = {
		label = 'Scrap Metal',
		weight = 80,
	},

	-- Runa System Items
	['galeoni'] = {
		label = 'Galeoni',
		weight = 0,
		stack = true,
		close = true,
		description = 'Valuta speciale del sistema runa',
		client = {
			image = 'galeoni.png'
		}
	},
	['runa_hp'] = {
		label = 'Runa HP',
		weight = 100,
		stack = true,
		close = true,
		description = 'Aumenta la salute massima',
		client = {
			image = 'runa_hp.png'
		}
	},
	['runa_hp_1'] = {
		label = 'Runa HP +1',
		weight = 100,
		stack = true,
		close = true,
		description = 'Runa HP migliorata che aumenta la salute massima del 10%',
		client = {
			image = 'runa_hp.png'
		}
	},
	['runa_hp_2'] = {
		label = 'Runa HP +2',
		weight = 100,
		stack = true,
		close = true,
		description = 'Runa HP avanzata che aumenta la salute massima del 25%',
		client = {
			image = 'runa_hp.png'
		}
	},
	['runa_hp_3'] = {
		label = 'Runa HP +3',
		weight = 100,
		stack = true,
		close = true,
		description = 'Runa HP superiore che aumenta la salute massima del 50%',
		client = {
			image = 'runa_hp.png'
		}
	},
	['runa_hp_4'] = {
		label = 'Runa HP +4',
		weight = 100,
		stack = true,
		close = true,
		description = 'Runa HP epica che aumenta la salute massima del 75%',
		client = {
			image = 'runa_hp.png'
		}
	},
	['runa_danno'] = {
		label = 'Runa Danno',
		weight = 100,
		stack = true,
		close = true,
		description = 'Aumenta il danno delle armi',
		client = {
			image = 'runa_danno.png'
		}
	},
	['runa_danno_1'] = {
		label = 'Runa Danno +1',
		weight = 100,
		stack = true,
		close = true,
		description = 'Runa Danno migliorata che aumenta il danno del 15%',
		client = {
			image = 'runa_danno.png'
		}
	},
	['runa_danno_2'] = {
		label = 'Runa Danno +2',
		weight = 100,
		stack = true,
		close = true,
		description = 'Runa Danno avanzata che aumenta il danno del 30%',
		client = {
			image = 'runa_danno.png'
		}
	},
	['runa_danno_3'] = {
		label = 'Runa Danno +3',
		weight = 100,
		stack = true,
		close = true,
		description = 'Runa Danno superiore che aumenta il danno del 50%',
		client = {
			image = 'runa_danno.png'
		}
	},
	['runa_danno_4'] = {
		label = 'Runa Danno +4',
		weight = 100,
		stack = true,
		close = true,
		description = 'Runa Danno epica che aumenta il danno del 75%',
		client = {
			image = 'runa_danno.png'
		}
	},
	['runa_mp'] = {
		label = 'Runa MP',
		weight = 100,
		stack = true,
		close = true,
		description = 'Aumenta i punti mana',
		client = {
			image = 'runa_mp.png'
		}
	},
	['runa_mp_1'] = {
		label = 'Runa MP +1',
		weight = 100,
		stack = true,
		close = true,
		description = 'Runa MP migliorata che aumenta il mana massimo del 20%',
		client = {
			image = 'runa_mp.png'
		}
	},
	['runa_mp_2'] = {
		label = 'Runa MP +2',
		weight = 100,
		stack = true,
		close = true,
		description = 'Runa MP avanzata che aumenta il mana massimo del 40%',
		client = {
			image = 'runa_mp.png'
		}
	},
	['runa_mp_3'] = {
		label = 'Runa MP +3',
		weight = 100,
		stack = true,
		close = true,
		description = 'Runa MP superiore che aumenta il mana massimo del 60%',
		client = {
			image = 'runa_mp.png'
		}
	},
	['runa_mp_4'] = {
		label = 'Runa MP +4',
		weight = 100,
		stack = true,
		close = true,
		description = 'Runa MP epica che aumenta il mana massimo dell\'80%',
		client = {
			image = 'runa_mp.png'
		}
	},
	['runa_cdr'] = {
		label = 'Runa CDR',
		weight = 100,
		stack = true,
		close = true,
		description = 'Riduce il cooldown delle abilità',
		client = {
			image = 'runa_cdr.png'
		}
	},
	['runa_cdr_1'] = {
		label = 'Runa CDR +1',
		weight = 100,
		stack = true,
		close = true,
		description = 'Runa CDR migliorata che riduce i cooldown del 10%',
		client = {
			image = 'runa_cdr.png'
		}
	},
	['runa_cdr_2'] = {
		label = 'Runa CDR +2',
		weight = 100,
		stack = true,
		close = true,
		description = 'Runa CDR avanzata che riduce i cooldown del 25%',
		client = {
			image = 'runa_cdr.png'
		}
	},
	['runa_cdr_3'] = {
		label = 'Runa CDR +3',
		weight = 100,
		stack = true,
		close = true,
		description = 'Runa CDR superiore che riduce i cooldown del 40%',
		client = {
			image = 'runa_cdr.png'
		}
	},
	['runa_cdr_4'] = {
		label = 'Runa CDR +4',
		weight = 100,
		stack = true,
		close = true,
		description = 'Runa CDR epica che riduce i cooldown del 60%',
		client = {
			image = 'runa_cdr.png'
		}
	},
	['runa_speed'] = {
		label = 'Runa Speed',
		weight = 100,
		stack = true,
		close = true,
		description = 'Aumenta la velocità di movimento',
		client = {
			image = 'runa_speed.png'
		}
	},
	['runa_speed_1'] = {
		label = 'Runa Speed +1',
		weight = 100,
		stack = true,
		close = true,
		description = 'Runa Speed migliorata che aumenta la velocità del 10%',
		client = {
			image = 'runa_speed.png'
		}
	},
	['runa_speed_2'] = {
		label = 'Runa Speed +2',
		weight = 100,
		stack = true,
		close = true,
		description = 'Runa Speed avanzata che aumenta la velocità del 20%',
		client = {
			image = 'runa_speed.png'
		}
	},
	['runa_speed_3'] = {
		label = 'Runa Speed +3',
		weight = 100,
		stack = true,
		close = true,
		description = 'Runa Speed superiore che aumenta la velocità del 30%',
		client = {
			image = 'runa_speed.png'
		}
	},
	['runa_speed_4'] = {
		label = 'Runa Speed +4',
		weight = 100,
		stack = true,
		close = true,
		description = 'Runa Speed epica che aumenta la velocità del 40%',
		client = {
			image = 'runa_speed.png'
		}
	},
	['pietra_grezza'] = {
		label = 'Pietra Grezza',
		weight = 100,
		stack = true,
		close = true,
		description = 'Pietra utilizzata per craftare rune',
		client = {
			image = 'pietra_grezza.png'
		}
	},
	['runa_fortuna'] = {
		label = 'Runa Fortuna',
		weight = 0,
		stack = true,
		close = true,
		description = 'Aumenta la fortuna e i drop rate'
	},
	['runa_mistica'] = {
		label = 'Runa Mistica',
		weight = 0,
		stack = true,
		close = true,
		description = 'Rara runa che aumenta tutte le statistiche'
	},
	['runa_hp_divina'] = {
		label = 'Runa HP Divina +5',
		weight = 100,
		stack = true,
		close = true,
		description = 'Runa massimizzata che conferisce immortalità temporanea e rigenerazione istantanea',
		client = {
			image = 'runa_hp.png'
		}
	},
	['runa_danno_divina'] = {
		label = 'Runa Danno Divina +5',
		weight = 100,
		stack = true,
		close = true,
		description = 'Runa massimizzata che triplica il danno e aggiunge effetti elementali',
		client = {
			image = 'runa_danno.png'
		}
	},
	['runa_mp_divina'] = {
		label = 'Runa MP Divina +5',
		weight = 100,
		stack = true,
		close = true,
		description = 'Runa massimizzata che garantisce mana infinito e cast istantanei',
		client = {
			image = 'runa_mp.png'
		}
	},
	['runa_cdr_divina'] = {
		label = 'Runa CDR Divina +5',
		weight = 100,
		stack = true,
		close = true,
		description = 'Runa massimizzata che elimina tutti i cooldown e permette abilità concatenate',
		client = {
			image = 'runa_cdr.png'
		}
	},
	['runa_speed_divina'] = {
		label = 'Runa Speed Divina +5',
		weight = 100,
		stack = true,
		close = true,
		description = 'Runa massimizzata che conferisce velocità suprema e teletrasporto breve',
		client = {
			image = 'runa_speed.png'
		}
	},

	['orologiostellare'] = {
		label = 'Orologio Stellare',
		weight = 100,
		stack = true,
		close = true,
		client = {
			export = 'Runa_System.orologiostellare:use'
		}
	},

	['galeoni'] = {
		label = 'Galeoni',
		weight = 1,
		stack = true,
		close = true,
		description = 'Moneta antica usata per incantare rune magiche. 200 galeoni per ogni incantesimo.'
	},

	['steel'] = {
		label = 'Steel',
		weight = 100,
	},

	['metalscrap'] = {
		label = 'Metal Scrap',
		weight = 100,
	},

	['iron'] = {
		label = 'Iron',
		weight = 100,
	},

	['copper'] = {
		label = 'Copper',
		weight = 100,
	},

	
	['aluminium'] = {
		label = 'Aluminium',
		weight = 100,
	},

	["golddiamondring"] = {
		label = "Gold Diamond Ring",
		weight = 100,
		stack = true,
		close = true,
		description = "It's a gold ring with a diamond?",
		client = {
			image = "golddiamondring.png",
		}
	},

	["goldbracelet"] = {
		label = "Gold Bracelet",
		weight = 100,
		stack = true,
		close = true,
		description = "Is this bracelet real gold?",
		client = {
			image = "goldbracelet.png",
		}
	},

	["goldring"] = {
		label = "Golden Ring",
		weight = 100,
		stack = true,
		close = true,
		description = "My precious",
		client = {
			image = "goldring.png",
		}
	},

	["rubyring"] = {
		label = "Ruby Ring",
		weight = 100,
		stack = true,
		close = true,
		description = "It is a ruby, not a rubix",
		client = {
			image = "rubyring.png",
		}
	},

	["bottlecap"] = {
		label = "Bottle Cap",
		weight = 100,
		stack = true,
		close = true,
		description = "Stepped on a pop top",
		client = {
			image = "bottlecap.png",
		}
	},

	["corno"] = {
		label = "Corno",
		weight = 100,
		stack = true,
		close = true,
		description = "",
		client = {
			image = "corno.png",
		}
	},

	["toycar"] = {
		label = "Toy Car",
		weight = 100,
		stack = true,
		close = true,
		description = "Don't put it in odd places",
		client = {
			image = "toycar.png",
		}
	},


	["metaldetector"] = {
		label = "Metal Detector",
		weight = 2500,
		stack = true,
		close = true,
		description = "Maybe it can find things",
		client = {
			image = "metaldetector.png",
			event = 'qb-metaldetecting:togglehand'
		}
	},

	["1797coin"] = {
		label = "1797 Coin",
		weight = 100,
		stack = true,
		close = true,
		description = "Dat's old",
		client = {
			image = "1797coin.png",
		}
	},

	["bobbypin"] = {
		label = "Bobby Pin",
		weight = 100,
		stack = true,
		close = true,
		description = "Put your hair up",
		client = {
			image = "bobbypin.png",
		}
	},

	["1792coin"] = {
		label = "1792 Coin",
		weight = 100,
		stack = true,
		close = true,
		description = "Even older",
		client = {
			image = "1792coin.png",
		}
	},

	["diamondring"] = {
		label = "Diamond Ring",
		weight = 100,
		stack = true,
		close = true,
		description = "Pretty sure some poor kid made this",
		client = {
			image = "diamondring.png",
		}
	},

	["clump"] = {
		label = "Clump",
		weight = 100,
		stack = true,
		close = true,
		description = "Not a turd",
		client = {
			image = "clump.png",
		}
	},

}
