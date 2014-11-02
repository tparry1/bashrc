# Add npm bin to path.
if command -v npm &>-; then
  source <(npm completion 2>-)
fi
