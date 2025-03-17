#!/bin/bash

message_text=$1

replaceValue() {
  local url=$1
  local target=$2
  local value=$3
  local result
  result=$(printf '%s' "$url" | sed "s|#${target}|${value//&/\\&}|g")
  echo "$result"
}

toBase64() {
  echo -n "$1" | base64
}

urlencode() {
  local input="$1"
  local output=""
  local length=${#input}
  for ((i = 0; i < length; i++)); do
    local char="${input:i:1}"
    case "$char" in
    [a-zA-Z0-9.~_-]) output+="$char" ;;
    *) output+="$(printf '%%%02X' "'$char")" ;;
    esac
  done
  echo "$output"
}

toTGMsg() {
  local msg=$1
  local title="*Serv00-play通知*"
  local host_icon="🖥️"
  local user_icon="👤"
  local time_icon="⏰"
  local notify_icon="📢"
  local server_icon="🌐"
  local home_icon="🏠"
  local panel_icon="📊"

  # 获取当前时间
  local current_time=$(date "+%Y-%m-%d %H:%M:%S")

  if [[ "$msg" != Host:* ]]; then
    local formatted_msg="${title}  \n\n"
    formatted_msg+="${time_icon} *时间：* ${current_time}  \n"
    formatted_msg+="${notify_icon} *通知内容：*    \n$msg  \n\n"
    echo -e "$formatted_msg"
    return
  fi

  local host=$(echo "$msg" | sed -n 's/.*Host:\([^,]*\).*/\1/p' | xargs)
  local user=$(echo "$msg" | sed -n 's/.*user:\([^,]*\).*/\1/p' | xargs)
  local notify_content=$(echo "$msg" | sed -E 's/.*user:[^,]*,//' | xargs)

  # 格式化消息内容，Markdown 换行使用两个空格 + 换行
  local formatted_msg="${title}  \n\n"
  formatted_msg+="${host_icon} *主机：* ${host}  \n"
  formatted_msg+="${user_icon} *用户：* ${user}  \n"
  formatted_msg+="${server_icon} *SSH/SFTP：* s10.serv00.com  \n"
  formatted_msg+="${home_icon} *主目录：* /usr/home/sdfsfs  \n"
  formatted_msg+="${panel_icon} *网页面板：* https://panel10.serv00.com/  \n"
  formatted_msg+="${time_icon} *时间：* ${current_time}  \n\n"
  formatted_msg+="${notify_icon} *通知内容：* ${notify_content}  \n\n"

  echo -e "$formatted_msg|${host}|${user}" # 使用 -e 选项以确保换行符生效
}

# 设置登录信息
LOGIN="sdfsfs"
PASSWORD="V5XMkr&lod^foQ7lyPf("
SSH_SERVER="s10.serv00.com"
HOME_DIR="/usr/home/sdfsfs"
WEBPANEL="https://panel10.serv00.com/"

telegramBotToken=8079327972:AAGx0-S-mGCurYiJrZ5LcTVZu7Te-CnwUgU
telegramBotUserId=1137724729
result=$(toTGMsg "$message_text")
formatted_msg=$(echo "$result" | awk -F'|' '{print $1}')
host=$(echo "$result" | awk -F'|' '{print $2}')
user=$(echo "$result" | awk -F'|' '{print $3}')

if [[ "$BUTTON_URL" == "null" ]]; then
  button_url="$WEBPANEL"
else
  button_url=${BUTTON_URL:-"$WEBPANEL"}
fi

URL="https://api.telegram.org/bot${telegramBotToken}/sendMessage"

if [[ -n "$host" ]]; then
  button_url=$(replaceValue $button_url HOST $host)
fi
if [[ -n "$user" ]]; then
  button_url=$(replaceValue $button_url USER $user)
fi
if [[ -n "$PASSWORD" ]]; then
  pass=$(toBase64 $PASSWORD)
  button_url=$(replaceValue $button_url PASS $pass)
fi
if [[ -n "$HOME_DIR" ]]; then
  button_url=$(replaceValue $button_url HOME $HOME_DIR)
fi
if [[ -n "$SSH_SERVER" ]]; then
  button_url=$(replaceValue $button_url SSH $SSH_SERVER)
fi

encoded_url=$(urlencode "$button_url")
#echo "encoded_url: $encoded_url"

# 创建多个按钮
reply_markup='{
    "inline_keyboard": [
      [
        {"text": "登录面板", "url": "'"${WEBPANEL}"'"}
      ],
      [
        {"text": "SSH连接", "url": "ssh://'"${LOGIN}"'@'"${SSH_SERVER}"'"},
        {"text": "SFTP连接", "url": "sftp://'"${LOGIN}"'@'"${SSH_SERVER}"'"}
      ]
    ]
  }'

#echo "reply_markup: $reply_markup"
#echo "telegramBotToken:$telegramBotToken,telegramBotUserId:$telegramBotUserId"
if [[ -z ${telegramBotToken} ]]; then
  echo "未配置TG推送"
else
  res=$(curl -s -X POST "https://api.telegram.org/bot${telegramBotToken}/sendMessage" \
    -d chat_id="${telegramBotUserId}" \
    -d parse_mode="Markdown" \
    -d text="$formatted_msg" \
    -d reply_markup="$reply_markup")
  if [ $? == 124 ]; then
    echo 'TG_api请求超时,请检查网络是否重启完成并是否能够访问TG'
    exit 1
  fi
  #echo "res:$res"
  resSuccess=$(echo "$res" | jq -r ".ok")
  if [[ $resSuccess = "true" ]]; then
    echo "TG推送成功"
  else
    echo "TG推送失败，请检查TG机器人token和ID"
  fi
fi
