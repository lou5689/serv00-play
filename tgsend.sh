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

# 定义基本按钮URL
button_url=${BUTTON_URL:-"https://panel10.serv00.com"}
telegraph_url=${TELEGRAPH_URL:-"https://status.bwgyhw.cn/"}
new_user_url=${NEW_USER_URL:-"https://panel10.serv00.com"}
webssh_url=${WEBSSH_URL:-"https://webssh.dgfghh.ggff.net/#encoding=utf-8&hostname=panel10.serv00.com&username=sdfsfs&password=VjVYTWtyJmxvZF5mb1E3bHlQZig=&command=ss"}
serv00_url=${SERV00_URL:-"https://serv00.com"}
bwh_url=${BWH_URL:-"https://bandwagonhost.com/clientarea.php"}
bwh_special_url=${BWH_SPECIAL_URL:-"https://jgluul.afdsfddffasdsd.sbs/jbkljkj"}
bwh_kvm_url=${BWH_KVM_URL:-"https://sub.sghnfjgf.filegear-sg.me/dsfdg568"}
nezha_url=${NEZHA_URL:-"https://nazha1.dgfghh.ggff.net/"}
tianya_url=${TIANYA_URL:-"https://status.eooce.com"}
tcp_ping_url="https://tcp.ping.pe"

# 定义新增的按钮URL
server_monitor_url="https://github.com/search?q=v2ray+free&type=repositories&s=stars&o=desc"
traffic_stats_url="https://fofa.info/result?qbase64=Ym9keT0i6Ieq5Yqo5oqT5Y%20WdGfpopHpgZPjgIHorqLpmIXlnLDlnYDjgIHlhazlvIDkupLogZTnvZHkuIrnmoRzc%20OAgXNzcuOAgXZtZXNz44CBdHJvamFu6IqC54K55L%20h5oGvIg%3D%3D"
system_update_url=${SYSTEM_UPDATE_URL:-"https://support.euserv.com/index.iphp?sess_id=99393606a84f885af7c3f633010327bb120851171791743474782&action=show_default"}
firewall_config_url=${FIREWALL_CONFIG_URL:-"$bwh_url/firewall"}
node_manage_url=${NODE_MANAGE_URL:-"$bwh_special_url/manage"}
subscription_manage_url=${SUBSCRIPTION_MANAGE_URL:-"$bwh_kvm_url/subscription"}
backup_restore_url=${BACKUP_RESTORE_URL:-"$webssh_url"}
ip_manage_url=${IP_MANAGE_URL:-"$tcp_ping_url/manage"}
resource_usage_url=${RESOURCE_USAGE_URL:-"$nezha_url/usage"}
service_status_url=${SERVICE_STATUS_URL:-"$telegraph_url/status"}

# 确保按钮URL不为空，设置默认值
if [[ -z "$button_url" || "$button_url" == "null" ]]; then
  button_url="https://serv00.com"  # 设置默认URL
fi

# URL替换逻辑
if [[ -n "$host" ]]; then
  # 原有URL替换
  button_url=$(replaceValue "$button_url" HOST "$host")
  telegraph_url=$(replaceValue "$telegraph_url" HOST "$host")
  new_user_url=$(replaceValue "$new_user_url" HOST "$host")
  webssh_url=$(replaceValue "$webssh_url" HOST "$host")
  serv00_url=$(replaceValue "$serv00_url" HOST "$host")
  bwh_url=$(replaceValue "$bwh_url" HOST "$host")
  bwh_special_url=$(replaceValue "$bwh_special_url" HOST "$host")
  bwh_kvm_url=$(replaceValue "$bwh_kvm_url" HOST "$host")
  nezha_url=$(replaceValue "$nezha_url" HOST "$host")
  tianya_url=$(replaceValue "$tianya_url" HOST "$host")
  tcp_ping_url=$(replaceValue "$tcp_ping_url" HOST "$host")
  
  # 新增URL替换
  server_monitor_url=$(replaceValue "$server_monitor_url" HOST "$host")
  traffic_stats_url=$(replaceValue "$traffic_stats_url" HOST "$host")
  system_update_url=$(replaceValue "$system_update_url" HOST "$host")
  firewall_config_url=$(replaceValue "$firewall_config_url" HOST "$host")
  node_manage_url=$(replaceValue "$node_manage_url" HOST "$host")
  subscription_manage_url=$(replaceValue "$subscription_manage_url" HOST "$host")
  backup_restore_url=$(replaceValue "$backup_restore_url" HOST "$host")
  ip_manage_url=$(replaceValue "$ip_manage_url" HOST "$host")
  resource_usage_url=$(replaceValue "$resource_usage_url" HOST "$host")
  service_status_url=$(replaceValue "$service_status_url" HOST "$host")
