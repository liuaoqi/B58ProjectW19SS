# B58ProjectW19SS

Project Plan
--------

Project Title: Simon Says


Provide a one paragraph description of your project:
A four light memory-based game where the player must remember the sequence of lights and press out the pattern accordingly using the keys. The pattern gets bigger and bigger as the game progresses. The game will have the level displayed on the hex display that increases on each turn as well as a message the indicates whether the level is passed or the game is lost. If the player gets the pattern wrong, they will lose the game, the level will freeze and the losing message will be displayed. The game will also have 3 modes: Easy, Medium, Hard (determined by the position of the switches) that determine the speed at which the pattern is displayed. If time permits, might add sounds as well.

What is your plan for the first week? Get the lights to display the randomized pattern according to the three different speeds. At this point, winning that round would just be pressing one key.


What is your plan for the second week? Implement pattern-key matching to make sure player presses out the right pattern. Also, ensure that the scoreboard displays the score accordingly.


What is your plan for the third week? Fix any glitches and bugs that might be present. If that is done, then maybe include the sound feature where each light has a different pitch of sound.


What is your backup plan if things don’t work out as planned? If we cannot randomize, we will come up with some patterns. The patterns might have to be at a fixed length instead of getting bigger and bigger. Might have to not include VGA monitor if things don't work out regarding that.



Weekly Reports
--------------

Week 1:
 - Managed to randomize the order of the LEDs lighting up with an LFSR (linear feedback shift register) module (i.e. there is no set pattern to the lighting up and the next LED to light up is unpredictable). This is useful for our game since the whole point is to generate a random pattern that the player must follow along with.
- Had trouble getting the Rate Divider to work (all four LEDs light up dimly at the same time, no visible changes occur when moving switches and all randomization is lost once the Rate Divider is added); will continue to debug and improve code since the different speed option is an important part of the project.
- When reset is 0, LED0 is brightly lit up by default. Do not know where this error is originating from, will analyze code to fix it.

Week 2:
- Modified the randomization so that the pattern is determined right at the beginning on start up (i.e. still using a LFSR but instead of 2 bits it's now 20 bits (every 2 bits correspoding to either LEDR0, LEDR1, LEDR2, LEDR3)).
- Repeatedly used a shift register to get the 2 bits that correspond to each LED part of the pattern, using separate registers to store the pattern as it progresses (i.e. at the beginning, first 2 bits is stored, then first 4 bits is stored, then first 6 bits ... until all 20 bits are stored). Having trouble getting this to work.
- Still had trouble getting Rate Divider to work so temporarily used a manual clock; will continue to make modifications for it to work.
- LED0 is no longer lit up by default. Problem fixed.
- Had trouble verifying whether the KEY inputs match the sequence of lights. Will comtinue to debug and improve code since this is also a vital part of the project.

Week 3:
- Created module called load_pattern to load every 2 bits of the pattern into a light variable that is translated into the specific LED in the main module (i.e. light = 2'b10 is LEDR3).
- Created module called checkifwin that checks if the key pressed matches up to the light of the pattern (i.e. KEY[2] is 2'b01 so we check if the light is 2'b01).
- Added 'DIED' and 'GOOD' to be displayed on the hex display.
- Still had trouble getting Rate Divider to work - using manual clock temporarily.
- Removed lives meter but instead added a display to show the level currently being played.



References
----------
<In this space clearly indicate all external sources used in this project. If you used anyone else's code (from previous B58 projects or other sources) clearly indicate what you used and where you found it. Usage of any material not credited in this space will be considered plagiarism. It is absolutely OK and expected to update this section as you progress in the projected.

Make sure to document what you added on top of the existing work, especially if you work with a previous project. What is it that YOU added?>

1. used morsecode.v from CSCB58 Lab 4 as the base template but kept only the RateDivider portion in the end and changed everything else with our own code
2. used top module from flasher.v from CSCB58 Lab 4 to help get different speeds
3. hex_display from CSCB58 Lab 3
4. randomizer from: https://www.cnblogs.com/BitArt/archive/2012/12/22/2827005.html 
