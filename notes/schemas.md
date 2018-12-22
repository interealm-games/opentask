# Schema Notes

 - Configuration File //DONE
   - Config version
   - Task[]
   - Requirement[]
   - Analog[] (Global)
 - Task //DONE
  - ??type "shell" | "process"
  - command: string // must exist in requirements
  - ??isBackground: boolean
  - ?options:CommandOptions
  - ?args: 
  - ??presentation:Pres
  - ??problemMatcher? string | ProblemMatcher | (string | ProblemMatcher)[]; //don' t need this
 - Requirement //DONE
   - name
   - link
   - command (default no extension)
   - Windows
   - Linux
   - Macos ...
   - version (semver)
 - Analog
   - name
   - cmd (path)
 - Local config
   - Config version
   - Analog
 CommandOptions
  - cwd?
  - env?
  - shell? {executable, args}
  


 https://semver.org/
 https://docs.npmjs.com/misc/semver
 

