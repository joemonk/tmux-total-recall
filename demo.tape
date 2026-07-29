Output demo.gif

Set Shell "bash"
Set FontSize 14
Set Width 900
Set Height 450
Set Theme "Dracula"
Set Padding 10

# Start tmux
Type "tmux"
Enter
Sleep 2s

# Browse - prefix+b
Ctrl+b
Type "b"
Sleep 1.5s
Type "deploy"
Sleep 800ms
Enter
Sleep 800ms

# Show what was pasted
Type "echo 'pasted: '"
Sleep 300ms
Ctrl+"]"
Enter
Sleep 800ms

# Save a new command manually - prefix+a
Ctrl+b
Type "a"
Sleep 800ms
Type "kubectl rollout restart deployment/api"
Enter
Sleep 500ms
Type "restart API"
Enter
Sleep 1s
