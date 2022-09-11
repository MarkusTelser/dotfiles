function copydir {
  pwd | tr -d "\r\n" | xclip -selection clipboard
}
