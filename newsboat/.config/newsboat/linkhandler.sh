#!/bin/sh

# Feed script a url or file location.
# If an image, it will view in sxiv.
# if a video or gif, it will view in mpv
# if a music file or pdf, it will download,
# otherwise it opens link in browser.

if [ -z "$1" ]; then
    url="$(xclip -o)"
else
    url="$1"
fi

case "$url" in
    *mkv|*webm|*mp4|*youtube.com/watch*|*youtube.com/playlist*|*youtube.com/shorts*|*youtu.be*|*hooktube.com*|*bitchute.com*|*videos.lukesmith.xyz*|*odysee.com*)
        quality=$(echo -e "1080p\n720p\n480p\n360p\nbest\nworst" | rofi -dmenu -p "Video Quality" -theme ~/.config/rofi/newsboat-video-quality.rasi)
	# Exit if no quality selected (Esc pressed)
	[ -z "$quality" ] && exit 0
        case "$quality" in
            1080p) setsid -f mpv --ytdl-format="bestvideo[height<=1080]+bestaudio/best" "$url" >/dev/null 2>&1 ;;
            720p) setsid -f mpv --ytdl-format="bestvideo[height<=720]+bestaudio/best" "$url" >/dev/null 2>&1 ;;
            480p) setsid -f mpv --ytdl-format="bestvideo[height<=480]+bestaudio/best" "$url" >/dev/null 2>&1 ;;
            360p) setsid -f mpv --ytdl-format="bestvideo[height<=360]+bestaudio/best" "$url" >/dev/null 2>&1 ;;
            best) setsid -f mpv --ytdl-format="bestvideo+bestaudio/best" "$url" >/dev/null 2>&1 ;;
            worst) setsid -f mpv --ytdl-format="worst" "$url" >/dev/null 2>&1 ;;
            *) setsid -f mpv -quiet "$url" >/dev/null 2>&1 ;;
        esac ;;
    *png|*jpg|*jpe|*jpeg|*gif)
        curl -sL "$url" > "/tmp/$(echo "$url" | sed "s/.*\///;s/%20/ /g")" && sxiv -a "/tmp/$(echo "$url" | sed "s/.*\///;s/%20/ /g")" >/dev/null 2>&1 & ;;
    *pdf|*cbz|*cbr)
        curl -sL "$url" > "/tmp/$(echo "$url" | sed "s/.*\///;s/%20/ /g")" && zathura "/tmp/$(echo "$url" | sed "s/.*\///;s/%20/ /g")" >/dev/null 2>&1 & ;;
    *mp3|*flac|*opus|*mp3?source*)
        qndl "$url" 'curl -LO' >/dev/null 2>&1 ;;
    *)
        readable -o /tmp/x.html -s ~/.config/newsboat/style.css "$url" >/dev/null 2>&1 && setsid -f "$BROWSER" /tmp/x.html >/dev/null 2>&1 ;;
esac
