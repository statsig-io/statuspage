KEYSARRAY=( $KEYS )
URLSARRAY=( $URLS )


echo $KEYSARRAY
echo $URLSARRAY
echo ${#KEYSARRAY[@]}
echo "***********************"

for (( index=0; index < ${#KEYSARRAY[@]}; index++))
do
  key="${KEYS[index]}"
  url="${URLS[index]}"

  echo $key
  echo $url

  for i in 1 2 3 4; 
  do
    response=$(curl --write-out '%{http_code}' --silent --output /dev/null $url)
    if [ "$response" -eq 200 ] || [ "$response" -eq 202 ] || [ "$response" -eq 301 ] || [ "$response" -eq 307 ]; then
      result="success"
    else
      result="failed"
    fi
    if [ "$result" = "success" ]; then
      break
    fi
    sleep 5
  done
  dateTime=$(date +'%Y-%m-%d %H:%M')
  echo $dateTime, $result >> "${key}_report.log"
done

git config --global user.name 'Vijaye Raji'
git config --global user.email 'vijaye@statsig.com'
git add -A
git commit -am 'Status logs - automated'
git push