fi

if [[ -n "$user" ]]; then
  # 原有URL替换
  button_url=$(replaceValue "$button_url" USER "$user")
  telegraph_url=$(replaceValue "$telegraph_url" USER "$user")
  new_user_url=$(replaceValue "$new_user_url" USER "$user")
  webssh_url=$(replaceValue "$webssh_url" USER "$user")
  serv00_url=$(replaceValue "$serv00_url" USER "$user")
  bwh_url=$(replaceValue "$bwh_url" USER "$user")
  bwh_special_url=$(replaceValue "$bwh_special_url" USER "$user")
  bwh_kvm_url=$(replaceValue "$bwh_kvm_url" USER "$user")
  nezha_url=$(replaceValue "$nezha_url" USER "$user")
  tianya_url=$(replaceValue "$tianya_url" USER "$user")
  tcp_ping_url=$(replaceValue "$tcp_ping_url" USER "$user")
  
  # 新增URL替换
  server_monitor_url=$(replaceValue "$server_monitor_url" USER "$user")
  traffic_stats_url=$(replaceValue "$traffic_stats_url" USER "$user")
  system_update_url=$(replaceValue "$system_update_url" USER "$user")
  firewall_config_url=$(replaceValue "$firewall_config_url" USER "$user")
  node_manage_url=$(replaceValue "$node_manage_url" USER "$user")
  subscription_manage_url=$(replaceValue "$subscription_manage_url" USER "$user")
  backup_restore_url=$(replaceValue "$backup_restore_url" USER "$user")
  ip_manage_url=$(replaceValue "$ip_manage_url" USER "$user")
  resource_usage_url=$(replaceValue "$resource_usage_url" USER "$user")
  service_status_url=$(replaceValue "$service_status_url" USER "$user")
fi

if [[ -n "$PASS" ]]; then
  pass=$(toBase64 "$PASS")
  # 原有URL替换
  button_url=$(replaceValue "$button_url" PASS "$pass")
  telegraph_url=$(replaceValue "$telegraph_url" PASS "$pass")
  new_user_url=$(replaceValue "$new_user_url" PASS "$pass")
  webssh_url=$(replaceValue "$webssh_url" PASS "$pass")
  serv00_url=$(replaceValue "$serv00_url" PASS "$pass")
  bwh_url=$(replaceValue "$bwh_url" PASS "$pass")
  bwh_special_url=$(replaceValue "$bwh_special_url" PASS "$pass")
  bwh_kvm_url=$(replaceValue "$bwh_kvm_url" PASS "$pass")
  nezha_url=$(replaceValue "$nezha_url" PASS "$pass")
  tianya_url=$(replaceValue "$tianya_url" PASS "$pass")
  tcp_ping_url=$(replaceValue "$tcp_ping_url" PASS "$pass")
  
  # 新增URL替换
  server_monitor_url=$(replaceValue "$server_monitor_url" PASS "$pass")
  traffic_stats_url=$(replaceValue "$traffic_stats_url" PASS "$pass")
  system_update_url=$(replaceValue "$system_update_url" PASS "$pass")
  firewall_config_url=$(replaceValue "$firewall_config_url" PASS "$pass")
  node_manage_url=$(replaceValue "$node_manage_url" PASS "$pass")
  subscription_manage_url=$(replaceValue "$subscription_manage_url" PASS "$pass")
  backup_restore_url=$(replaceValue "$backup_restore_url" PASS "$pass")
  ip_manage_url=$(replaceValue "$ip_manage_url" PASS "$pass")
  resource_usage_url=$(replaceValue "$resource_usage_url" PASS "$pass")
  service_status_url=$(replaceValue "$service_status_url" PASS "$pass")
