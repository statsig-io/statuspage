KEYSARRAY=()
URLSARRAY=()

urlsConfig="./urls.cfg"
while read -r line
do
  echo "$line"
  IFS='=' read -ra TOKENS <<< "$line"
  echo $TOKENS

  KEYSARRAY+=(${TOKENS[0]})
  URLSARRAY+=(${TOKENS[1]})
done < "$urlsConfig"


echo "***********************"
echo $KEYSARRAY
echo $URLSARRAY
echo ${#KEYSARRAY[@]}
echo "***********************"

mkdir -p logs

for (( index=0; index < ${#KEYSARRAY[@]}; index++))
do
  key="${KEYSARRAY[index]}"
  url="${URLSARRAY[index]}"

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
  echo $dateTime, $result >> "logs/${key}_report.log"
done

git config --global user.name 'Vijaye Raji'
git config --global user.email 'vijaye@statsig.com'
git add -A
git commit -am 'Status logs - automated'
git push

