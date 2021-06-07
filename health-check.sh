keys=('www' 'console' 'docs')
urls=('https://www.statsig.com' 'https://console.statsig.com' 'https://docs.statsig.com')


for index in "${!keys[@]}";
do
  key="${keys[index]}"
  url="${urls[index]}"

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
  echo $dateTime, $result >> $key"_report.log"
done