fi

# URL编码
button_url_encoded=$(urlencode "$button_url")
telegraph_url_encoded=$(urlencode "$telegraph_url")
new_user_url_encoded=$(urlencode "$new_user_url")
webssh_url_encoded=$(urlencode "$webssh_url")
serv00_url_encoded=$(urlencode "$serv00_url")
bwh_url_encoded=$(urlencode "$bwh_url")
bwh_special_url_encoded=$(urlencode "$bwh_special_url")
bwh_kvm_url_encoded=$(urlencode "$bwh_kvm_url")
nezha_url_encoded=$(urlencode "$nezha_url")
tianya_url_encoded=$(urlencode "$tianya_url")
tcp_ping_url_encoded=$(urlencode "$tcp_ping_url")

# 新增URL编码
server_monitor_url_encoded=$(urlencode "$server_monitor_url")
traffic_stats_url_encoded=$(urlencode "$traffic_stats_url")
system_update_url_encoded=$(urlencode "$system_update_url")
firewall_config_url_encoded=$(urlencode "$firewall_config_url")
node_manage_url_encoded=$(urlencode "$node_manage_url")
subscription_manage_url_encoded=$(urlencode "$subscription_manage_url")
backup_restore_url_encoded=$(urlencode "$backup_restore_url")
ip_manage_url_encoded=$(urlencode "$ip_manage_url")
resource_usage_url_encoded=$(urlencode "$resource_usage_url")
service_status_url_encoded=$(urlencode "$service_status_url")

# 检查按钮URL是否为null，如果是则使用默认URL
if [[ "$button_url_encoded" == "null" ]]; then
  button_url_encoded=$(urlencode "https://serv00.com")
fi

# 构建按钮布局 - 使用单引号包裹整个JSON，内部使用双引号
reply_markup='{
    "inline_keyboard": [
      [
        {"text": "✨ serv00快速登入 ✨", "url": "'"$new_user_url_encoded"'"}
      ],
      [
        {"text": "✨ webssh快速登入 ✨", "url": "'"$webssh_url_encoded"'"}
      ],
      [
        {"text": "serv00官网", "url": "'"$serv00_url_encoded"'"},
        {"text": "搬瓦工官网", "url": "'"$bwh_url_encoded"'"}
      ],
      [
        {"text": "edgetunnel最新节点", "url": "'"$bwh_special_url_encoded"'"},
        {"text": "汇聚订阅器", "url": "'"$bwh_kvm_url_encoded"'"}
      ],
      [
        {"text": "🔮 哪吒面板 🔮", "url": "'"$nezha_url_encoded"'"}
      ],
      [
        {"text": "Serv00 主机状态查询", "url": "'"$tianya_url_encoded"'"}
      ],
      [
        {"text": "🔍 搬瓦工IP排查故障 🔍", "url": "'"$tcp_ping_url_encoded"'"}
      ],
      [
        {"text": "🔮 搬瓦工方案库存监控 🔮", "url": "'"$telegraph_url_encoded"'"}
      ],
      [
        {"text": "🌐 公益节点池 Github 🌐", "url": "'"$server_monitor_url_encoded"'"}
      ],
      [
        {"text": "🔗 公益节点池 FOFA 🔗", "url": "'"$traffic_stats_url_encoded"'"}
      ],
      [
        {"text": "✨ 德鸡 ✨", "url": "'"$system_update_url_encoded"'"},
        {"text": "防火墙设置", "url": "'"$firewall_config_url_encoded"'"}
      ],
      [
        {"text": "节点管理", "url": "'"$node_manage_url_encoded"'"},
        {"text": "订阅管理", "url": "'"$subscription_manage_url_encoded"'"}
      ],
      [
        {"text": "💾 备份恢复 💾", "url": "'"$backup_restore_url_encoded"'"}
      ],
      [
        {"text": "IP管理", "url": "'"$ip_manage_url_encoded"'"}
      ],
      [
        {"text": "📊 资源使用情况 📊", "url": "'"$resource_usage_url_encoded"'"}
      ],
      [
        {"text": "📡 查看服务状态 📡", "url": "'"$service_status_url_encoded"'"}
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
  
  if [ $? -eq 124 ]; then
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
fi
