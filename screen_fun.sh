#### Written by Patrick Kennedy. License: MIT
# Prototype that uses a mysql database to play music depending on screen state.
# This is an early prototype, but it does demonstrate some cool stuff with
# shell scripting and linux fun.

# install xscreensaver: 
# sudo apt-get install xscreensaver xscreensaver-data-extra xscreensaver-gl-extra
#

# usage: ./screen 1
#        ./screen
#        ./screen 30
#############################################
# $ sudo apt-get install procps # for pgrep 

killall xscreensaver-command > /dev/null 2>&1 
xscreensaver -no-splash    & > /dev/null 2>&1
#xscreensaver-command       & > /dev/null 2>&1
# above commented line works, but the music ain't playing! 

#exit
# count loops
c=0
x=0

###
# https://stackoverflow.com/questions/8055694/how-to-execute-a-mysql-command-from-a-shell-script
# Best practice is to store user and password in ~/.my.cnf, so you don't enter it on the command line:

#[client]
#user = root
#password = XXXXXXXX
# So, try it later

# create database screen_db;
# use screen_db;

#CREATE TABLE songs(
#  id int NOT NULL AUTO_INCREMENT,
#  song_id int NULL,
#  file_and_path varchar(255) NOT NULL,
#  PRIMARY KEY (id)
#);


# add backslashes around song (which don't actually get posted into db)

#INSERT INTO songs (song_id,file_and_path) VALUES ('1','/home/joe/1PK/My\ Music/Van\ Halen\ -\ 1984/\'01 - 1984.mp3\'');

#INSERT INTO songs (song_id,file_and_path) VALUES ('2','/home/joe/1PK/My\ Music/Van\ Halen\ -\ 1984/\'02 - Jump.mp3\'');

#INSERT INTO songs (song_id,file_and_path) VALUES ('3','/home/joe/2PK/music/\'Blue Oyster Cult - Dont Fear The Reaper (Audio)-Dy4HA3vUv2c.webm\'');



# updating existing data via mysql
# update songs set file_and_path = '/home/joe/1PK/My Music/Van Halen - 1984/\'01 - 1984.mp3\'' where id = 1;

###


lock() {
    # Log this somewhere with `date` instead of just echoing.
    echo `uname -n` screen is now locked 
    # Do other things here, like stop music playback & mute speakers.
}

unlock() {
    # Log this somewhere with `date` instead of just echoing.
    # Do other things here, like resume music playback & unmute speakers.
    #killall mpg123 > /dev/null 2>&1
    #killall totem  > /dev/null 2>&1
    
    echo `uname -n` screen is now unblank `date`
    
    killall xscreensaver-command > /dev/null 2>&1

}

screensaver() { echo `uname -n` screensaver time per blank mode x=0

    # Do other things here, like resume music playback & unmute speakers.
    # will play 3 songs and run out; will play 3 songs again when screensaver is called again
    # adding a field to the database can allow a choice of app to use to play media
    # could use a while true loop to support continuous play list
return
    if [[ $x -lt 1 ]] ; then
      x=$((x+1));
      echo var is $x
      #song="mysql -uroot -D screen_db -e -s -N 'SELECT file_and_path FROM songs where m_id= $x'"

      ## query 1
      song=`mysql -uroot -pMyPassword123 screen_db -s -N -e 'SELECT file_and_path FROM songs where id='$x` > /dev/null 2>&1
      ## must strip inner single quotes around song (or around anything else)
      song=`echo $song | tr -d "'"`
      #echo "Playing ===> $song" 
      totem "$song"


      # query 2
      x=$((x+1));
      ##query  # use another var for 1st line, and then don't need to repeat
      song=`mysql -uroot -pMyPassword123 screen_db -s -N -e 'SELECT file_and_path FROM songs where id='$x` > /dev/null 2>&1
      ## must strip inner single quotes around song (or around anything else)
      song=`echo $song | tr -d "'"` 
      totem "$song"

      ## query 3
      x=$((x+1));
      ##query  # use another var for 1st line, and then don't need to repeat
      song=`mysql -uroot -pMyPassword123 screen_db -s -N -e 'SELECT file_and_path FROM songs where id='$x` > /dev/null 2>&1
      ## must strip inner single quotes around song (or around anything else)
      song=`echo $song | tr -d "'"` 
      totem "$song"



      #mpg123 ~/1PK/My\ Music/Van\ Halen\ -\ 1984/'01 - 1984.mp3' > /dev/null 2>&1
      #mpg123 ~/1PK/My\ Music/Van\ Halen\ -\ 1984/'02 - Jump.mp3' > /dev/null 2>&1
      #totem ~/2PK/music/'Blue Oyster Cult - (Don'\''t Fear) The Reaper (Audio)-Dy4HA3vUv2c.webm'  > /dev/null 2>&1

    fi
    if [[ $x -eq 3 ]] ; then
      x=0
    fi

}

#xscreensaver -no-splash &  
# To lock it if you want, add the next line
# This is currently my preferred location to lock things;
# And apparently an & is not required!
xscreensaver-command -l

xscreensaver-command -watch | while read a; do
    echo "$a" | grep -q '^LOCK' && lock
    echo "$a" | grep -q '^UNBLANK' && unlock
    echo "$a" | grep -q '^BLANK' && screensaver
done &

# use ctrl+c to break out (but log in first, if lock is used above)

sleep_length=$1

re='^[0-9]+$'

if ! [[ $1 =~ $re  ]] ; then
  sleep_length=60  # if not num, then use set value
  echo Set to 1 minute for sleeping...
fi

#echo "sleep for: " $sleep_length
#sleep 2


xscreensaver-command -activate
#xscreensaver-command  -activate &

sleep $sleep_length

while true
do
  #echo "sleep for: " $sleep_length
  #sleep 2

  c=$((c+1));
  echo $c
  xscreensaver-command -quiet -cycle 2> /dev/null
  xscreensaver-command -next
  
  sleep $sleep_length
done

