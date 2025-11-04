source .env
/opt/homebrew/bin/restic backup --exclude-file=./exclude.txt $HOME/
