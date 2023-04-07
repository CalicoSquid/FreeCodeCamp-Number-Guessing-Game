#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guessing_game -t --no-align -c"

#echo -e "\n~~~ Random Number Guessing Game ~~~\n"

WELCOME_FUNCTION() {
# Gets random number between 1 - 1000  
RANDOM_NUMBER=$[ $RANDOM % 1000 + 1]

echo "Enter your username:"
read USERNAME
# Look for user in database
GET_USER=$($PSQL "SELECT username FROM users WHERE username = '$USERNAME'")
#If not there...
if [[ -z $GET_USER ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER=$($PSQL "INSERT INTO users(username,games_played,best_game) VALUES('$USERNAME',0,0)")
  # Start game!!
  #echo -e "\n~~~ Lets begin!! ~~~\n"
  ADD_GAME_PLAYED=$($PSQL "UPDATE users SET games_played = games_played + 1 WHERE username='$USERNAME'")
  echo "Guess the secret number between 1 and 1000:"
  NUMBER_GUESSER_GAME $USERNAME $RANDOM_NUMBER
# IOf user already exists in database  
else
  #Get games played
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username = '$USERNAME'")
  # Get best score
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username = '$USERNAME'")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  # Start game!!
  #echo -e "\n~~~ Lets begin!! ~~~\n"
  ADD_GAME_PLAYED=$($PSQL "UPDATE users SET games_played = games_played + 1 WHERE username='$USERNAME'")
  echo "Guess the secret number between 1 and 1000:"
  NUMBER_GUESSER_GAME $USERNAME $RANDOM_NUMBER
fi

}

GUESS_COUNTER=0

NUMBER_GUESSER_GAME() {
# Get users guess
read GUESS
# If guess is not an integer
if [[ ! $GUESS =~ ^[0-9]*$ ]]
then
  # Restart function  
  echo "That is not an integer, guess again:"
  NUMBER_GUESSER_GAME $1 $2
fi

# Now that a number has been entered increment the counter
GUESS_COUNTER=$(( GUESS_COUNTER + 1 ))

# If Guess is high
if [[ $GUESS > $2  ]]
then
  echo "It's lower than that, guess again:"
  NUMBER_GUESSER_GAME $1 $2
#I If guess is low  
elif [[ $GUESS < $2 ]]
then
  echo "It's higher than that, guess again:"
  NUMBER_GUESSER_GAME $1 $2
# Correct guess!!  
else  
  echo "You guessed it in $GUESS_COUNTER tries. The secret number was $2. Nice job!"
  # Get previous best score
  GET_BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username = '$1'")
  #Check if current game is better
  if [[ $GUESS_COUNTER < $GET_BEST_GAME ||  $GET_BEST_GAME == 0 ]]
  then 
    # ...and update best_game counter if it is!
    SET_BEST_GAME=$($PSQL "UPDATE users SET best_game = $GUESS_COUNTER WHERE username = '$1'")
  fi
fi
}


WELCOME_FUNCTION
