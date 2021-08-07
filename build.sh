#!/usr/bin/env sh

COL='\033[0;37m'
RED='\033[1;31m'
NC='\033[0m' # No Color

git clone https://github.com/netbox-community/netbox

#cp django/env.dev temp/environment.prod
printf "SECRET_KEY=\'%s\'\n" $(./lib/secret_key.py) > temp/environment.prod

while
  printf "${COL}superuser username:${NC}"
  read username
  [ -z "$username" ]
do :; done

stty -echo
while
  printf "${COL}superuser password:${NC}"
  read password
  printf "\n"
  [ -z "$password" ]
do :; done

while
  printf "${COL}superuser password (repeat):${NC}"
  read password1
  printf "\n"
  [ -z "$password1" ]
do :; done

stty echo

if [ "$password" != "$password1" ]
then
  printf "\n${RED}Passwords do not match${NC}\n\n"
  exit 1
fi

printf "\n"

printf "${COL}superuser e-mail address [netbox@netbox.local]:${NC}"
read email

if [ -z "$email" ]
then
   printf "\n${COL}No e-mail address entered, defaulting to ${NC}netbox@netbox.local\n"
   email="netbox@netbox.local"
fi

printf "DJANGO_SUPERUSER_USERNAME=%s\n" $username >> temp/environment.prod
printf "DJANGO_SUPERUSER_PASSWORD=%s\n" $password >> temp/environment.prod
printf "DJANGO_SUPERUSER_EMAIL=%s\n" $email >> temp/environment.prod

# Generate self-signed certificate for localhost
printf "\nGenerating self-signed certificate for localhost\n"
openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 -subj "/C=EU/ST=N\/A/L=N\/A/O=SURF/OU=Thunderlab/CN=localhost" -keyout ./temp/netbox-localhost.key  -out ./temp/netbox-localhost.crt

printf "\n${COL} Building volumes, images, and containers${NC}\n\n"
docker-compose up --build --remove-orphans -d

# Initialize the ddosdb Django App
#printf "\n${COL} Collecting Django static files${NC}\n\n"
#docker-compose exec ddosdb python manage.py collectstatic --noinput
#
#printf "\n${COL} Applying Django migrations${NC}\n\n"
#docker-compose exec ddosdb python manage.py migrate --noinput

#printf "\n${COL} Creating Django superuser${NC}\n\n"
#docker-compose exec ddosdb python manage.py createsuperuser --noinput

#printf "\n${COL} Setting up default Celery (beat) tasks ${NC}\n\n"
#docker-compose exec ddosdb python manage.py celery

printf "\n\n${COL}** Finished **\n\n"
printf "Stop netbox by executing 'docker-compose down' in this directory\n"
printf " 'docker-compose up' will restart netbox\n"
printf " 'docker-compose up --build' will rebuild and restart\n"
printf "\nTo reset netbox to factory settings: \n"
printf " Run 'docker-compose down' to bring down the containers\n"
printf " Then 'docker system prune -a --volumes' to delete all data \n"
printf " Followed by './build.sh' to rebuild & restart ${NC}\n\n"
