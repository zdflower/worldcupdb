#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo $($PSQL "TRUNCATE teams, games;")
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
                      do
                        # teams
                        if [[ $WINNER != "winner" ]]
                           then
                             #pedís el team_id para el equipo de winner, si no existe el registro, lo tenés que ingresar
                             TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
                             if [[ -z $TEAM_ID ]]
                             then
                               # insertar
                               INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")

                                if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
                                then
                                  echo "Inserted into teams, $WINNER"
                                fi

                             fi

                             # el equipo oponente.
                             TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
                             if [[ -z $TEAM_ID ]]
                             then
                               # insertar
                               INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
                             
                               # chequeás que esté bien y mostrás un mensaje
                               if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
                                then
                                  echo "Inserted into teams, $OPPONENT"

                               fi
                             fi
                        # conviene guardar el team_id del winner para después usarlo abajo en la búsqueda del game
            WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
                        # también el team_id del opponent para incluirlo en la del game
            OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
                        
                        # games
# ves si ya está el game donde año = $YEAR AND round = $ROUND AND winner = $WINNER o no.
                          GAME_ID=$($PSQL "SELECT game_id FROM games WHERE year=$YEAR AND round='$ROUND' AND winner_id=$WINNER_ID")
                          if [[ -z $GAME_ID ]]
                          then
                            #insertar el game
                            INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
                            # chequeás si fue bien
                            if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
                            then
                              echo "Inserted into games, $YEAR $ROUND $WINNER $OPPONENT"
                            fi
                          fi
                      fi
                      done
