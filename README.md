# TF2 Weapon Collection

This is a mod for Garry's Mod TTT, adding 24 new weapons into the game, and more, all from Team Fortress 2!

Includes...

- 8 Melee weapons, that spawn on the ground and can replace your crowbar!
- 11 Floor weapons, that spawn on the ground
- 4 Detective weapons, that detectives can buy
- 4 Traitor weapons, that traitors can buy
- 24 Weapon upgrades, one for each weapon, for the "Pack-a-Punch" mod:\
<https://steamcommunity.com/sharedfiles/filedetails/?id=3043605644>
- 2 Roles using weapons and abilities from each of the TF2 classes, for "Custom Roles for TTT" mod, or "TTT2" mods!\
<https://steamcommunity.com/sharedfiles/filedetails/?id=2404251054>
<https://steamcommunity.com/sharedfiles/filedetails/?id=1357204556>
- 1 Randomat event using all of the TF2 weapons in the pack, where you play a round of Capture the Flag, for the "Randomat" mod:\
<https://steamcommunity.com/sharedfiles/filedetails/?id=2055805086>
- (And also works with the randomat's many different versions:)\
<https://steamcommunity.com/sharedfiles/filedetails/?id=1406495040>\
<https://steamcommunity.com/sharedfiles/filedetails/?id=2428342861>

## Credits

Credit goes to [IRIS](https://steamcommunity.com/profiles/76561198145368675) and [FLOWEY](https://steamcommunity.com/id/LMAO-NOOB-EZ-UNINSTALL-KID) for creating [The Ultimate TF2 Weapon Collection Revised](https://steamcommunity.com/sharedfiles/filedetails/?id=3266137777) mod, which this mod was originally based off of. (However, much of the original code was very heavily modified, or re-written).\
\
Credit goes to [Malivil](https://steamcommunity.com/id/malivil) for creating the [Improved Double Jump!](https://steamcommunity.com/sharedfiles/filedetails/?id=2501234496) mod, which was used for the Scout's double/multi-jump ability.

## Roles

### The REDMann & BLUMann

The REDMann is a Traitor role, the BLUMann is a Detective role\
On dying, you see a "Freeze cam" of the player that killed you!\
Instead of buying items, you choose a TF2 class to play as!\
\
**To use the RED/BLU Mann roles, you must enable them!**\
*ttt_redmann_enabled* - Default: 0 - Whether the RED Mann role is enabled\
*ttt_blumann_enabled* - Default: 0 - Whether the BLU Mann role is enabled

### Classes

#### Scout

Moves faster, less health, 1+ extra jump\
Starting Weapons: Sandman, Pistol, Scattergun

#### Solider

Immune to fall damage\
Starting Weapons: Escape Plan, Rocket Launcher, Shotgun

#### Pyro

Immune to fire damage\
Starting Weapons: Lollichop, Flamethrower, Shotgun

#### Demoman

Immune to explosion damage\
Starting Weapons: Ullapool Caber, Grenade Launcher, Sitckybomb Launcher

#### Heavy

Moves slower, more health\
Starting Weapons: Golden Frying Pan, Minigun, Sandvich

#### Engineer

Can place a sentry turret\
Starting Weapons: Eureka Effect, Pistol, Shotgun

#### Medic

Passive health regen\
Starting Weapons: Bonesaw, Medi Gun, Syringe Gun

#### Sniper

Sniper rifle is always at full damage\
Starting Weapons: Machete, Sniper Rifle, SMG

#### Spy

Starts with a lot of sneaky powerful items\
Starting Weapons: Backstab Knife, Revolver, Invis Watch, Disguiser

## Randomat Event "Meet the Randomat!"

When the "Meet the randomat" event triggers, a round of Capture the Flag begins!\
All players are set to traitor/detective, or REDMann/BLUMann if Custom Roles for TTT is installed.\
After the intelligence (flag) is captured and returned to your team's base 2 times (by default), your team wins!\
\
You can choose a TF2 class to play as during this event, and can change classes while dead, players respawn after 15 seconds (by default)\
If Custom Roles for TTT is not installed, you are simply given your classes' weapons on selecting a class\
On dying, you see a "Freeze cam" of the player that killed you!\
\
*ttt_randomat_tf2* - Default: 1 - Whether this randomat event is enabled\
*randomat_tf2_captures_to_win* - Default: 2 - Number of flag captures for a team to win\
*randomat_tf2_respawn_seconds* - Default: 15 - Seconds to wait after dying until you respawn\
*randomat_tf2_play_music* - Default: 1 - Play music during the event

## Melee Weapons

### Bonesaw

Gives passive health regen while held\
PaP Upgrade: Health regen increased, also heals nearby players!\
*ttt_pap_amputator* - Default: 1 - Whether this upgrade is enabled

### Ullapool Caber

Explodes on first hit and sends players flying\
PaP Upgrade: No self-damage, infinite explosions!\
*ttt_pap_the_boomstick* - Default: 1 - Whether this upgrade is enabled

### The Escape Plan

Increases speed while held, speed scales with health lost\
PaP Upgrade: Damage increases as health decreases as well!\
*ttt_pap_the_equalizer* - Default: 1 - Whether this upgrade is enabled

### Eureka Effect

Has a 1-time teleport back to a spawn point\
PaP Upgrade: Press Right-Click to place and build a sentry!\
*ttt_pap_sentry_wrench* - Default: 1 - Whether this upgrade is enabled

### Golden Frying Pan

Turns anything you hit to gold, hit bodies & killed players cannot be searched\
PaP Upgrade: Sells anything you hit!\
*ttt_pap_the_moneymaker* - Default: 1 - Whether this upgrade is enabled

### Lollichop

Grants "Pyrovision" on being held\
PaP Upgrade: Welcome to Pyroland... Increased damage, range, and swing speed!\
*ttt_pap_pyrovision_stick* - Default: 1 - Whether this upgrade is enabled

### Machete

Does bleed damage over time\
PaP Upgrade: Bleed lasts forever, kills are silent!\
*ttt_pap_tribalmans_shiv* - Default: 1 - Whether this upgrade is enabled

### The Sandman

Baseball bat that can launch a baseball, which temporarily slows players on hit\
PaP Upgrade: Bigger balls... They do everything better!\
*ttt_pap_mr_sandman* - Default: 1 - Whether this upgrade is enabled

## Floor Weapons

### Flamethrower

A short-range, high-damage flamethrower, that can push players back with right-click\
PaP Upgrade: Increased damage, range and ammo... Shoots rainbows!\
*ttt_pap_rainblower* - Default: 1 - Whether this upgrade is enabled

### Grenade Launcher

Low-ammo grenade launcher that explode on direct hit or after a few seconds\
PaP Upgrade: Hold fire to charge, shoots high-damage cannonballs!\
*ttt_pap_loose_cannon* - Default: 1 - Whether this upgrade is enabled

### Minigun

Charges up before it starts shooting, deals heavy damage and doesn't need to be reloaded\
PaP Upgrade: Kills and spins up silently, 100% accurate, shoots more quietly\
*ttt_pap_tomislav* - Default: 1 - Whether this upgrade is enabled

### Pistol

Standard pistol with 12 ammo in a clip\
PaP Upgrade: A pistol-shotgun that lets you shove players! (Right-click)\
*ttt_pap_shortstop* - Default: 1 - Whether this upgrade is enabled

### Revolver

High-damage revolver with 6 ammo in a clip\
PaP Upgrade: Kills turn you invisible for 10 stacking seconds\
*ttt_pap_invisivolver* - Default: 1 - Whether this upgrade is enabled

### Sandvich

Temporarily heals you to full health, takes the grenade slot, lasts 30 seconds\
PaP Upgrade: Om nom nom... Sandvich last long! Sandvich make more damage and speed!\
*ttt_pap_steak_sandvich* - Default: 1 - Whether this upgrade is enabled

### Scattergun

Fast-firing lower damage shotgun\
PaP Upgrade: A double barrel that launches players back!\
*ttt_pap_force_a_nature* - Default: 1 - Whether this upgrade is enabled

### Shotgun

Standard shotgun with 6 ammo in a clip\
PaP Upgrade: 1-shot kills anyone in the air!\
*ttt_pap_reserve_shooter* - Default: 1 - Whether this upgrade is enabled

### SMG

Standard SMG with 25 ammo in a clip, takes the pistol slot\
PaP Upgrade: Throw at players to make them temporarily have 1 HP!\
*ttt_pap_jarate* - Default: 1 - Whether this upgrade is enabled

### Sniper

A high-damage sniper rifle that charges its damage up after scoping in, has a laser sight\
PaP Upgrade: Full-charge headshots always kill!\
*ttt_pap_awper_hand* - Default: 1 - Whether this upgrade is enabled

### Syringe Gun

A very high-damage, low range and accuracy gun, syringes fired are affected by gravity\
PaP Upgrade: Heals 3 HP for every hit!\
*ttt_pap_blutsauger* - Default: 1 - Whether this upgrade is enabled

## Buyable Weapons

### Invis Watch

Detective/Traitor, temporarily makes you invisible, can be reloaded with pistol ammo\
PaP Upgrade: Recharges while standing still and not attacking!\
*ttt_pap_cloak_and_dagger* - Default: 1 - Whether this upgrade is enabled

### Backstab Knife

Detective/Traitor, instantly kills any player hit from behind, infinite uses, melee weapon\
PaP Upgrade: Doesn't leave bodies, take on the appearance of your victims!\
*ttt_pap_eternal_reward* - Default: 1 - Whether this upgrade is enabled

### Medi Gun

Detective, heals players at a range, can activate temporary invincibility (Ubercharge) after ammo is depleted\
PaP Upgrade: Activate Ubercharge an unlimited number of times!\
*ttt_pap_uber_medi_gun* - Default: 1 - Whether this upgrade is enabled

### Rocket Launcher

Detective/Traitor, lets you rocket-jump! Look at the ground and shoot a rocket to go flying into the air!\
PaP Upgrade: Immune to fall & self-damage while held, launches players hilariously far!\
*ttt_pap_rpweee* - Default: 1 - Whether this upgrade is enabled

### Stickybomb Launcher

Traitor, shoots bombs that can be remotely detonated, max 8 at a time\
PaP Upgrade: No self-damage, more damage and push force, infinite ammo!\
*ttt_pap_sticky_jumper* - Default: 1 - Whether this upgrade is enabled

## Steam Workshop Link

<https://steamcommunity.com/sharedfiles/filedetails/?id=3484716425>
