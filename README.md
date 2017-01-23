# Piano
This was a project done for my Digital Logic course in my 2nd year of study
This project is to be implemented with a DE1-SOC FPGA, and uses the GPIO pins to communicate with some simple buttons which act as the keyboard
This game is a fully functioning piano with six keys, and combination of the keys can be pressed to acheive any chord
The game implements a memory attribute, after pressing a key on the FPGA it will initialize the next level
The level goes as follows:
- Play sqeuence of tones to user
- User plays sqeuence of tones back, in order and with similar timing to ensure correctness
- if correct, the user moves on to the next level
- if incorrect, the user will repeat the level and lose a life
Upon completeing all the levels, the user is played an end tone and is awarded with the victory screen
Upon losing all lives, the user is displayed a game over screen
