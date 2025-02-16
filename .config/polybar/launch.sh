killall -q polybar

echo "---" | tee -a /tmp/polybar1.log /tmp/polybar2.log
polybar example --config=~/.config/polybar/config.ini 2>&1 | tee -a /tmp/polybar1.log
# & disown

echo "Bars launched..."
