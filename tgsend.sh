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
  formatted_msg+="${time_icon} *时间：* ${current_time}  \n\n"
  formatted_msg+="${notify_icon} *通知内容：* ${notify_content}  \n\n"

  echo -e "$formatted_msg|${host}|${user}" # 使用 -e 选项以确保换行符生效
}

telegramBotToken=${TELEGRAM_TOKEN}
telegramBotUserId=${TELEGRAM_USERID}
result=$(toTGMsg "$message_text")
formatted_msg=$(echo "$result" | awk -F'|' '{print $1}')
host=$(echo "$result" | awk -F'|' '{print $2}')
user=$(echo "$result" | awk -F'|' '{print $3}')

# 定义所有按钮的URL
if [[ "$BUTTON_URL" == "null" ]]; then
  button_url="https://panel10.serv00.com"
else
  button_url=${BUTTON_URL:-"https://webssh.dgfghh.ggff.net/#encoding=utf-8&hostname=panel10.serv00.com&username=sdfsfs&password=VjVYTWtyJmxvZF5mb1E3bHlQZig=&command=ss"}
fi

if [[ "$TELEGRAPH_URL" == "null" ]]; then
  telegraph_url="https://webssh.dgfghh.ggff.net/#encoding=utf-8&hostname=panel10.serv00.com&username=sdfsfs&password=VjVYTWtyJmxvZF5mb1E3bHlQZig=&command=ss"
else
  telegraph_url=${TELEGRAPH_URL:-"https://webssh.dgfghh.ggff.net/#encoding=utf-8&hostname=panel10.serv00.com&username=sdfsfs&password=VjVYTWtyJmxvZF5mb1E3bHlQZig=&command=ss"}
fi

if [[ "$NEW_USER_URL" == "null" ]]; then
  new_user_url="https://serv00.com/newuser"
else
  new_user_url=${NEW_USER_URL:-"https://serv00.com/newuser"}
fi

if [[ "$ADVANCED_SEARCH_URL" == "null" ]]; then
  advanced_search_url="https://serv00.com/search"
else
  advanced_search_url=${ADVANCED_SEARCH_URL:-"https://serv00.com/search"}
fi

if [[ "$VRAY_CLIENT_URL" == "null" ]]; then
  vray_client_url="https://serv00.com/vray"
else
  vray_client_url=${VRAY_CLIENT_URL:-"https://serv00.com/vray"}
fi

if [[ "$CLASH_CLIENT_URL" == "null" ]]; then
  clash_client_url="https://serv00.com/clash"
else
  clash_client_url=${CLASH_CLIENT_URL:-"https://serv00.com/clash"}
fi

if [[ "$MIHOMO_CLIENT_URL" == "null" ]]; then
  mihomo_client_url="https://serv00.com/mihomo"
else
  mihomo_client_url=${MIHOMO_CLIENT_URL:-"https://serv00.com/mihomo"}
fi

if [[ "$SINGBOX_CLIENT_URL" == "null" ]]; then
  singbox_client_url="https://serv00.com/singbox"
else
  singbox_client_url=${SINGBOX_CLIENT_URL:-"https://serv00.com/singbox"}
fi

if [[ "$WORKERS_PAGES_URL" == "null" ]]; then
  workers_pages_url="https://serv00.com/workers"
else
  workers_pages_url=${WORKERS_PAGES_URL:-"https://serv00.com/workers"}
fi

if [[ "$ORDER_STATUS_URL" == "null" ]]; then
  order_status_url="https://serv00.com/order"
else
  order_status_url=${ORDER_STATUS_URL:-"https://serv00.com/order"}
fi

URL="https://api.telegram.org/bot${telegramBotToken}/sendMessage"

# 处理所有URL的替换
for url_var in button_url telegraph_url new_user_url advanced_search_url vray_client_url clash_client_url mihomo_client_url singbox_client_url workers_pages_url order_status_url; do
  if [[ -n "$host" ]]; then
    eval "$url_var=\$(replaceValue \$$url_var HOST \$host)"
  fi
  if [[ -n "$user" ]]; then
    eval "$url_var=\$(replaceValue \$$url_var USER \$user)"
  fi
  if [[ -n "$PASS" ]]; then
    pass=$(toBase64 $PASS)
    eval "$url_var=\$(replaceValue \$$url_var PASS \$pass)"
  fi
  # 编码URL
  encoded_var="${url_var}_encoded"
  eval "$encoded_var=\$(urlencode \$$url_var)"
done

# 定义多按钮网格布局的reply_markup
reply_markup='{
    "inline_keyboard": [
      [
        {"text": "✨ serv00快速登入 ✨", "url": "'"${new_user_url_encoded}"'"}
      ],
      [
        {"text": "✨ webssh快速登入 ✨", "url": "'"${advanced_search_url_encoded}"'"}
      ],
      [
        {"text": "serv00官网", "url": "'"${vray_client_url_encoded}"'"},
        {"text": "搬瓦工官网", "url": "'"${clash_client_url_encoded}"'"}
      ],
      [
        {"text": "搬瓦工特价面板", "url": "'"${mihomo_client_url_encoded}"'"},
        {"text": "搬瓦工KVM面板", "url": "'"${singbox_client_url_encoded}"'"}
      ],
      [
        {"text": "✨ 哪吒面板 ✨", "url": "'"${workers_pages_url_encoded}"'"}
      ],
      [
        {"text": "天涯在线订阅层", "url": "'"${order_status_url_encoded}"'"}
      ],
      [
        {"text": "点击查看", "url": "'"${button_url_encoded}"'"}
      ],
      [
        {"text": "打开Terminal", "url": "'"${telegraph_url_encoded}"'"}
      ]
    ]
  }'

# 调试信息
echo "按钮结构: $reply_markup"

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
    echo "错误信息: $res"
  fi
f
