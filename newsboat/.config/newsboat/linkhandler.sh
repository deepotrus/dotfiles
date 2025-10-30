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

IMG_VIEWER="$(command -v nsxiv || command -v sxiv)"

open_browser() {
    setsid -f ${BROWSER:-xdg-open} "$1" > /dev/null 2>&1
}

open_video() {
    # Use rofi for quality picking
	quality=$(printf "auto\n1080p\n720p\n480p\n360p\nbest\nworst" | rofi -dmenu -p "Choose:" -theme ~/.config/rofi/newsboat-video-quality.rasi)
	# Exit if no quality selected (Esc pressed)
	[ -z "$quality" ] && exit 0
    case "$quality" in
		auto)  setsid -f mpv -quiet "$1" >/dev/null 2>&1 ;;
        1080p) setsid -f mpv --ytdl-format="bestvideo[height<=1080]+bestaudio/best" "$url" >/dev/null 2>&1 ;;
        720p)  setsid -f mpv --ytdl-format="bestvideo[height<=720]+bestaudio/best" "$url" >/dev/null 2>&1 ;;
        480p)  setsid -f mpv --ytdl-format="bestvideo[height<=480]+bestaudio/best" "$url" >/dev/null 2>&1 ;;
        360p)  setsid -f mpv --ytdl-format="bestvideo[height<=360]+bestaudio/best" "$url" >/dev/null 2>&1 ;;
        best)  setsid -f mpv --ytdl-format="bestvideo+bestaudio/best" "$url" >/dev/null 2>&1 ;;
        worst) setsid -f mpv --ytdl-format="worst" "$url" >/dev/null 2>&1 ;;
        *)     setsid -f mpv -quiet "$url" >/dev/null 2>&1 ;;
    esac
}

# Open videos with automatic quality
open_video_auto() {
	setsid -f mpv -quiet "$1" >/dev/null 2>&1
}

open_image_tmp() {
	[ -n "$IMG_VIEWER" ] || { open_browser "$1"; exit 0; }
	name="$(printf "%s" "$1" | sed 's/.*\///;s/%20/ /g')"
	dest="/tmp/$name"
	#curl -fsSL -A "Mozilla/5.0" "$1" -o "$dest" && sxiv -a "$dest" >/dev/null 2>&1 &
	if curl -fsSL -A "Mozilla/5.0" "$1" -o "$dest"; then
		( "$IMG_VIEWER" -a "$dest"; rm -f "$dest" ) >/dev/null 2>&1 &
	fi
}



case "$url" in
	*v.redd.it/*)
		open_video_auto "$url"
		;;

    *youtube.com/watch*|*youtube.com/playlist*|*youtube.com/shorts*|*youtu.be*|*v.redd.it/*)
        open_video "$url"
        ;;

	# Direct images anywhere
	*.png|*.jpg|*.jpeg|*.jpe|*.gif|*.webp)
		open_image_tmp "$url"
		;;

    # Fallback into browser
    *)
        open_browser "$url"
        ;;
esac