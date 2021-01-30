package stx.async.terminal;

interface Api<R,E> extends stx.async.sub_terminal.Api<R,E>{

  //upper
  private function release<RR,EE>(term:Terminal<RR,EE>,?pos:Pos):Terminal<RR,EE>;
  
  public function pause(work:stx.async.Work,?pos:Pos):Terminal<R,E>;
  
  public function joint<RR,EE>(joiner:Outcome<RR,Defect<EE>> -> Work,?pos:Pos):Terminal<RR,EE>;
  public function inner<RR,EE>(join:Outcome<RR,Array<EE>> -> Void,?pos:Pos):Terminal<RR,EE>;
  
  public function toTerminalApi():Api<R,E>;
}