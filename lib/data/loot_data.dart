import '../models/treasure.dart';

class TreasureData {
  static const Map<Rarity, Map<String, String>> treasurePool = {
    Rarity.mythic: {
      "Abyssal Relic":
          "A pulsing stone that swallows light and, occasionally, the hopes and dreams of anyone holding it.",
      "Heart of the Trench":
          "It hums at a frequency that vibrates your teeth. If it stops humming, you should probably start praying.",
      "Void-Touched Compass":
          "It doesn't point North; it points toward the nearest tear in reality. Great for cosmic travel, terrible for finding the bathroom.",
      "Eye of the Leviathan":
          "A massive, preserved ocular lens. It’s definitely watching you, and it doesn't look impressed by your life choices.",
      "Singularity Shard":
          "A fragment of a collapsed star. It weighs more than your ship and the crushing guilt of your ancestors combined.",
      "Pre-Flood Star Map":
          "An indestructible tablet showing stars that died out 50,000 years ago. Just like your chances of a peaceful retirement.",
      "The Nautilus Core":
          "A biological engine that could power a city, or turn you into a puddle of radioactive sludge if you sneeze on it.",
      "Trident of the Storm God":
          "The water around it boils constantly. Perfect for a quick cup of tea or melting the skin off an unwanted intruder.",
      "Ever-Burning Underwater Flame":
          "A chemical anomaly that defies thermodynamics. It thrives in the dark, much like your worst impulses.",
      "Crown of the Sunken King":
          "Forged from an unknown isotope. Wearing it grants you authority over the deep, and a very localized, heavy depression.",
      "Primordial Ooze Vessel":
          "A sealed jar containing the 'starter fluid' of evolution. Open it if you’d like to meet your replacement as the dominant species.",
      "Echo of the Big Bang":
          "A seashell that plays the sound of the universe's creation. It’s mostly just a lot of screaming and static.",
    },
    Rarity.legendary: {
      "Golden Trident":
          "A heavy weapon encrusted with diamond-like barnacles. It’s great for stabbing, but even better for attracting greedy thieves.",
      "Poseidon's Crown":
          "Surprisingly light, though the weight of the millions of sailors who drowned under its reign is still palpable.",
      "Atlantian Power Cell":
          "Technology centuries ahead of our own. It’s currently leaking a blue fluid that makes your hair fall out in clumps.",
      "Sunken Dragon Egg":
          "It’s warm to the touch. Something inside is tapping back, and it sounds hungry for a human soul.",
      "Excalibur’s Scabbard":
          "The Lady of the Lake finally reclaimed it. She clearly didn't have a cleaning kit for all the 'knight-flavored' bloodstains.",
      "Solid Iridium Idol":
          "A heavy statuette of a forgotten deity. Its gaze suggests that forgetting it was a very, very big mistake.",
      "Amulet of Eternal Breath":
          "Allows land-dwellers to walk the ocean floor. Doesn't protect you from being eaten, though. You'll just be conscious for the whole thing.",
      "Royal Mermaid Scepter":
          "Topped with a massive pearl. It likely led many underwater processions, or at least one really expensive funeral.",
      "Kraken-Tooth Dagger":
          "Still dripping with a mild neurotoxin. One nick and you’ll start speaking fluent Dolphin. There is no known cure.",
      "Mantle of the Deep":
          "A cloak of woven shadows. It makes you nearly invisible, which is great for hiding from your problems and your creditors.",
      "Orichalcum Ingot":
          "Harder than steel and glows with heat. It’s the stuff of legends, and the cause of several historical genocides.",
      "Ancient Submersible Schematic":
          "Blueprints for a vessel that travels through the earth's crust. Page four is just a drawing of a skull with a question mark.",
      "Pearl of the Moon":
          "A sphere so white it looks like a dead eye. It also looks like its wearing a pointy hat. It reflects a future you’d probably rather not see.",
    },
    Rarity.epic: {
      "Pearl of Atlas":
          "A massive pearl that feels heavy. It’s not the world on your shoulders, but it’s enough to give you a permanent hunch.",
      "Sunken Astrolabe":
          "Used to find islands that are now underwater. It’s a very sophisticated way of realizing you are completely lost.",
      "Cthulhu's Left Toenail":
          "Jagged, green, and smells of madness. The intern who clipped this didn't make it to the weekend.",
      "Crystal Skull":
          "Anatomically correct. It vibrates when you speak, usually mocking your tone of voice.",
      "Vial of Siren Song":
          "A sealed tube. If you open it, you’ll hear a melody so beautiful you’ll jump out the airlock without a suit.",
      "Damascus Steel Anchor":
          "Incredibly sharp. It’s less of an anchor and more of a 'death from above' tool for unsuspecting coral.",
      "Bioluminescent Jellyfish Lantern":
          "The glass has absorbed a neon glow. It’s the perfect mood lighting for a slow descent into insanity. Just like a divorce.",
      "Titanium Deep-Sea Watch":
          "Still ticking perfectly. It’s a shame the person wearing it was less durable than the titanium.",
      "Engraved Whale Bone":
          "Shows a battle between a squid and a ship. Spoilers: the whale bone is the only thing that survived.",
      "Obsidian Mirror":
          "A dark surface. It shows your reflection from a parallel timeline where you actually made good life choices.",
      "Hydra Venom Vial":
          "Etched with warnings in dead languages. It’s a very slow way to die, but at least it’s 'artisanal'.",
      "Ship’s Bell of the Mary Celeste":
          "It rings on its own when the tide turns. It also rings whenever you’re about to have a terrible idea, so it rings constantly in your hands.",
      "Mechanical Golden Crab":
          "A clockwork toy that scuttles when wound. It has a habit of trying to cut your brake lines while you sleep.",
    },
    Rarity.rare: {
      "Sunken Coin":
          "A gold doubloon with a bite mark in it. Someone was either checking its purity or died in a very confusing way.",
      "Silver Ingot":
          "A blackened bar of silver. It needs a polish, much like your reputation after this expedition.",
      "Jeweled Hilt":
          "The blade is gone. It’s useless in a fight, but you’ll look very wealthy while you’re being mugged.",
      "Crate of Fine Spices":
          "The scent of cinnamon is still potent. It’s a nice change from the smell of damp metal and claustrophobia.",
      "Porcelain Tea Set":
          "Not a single chip. It survived the crushing pressure of the deep, which is more than we can say for the crew.",
      "Ivory Smoking Pipe":
          "Carved like a sea serpent. It belonged to a captain who is now 80% crab by volume.",
      "Navigator's Sextant":
          "A brass tool for finding your way. It led its last owner directly into a trench, so use it with caution.",
      "Stained Glass Lantern":
          "From a sunken cathedral. It casts beautiful patterns on the walls while you contemplate the void.",
      "Polished Megalodon Tooth":
          "A tooth the size of a dinner plate. A reminder that you are basically a snack in a tin can.",
      "Sealed Wine from 1700":
          "The vintage is 'earthy.' Specifically, it tastes like fermented salt and the regrets of a dead sommelier.",
      "Copper Diving Helmet":
          "Dented and scratched. The glass is stained with what looks like a very permanent scream.",
      "Compass of the Lost":
          "The needle spins aimlessly. It’s the perfect metaphor for your current career path.",
      "Jade Turtle Carving":
          "A serene turtle carved from jade. It’s the only thing in this submersible that isn't currently panicking.",
      "Gilded Spyglass":
          "You can almost see the horizon of the past. It’s mostly just a lot of people drowning in high-definition.",
      "Viking Shield Fragment":
          "A piece of wood that crossed the Atlantic. It didn't help the Viking, and it probably won't help you.",
      "Ancient Ceramic Jug":
          "Now home to a very small, very angry crab. He’s already filed a restraining order against you.",
    },
    Rarity.uncommon: {
      "Bio-Luminescent Kelp":
          "Stays fresh for a long time. It’s basically the radioactive kale of the ocean.",
      "Glowing Coral":
          "Provides enough light to read by. Mostly helpful for reading your own 'Last Will and Testament'.",
      "Strange Shell":
          "Emits a low hum. It feels warm when the tide comes in, or when it senses fresh blood.",
      "Petrified Starfish":
          "A five-armed creature turned to stone. It’s a star that literally crashed and burned.",
      "Shark Tooth Necklace":
          "A rugged piece of jewelry. Each tooth represents a shark that is currently looking for its missing property.",
      "Designer Hermit Crab Shell":
          "Some crab has very expensive taste. It’s only a matter of time before it starts asking for a mortgage.",
      "Water-Logged Journal":
          "The ink has bled, but you can still make out: 'It’s right behind me, isn't it?'",
      "Hand-Carved Driftwood Toy":
          "A small wooden horse. A grim reminder that children’s toys are 500% spookier when found underwater.",
      "Oxidized Iron Key":
          "What it opens is anyone's guess. Given your luck, it’s probably a cage.",
      "Brass Porthole Frame":
          "A sturdy piece of a ship's window. Perfect for framing a picture of the sun you'll never see again.",
      "Smooth Volcanic Rock":
          "Birthed from an underwater vent. It’s essentially a very heavy, very dark 'stress ball'.",
      "Fisherman's Lucky Hat":
          "It wasn't lucky enough to stay on his head. Or keep his head on his shoulders.",
      "Intact Lightbulb (How?)":
          "A miracle of physics. It survived 4,000 meters of pressure, yet you can’t survive a week without Wi-Fi.",
      "Lost Wedding Ring":
          "Inscription: 'To the end of the world.' It appears they reached their destination ahead of schedule.",
      "Message in a Bottle":
          "A very detailed recipe for Gandalf's chowder. The secret ingredient is, unsurprisingly, more MSG.",
    },
    Rarity.common: {
      "Rusty Anchor":
          "More rust than iron. It’s not going to hold the ship, but it might give a fish tetanus.",
      "Ball of Tangled Fishing Line":
          "The ultimate test of patience. Legend says if you untangle it, you die of old age instantly.",
      "Old Boot":
          "Size 10. It’s developed its own ecosystem and a primitive government that has already declared war on you.",
      "Soggy Driftwood":
          "Heavy, salt-soaked wood. It’s the ocean's way of saying 'I have no trash cans, so you take it'.",
      "Sea Glass":
          "A piece of a green bottle, smoothed by decades of waves. Once a vessel for beer, now a vessel for 'meh'.",
      "Empty Bottle":
          "Contains a little bit of seawater and the lingering scent of broken promises.",
      "Tin Can":
          "Labels are gone. It’s a 50/50 shot between 'Peaches' and 'Toxic Sludge'. Bon appétit!",
      "Average Pebble":
          "It’s a rock. It’s grey. It has more personality than most of your coworkers.",
      "Chunk of Coal":
          "A reminder of the age of steam. It fell off a freighter and has been judging the ecosystem ever since.",
      "Waterlogged Rope":
          "Slippery, heavy, and generally useless. Much like the 'safety' training you received.",
      "Broken Oar":
          "Someone had a very difficult time getting home. They didn't make it, but hey, you found a stick!",
      "Plastic Straw":
          "A grim reminder of the surface world. It will likely outlive you, your children, and the sun. It also choked 4 baby turtles.",
      "Barnacle-Covered Brick":
          "Why is there a brick at the bottom of the ocean? Who were they trying to build a house for? The Little Mermaid?",
      "Rubber Duck":
          "It has a thousand-yard stare. It watched the hull breach with a terrifying, plastic smile.",
      "Faded Postcard":
          "A picture of Hawaii. The message on the back: 'Wish you were here!'... I think they were being literal.",
      "Dead Car Battery":
          "Leaking grape-juice-colored acid. Toss it back to give the electric eels a fighting chance at revenge.",
      "Bent Paperclip":
          "Perhaps a shark was trying to keep its tax returns organized before it ate the accountant.",
      "Salty Rag":
          "It’s wet. It’s dirty. It’s a rag. You’re a legendary explorer and you’re holding a wet rag. Think about that.",
      "Moldy Sandwich":
          "Technically a new species of fungus. It’s currently writing its own manifesto in your cargo hold.",
      "Soggy Newspaper":
          "A headline about a bake sale from 1994. The muffins were reportedly 'to die for'.",
      "Empty Can of Soda":
          "Crushed by the pressure into a tiny metal puck. A helpful visual aid for what will happen if your hull fails.",
      "Michael's Group's Project":
          "Raycasted Pong. A 'C-' effort that confirms some horrors should remain buried in the source code.",
      "Uninflated Tire":
          "A rubber donut of despair. It doesn't even have the rim, so you can’t even sell it for scrap.",
      "Cracked Sunglasses":
          "Cool in 1988, but now they’re just a way to look fashionable while drowning in silt.",
      "A Single Sock":
          "The other one is attached to a foot that never made it back to the surface. Best not to think about it.",
    },
  };
}
