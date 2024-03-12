## Goal of Project
This is an attempt to create a wordle game in Zig and possibly in future a wordle solver.

## What is wordle
Wordle is a web-based word game where players have six attempts to guess a five-letter word, with feedbackgiven for each guess in the form of colored tiles indicating when letters match or occupy the correct position.

## Naive Implementation
1. Download a wordle dictionary containing most of the five-letter words used in wordle.
2. Make a Trie data structure that can be used to store the words from the dictionary.txt file
3. Make a wordle board by making a 6x5 array of nullable "Cell" values. A Cell is a struct that holds a nullable enum color and a nullable u8 value, both of which are initialized to null.

## Current State of Project
- Gives the user 6 guesses to correctly get the word
- After each guess the user gets feedback on how close their guess is to the word
- The game ends when the user guesses the word correctly
- The game ends when the user runs out of guesses
