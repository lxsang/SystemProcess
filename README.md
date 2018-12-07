# SystemProcess
* Spawning \*NIX system process using posix_spawn
* Dispatching code to multiple VMs, each VM runs on a separated system process. Inter-processes communication via shared memory

## Install
```Smalltalk
Metacello new
	repository: 'github://lxsang/SystemProcess';
	baseline:'SystemProcess';
	load
```

## Process spawn Example

Execute a command and redirect its stdout

```Smalltalk
|o|
o:= SystemProcess new.
o redirectStdout.
o onOutputDo: [
	:d| Transcript show: d
].
o onFinishDo: [ o cleanup ].
o shellCommand: { 'ls'. '-al' }.
```

Execute a command and redirect its stdin, stdout:

```Smalltalk
|o crlf|
crlf := Character cr asString, Character lf asString.
o:= SystemProcess new.
o redirectStdout.
o redirectStdin.
o onOutputDo: [
	:d| Transcript show: d
].
o onFinishDo: [ o cleanup ].
o shellCommand: { '/bin/sh'}.
o stdinStream nextPutAll: 'ls -al', crlf.
"exit /bin/sh"
o stdinStream nextPutAll: 'exit',crlf
```
### InterVM example
(contd.)
