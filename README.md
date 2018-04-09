# gateHero
A 4-key "mania"-style vertical scrolling rhythm game written in Verilog for the Altera Cyclone V DE1-SoC 5CSEMA5F31C6 board.

### Playing the Game
Players start by resetting the game with KEY[0] and pressing KEY[3] to start. Notes (coloured rectangles) will begin to fall from each of the four lanes on-screen, and players need to press the corresponding keys (D, F, J, and K, respectively, on a PS/2 keyboard), mapped to those lanes, when the notes reach the bottom of the screen to gain points.

In addition to the VGA screen, LEDR[9:6] will light up for each lane representing when notes have reached the bottom of the screen (and thus, should be hit by pressing the corresponding key on the keyboard). LEDR[3:0] will light up when the corresponding keys on the keyboard are pressed.

### Choosing a Track and Scroll Speed
The song (pattern of notes that fall from the top of the screen) can be changed with SW[9:8]. There are three different tracks: one for 2'b11, one for 2'b00, and one for 2'b01/2'b10. The scroll speed of the track (how fast the notes fall from the top of the screen) can be adjusted as well with SW[1:0]. There are two options: 2'b01/2'b10 for normal, and 2'b11 for fast.

### Scoring System
When a note is hit at the judgement position at the bottom of the screen, a "Perfect" score is given, and the player is awarded with two points. If a note is hit early (when the note is just above the judgement position), a "Good" score will be given and the player awarded with one point. No points are awarded for late hits (after the note falls off the screen) or misses (not hitting the note at all). Points are displayed in hexadecimal on HEX1 and HEX0.

In addition to score, the game keeps track of combos (sequences of notes hit without a miss).  HEX3 and HEX2 keep track of the player's current combo, and HEX5 and HEX4 keep track of the player's longest combo for that particular run. Like the points, these values are displayed in hex.

Long notes/holds ("stacks" or multiple notes immediately one after another) gain score (and combo) by pressing and holding the note corresponding to the lane in which the long note falls in. Points and combo will be awarded as long as the respective key is pressed, and a break in the hold (letting go and pressing again) will result in a combo break (resetting the current combo to 0).

### References and Acknowledgements
The VGA adapter code, as well as the PS/2 keyboard code, was taken from the University of Toronto's CSC258 course resources. All other code is original. The background .mif file was converted with a tool used from the same course resources.
