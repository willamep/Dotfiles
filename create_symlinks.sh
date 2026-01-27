conf="$HOME/.config"
mkdir -p -- "$conf"
org=$PWD/.config

mapfile -d '' -t configs < <(find "$org" -mindepth 1 -maxdepth 1 -print0)
for p in "${configs[@]}"; do
	name=$(basename -- "$p")
	rm -rf "$conf/$name"
	ln -sfn "$p" "$conf/$name"
	echo "Create symlink: $conf/$name -> $p"
done
