# Vulpreich
A new NES game about a rich Pearl Latina morph fox.

# Specs:
Metadata about the game
-	Mapper: MMC5 (no audio)
-	RAM: 131K (1K of on-chip RAM, 2K internal)
-	ROM: 2M PRG - 1M / CHR - 1M
-	Window: 8K PRG / 4K CHR
-	Mirroring: None

# Main story:
Phillip Reich ends up caught in a legal accident regarding music complaints toward a former neighbor.  As a result, Phillip, left in psychological shock after the accusation, leaves anything and everything of value to his Pearl Latina morph red fox, Iggy Reich.  As Iggy, the player is left in an open world to do anything of their chosing with the end goal being to reunite with Phillip.

# Building:
Code for this game comes with ASM6F as well as two `.bat` files that the command prompt will recognize.  To build this, go to the command prompt, follow the directory with `cd`, and type `build`.  There are only two configurations that turn the ROM into an NSF file, as well as a Sound Effect mode on top of that.  Feel free to expand the configuration file to make insteresting ROM modifications.

# NSF:
Implementation is complete, so the code is all there as well as the configuration.  This uses its own `.bat` file though.  To build the NSF, uncomment the NSF configuration, then go to the command prompt, follow the directory, and type `build-nsf`.