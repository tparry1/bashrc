# Add npm bin to path.
if which npm &> /dev/null; then
  source <(npm completion)
fi
