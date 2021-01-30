package stx.async;

typedef SubTerminalApi<R,E> = stx.async.sub_terminal.Api<R,E>;

@:forward(release) abstract SubTerminal<R,E>(SubTerminalApi<R,E>) from SubTerminalApi<R,E> to SubTerminalApi<R,E>{
  
}