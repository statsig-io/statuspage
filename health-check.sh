# In the original repository we'll just print the result of status checks,
# without committing. This avoids generating several commits that would make
# later upstream merges messy for anyone who forked us.
commit=true
origin=$(git remote get-url origin)
if [[ $origin == *statsig-io/statuspage* ]]
then
  commit=false
fi

KEYSARRAY=()
URLSARRAY=()

urlsConfig="./urls.cfg"
echo "Reading $urlsConfig"
while read -r line
do
  echo "  $line"
  IFS='=' read -ra TOKENS <<< "$line"
  KEYSARRAY+=(${TOKENS[0]})
  URLSARRAY+=(${TOKENS[1]})
done < "$urlsConfig"

echo "***********************"
echo "Starting health checks with ${#KEYSARRAY[@]} configs:"

mkdir -p logs

for (( index=0; index < ${#KEYSARRAY[@]}; index++))
do
  key="${KEYSARRAY[index]}"
  url="${URLSARRAY[index]}"
  echo "  $key=$url"

  for i in 1 2 3 4; 
  do
    server=$(curl --head --silent --connect-timeout 15 $url | grep --only-matching --perl-regexp --ignore-case 'server: \K.+')
    response=$(curl --write-out '%{http_code}' --silent --output /dev/null $url)
    if [ "$response" -eq 200 ] || [ "$response" -eq 202 ] || [ "$response" -eq 301 ] || [ "$response" -eq 302 ] || [ "$response" -eq 307 ]; then
      result="success"
    else
      result="failed"
    fi
    if [ "$result" = "failed" ]; then
echo "From: Statsig's Open-Source Status Page <$MAILFROM>
To: Izumi Sena Sora <$MAILRCPT>
Subject: Status Notification from Statsig's Open-Source Status Page
Date: $date
Mime-Version: 1.0
Content-Type: text/html; charset=utf-8
<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">
<html>
  <head>
    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\" />
    <title>Statsig's Open-Source Status Page</title>
    <style type=\"text/css\">
      body{width:100% !important;} .ReadMsgBody{width:100%;} .ExternalClass{width:100%;} /* Force Hotmail to display emails at full width */
      body{-webkit-text-size-adjust:none;} /* Prevent Webkit platforms from changing default text sizes. */
      body{margin:0; padding:0;}
      img{border:0; height:auto; line-height:100%; outline:none; text-decoration:none;}
      table td{border-collapse:collapse;}
      #backgroundTable{height:100% !important; margin:0; padding:0; width:100% !important;}

      body, #backgroundTable{
        background-color:#FAFAFA;
      }

      #templateContainer{
        border: 1px solid #DDDDDD;
      }

      h1, .h1{
        color:#202020;
        display:block;
        font-family:Arial;
        font-size:34px;
        font-weight:bold;
        line-height:100%;
        margin-top:0;
        margin-right:0;
        margin-bottom:10px;
        margin-left:0;
        text-align:center;
      }

      h2, .h2{
        color:#202020;
        display:block;
        font-family:Arial;
        font-size:30px;
        font-weight:bold;
        line-height:100%;
        margin-top:0;
        margin-right:0;
        margin-bottom:10px;
        margin-left:0;
        text-align:center;
        opacity:0.7;
      }

      h3, .h3{
        color:#202020;
        display:block;
        font-family:Arial;
        font-size:26px;
        font-weight:bold;
        line-height:100%;
        margin-top:0;
        margin-right:0;
        margin-bottom:10px;
        margin-left:0;
        text-align:center;
        opacity:0.7;
      }

      h4, .h4{
        color:#202020;
        display:block;
        font-family:Arial;
        font-size:22px;
        font-weight:bold;
        line-height:100%;
        margin-top:0;
        margin-right:0;
        margin-bottom:10px;
        margin-left:0;
        text-align:center;
        opacity:0.7;
      }

      #templateContainer, .bodyContent{
        background-color:#FFFFFF;
      }

      .bodyContent div{
        color:#505050;
        font-family:Arial;
        font-size:14px;
        line-height:150%;
        text-align:left;
      }

      .bodyContent div a:link, .bodyContent div a:visited, /* Yahoo! Mail Override */ .bodyContent div a .yshortcuts /* Yahoo! Mail Override */{
        color:#336699;
        font-weight:normal;
        text-decoration:underline;
      }

      .bodyContent img{
        display:inline;
        height:auto;
      }

      #templateFooter{
        background-color:#FFFFFF;
        border-top:0;
      }

      .footerContent div{
        color:#707070;
        font-family:Arial;
        font-size:12px;
        line-height:125%;
        text-align:left;
      }

      .footerContent div a:link, .footerContent div a:visited, /* Yahoo! Mail Override */ .footerContent div a .yshortcuts /* Yahoo! Mail Override */{
        color:#336699;
        font-weight:normal;
        text-decoration:underline;
      }

      .footerContent img{
        display:inline;
      }

      #utility div{
        text-align:center;
      }

      }

    </style>
  </head>
  <body leftmargin=\"0\" marginwidth=\"0\" topmargin=\"0\" marginheight=\"0\" offset=\"0\">
    <center>
      <table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" height=\"100%\" width=\"100%\" id=\"backgroundTable\">
        <tr>
          <td align=\"center\" valign=\"top\">
            <table border=\"0\" cellpadding=\"10\" cellspacing=\"0\" width=\"600\" id=\"templatePreheader\">
                <tr>
                    <td valign=\"top\" class=\"preheaderContent\"></td>
                </tr>
            </table>
            <table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" width=\"600\" id=\"templateContainer\">
              <tr>
                <td align=\"center\" valign=\"top\">
                  <table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" width=\"600\" id=\"templateBody\">
                    <tr>
                      <td valign=\"top\" class=\"bodyContent\">
                        <table border=\"0\" cellpadding=\"20\" cellspacing=\"0\" width=\"100%\">
                          <tr>
                            <td valign=\"top\">
                              <div>
                                <h1 class=\"h1\">Incident Update</h1>
                                <h4 class=\"h4\">Statsig's Open-Source Status Page</h4>
                                <br />
                                <strong>Current Status:</strong> Service Disruption
                                <br />
                                <!-- Operational -->
                                <!-- Degraded Performance -->
                                <!-- Partial Service Disruption -->
                                <!-- Service Disruption -->
                                <strong>Started:</strong> $date
                                <br />
                                <strong>Resolved:</strong> 
                                <br />
                                <br />
                                <strong>Affected Infrastructure</strong>
                                <br />
                                <strong>Components:</strong> Website
                                <br />
                                <strong>Locations:</strong> $server
                                <br />
                                <br />
                                <strong>Update:</strong>
                                <p>${key} (${url}) Getting $response Errors.</p>
                                <br />
                              </div>
                            </td>
                          </tr>
                        </table>
                      </td>
                    </tr>
                  </table>
                </td>
              </tr>
              <tr>
                <td align=\"center\" valign=\"top\">
                  <table border=\"0\" cellpadding=\"10\" cellspacing=\"0\" width=\"600\" id=\"templateFooter\">
                    <tr>
                      <td valign=\"top\" class=\"footerContent\">
                        <table border=\"0\" cellpadding=\"10\" cellspacing=\"0\" width=\"100%\">
                          <tr>
                            <td colspan=\"2\" valign=\"middle\" id=\"utility\">
                              <div>
                                <p>Learn More <a href=\"https://github.com/statsig-io/statuspage/\">Statsig's Open-Source Status Page</a></p>
                              </div>
                            </td>
                          </tr>
                        </table>
                      </td>
                    </tr>
                  </table>
                </td>
              </tr>
            </table>
          </td>
        </tr>
      </table>
    </center>
  </body>
</html>" > mail.txt
      echo "    ***********************"
      echo "    Response $response So Sending Alert"
      echo "    ***********************"
      curl --ssl-reqd --silent smtps://$SMTPS --user "$USERNAME:$PASSWORD" --mail-from $MAILFROM --mail-rcpt $MAILRCPT --upload-file mail.txt --connect-timeout 15
      rm mail.txt
      break
    fi
    if [ "$result" = "success" ]; then
      break
    fi
    sleep 5
  done
  dateTime=$(date +'%Y-%m-%d %H:%M')
  if [[ $commit == true ]]
  then
    echo $dateTime, $result >> "logs/${key}_report.log"
    # By default we keep 2000 last log entries.  Feel free to modify this to meet your needs.
    echo "$(tail -2000 logs/${key}_report.log)" > "logs/${key}_report.log"
  else
    echo "    $dateTime, $result"
  fi
done

if [[ $commit == true ]]
then
  # Let's make Vijaye the most productive person on GitHub.
  git config --global user.name 'Vijaye Raji'
  git config --global user.email 'vijaye@statsig.com'
  git add -A --force logs/
  git commit -am '[Automated] Update Health Check Logs'
  git push
fi
